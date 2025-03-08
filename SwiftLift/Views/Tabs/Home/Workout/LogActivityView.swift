import SwiftUI
import SwiftData

struct LogActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var exercises: [Exercise]
    @Binding var activity: Activity
    @State private var notes = ""
    @SceneStorage("isDeleting") private var isDeleting: Bool = false
    private let debouncer = Debouncer()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            activityHeader
            Divider()
            setSection(title: "warmup", sets: $activity.warmUpSets)
            addSetButton(for: $activity.warmUpSets, title: "Add warm up set")
            setSection(title: "working", sets: $activity.workingSets)
            addSetButton(for: $activity.workingSets, title: "Add working set")
            notesSection
        }
        .navigationTitle(Text(activity.name))
        .scrollDismissesKeyboard(.immediately)
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
    }
    
    private var activityHeader: some View {
        HStack {
            Text(activity.name)
                .font(.lato(type: .light, size: .title))
            Spacer()
        }
    }
    
    private func setSection(title: String, sets: Binding<[SetData]>) -> some View {
        VStack(alignment: .leading) {
            Text("\(sets.wrappedValue.count) \(title) set\(sets.wrappedValue.count == 1 ? ":" : "s:")")
                .font(.lato(type: .light, size: .subtitle))
                .padding(.horizontal)
            ForEach(Array(sets.wrappedValue.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    SetPill(set: sets[index], isDeleting: $isDeleting)
                        .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)
                    if isDeleting {
                        deleteButton(for: sets, index: index)
                    }
                }
                .padding(.vertical, 2.0)
            }
        }
    }
    
    private func deleteButton(for sets: Binding<[SetData]>, index: Int) -> some View {
        Button(action: {
            sets.wrappedValue.remove(at: index)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundStyle(Color.red)
        }
        .padding(.leading, 5.0)
    }
    
    private func addSetButton(for sets: Binding<[SetData]>, title: String) -> some View {
        Button(action: {
            sets.wrappedValue.append(SetData(reps: 0, weight: 0.0, isComplete: false))
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack {
                Spacer()
                Image(systemName: "plus")
                    .font(.title3)
                Text(title)
                    .font(.lato(type: .regular, size: .subtitle))
                Spacer()
            }
        }
        .padding(.top, 5.0)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .font(.lato(type: .light, size: .subtitle))
                .padding(.leading)
            TextField("Add note", text: $notes, axis: .vertical)
                .padding()
                .font(.lato(type: .regular, size: .body))
                .onAppear { loadNotes() }
                .onChange(of: notes) { saveNotes() }
                .background(Color("offset"))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)
        }
        .padding(.top)
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    withAnimation(.interactiveSpring) { isDeleting.toggle() }
                } label: {
                    Text(isDeleting ? "Done" : "Edit")
                        .font(.lato(type: .regular))
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    UIApplication.shared.dismissKeyboard()
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .padding(.all, 5.0)
            }
        }
    }
    
    private func loadNotes() {
        notes = exercises.first(where: { $0.name == activity.name })?.notes ?? ""
    }
    
    private func saveNotes() {
        debouncer.debounce(interval: 3.0) {
            if let index = exercises.firstIndex(where: { $0.name == activity.name }) {
                exercises[index].notes = notes
            }
        }
    }
}

#Preview {
    LogActivityView(activity: .constant(
        Activity(
            warmUpSets: [
                SetData(reps: 10, weight: 20.0, isComplete: true),
                SetData(reps: 15, weight: 30.0, isComplete: false)
            ],
            workingSets: [
                SetData(reps: 8, weight: 50.5, isComplete: false),
                SetData(reps: 8, weight: 50.0, isComplete: false),
                SetData(reps: 12, weight: 30.0, isComplete: false)
            ],
            parentExercise: Exercise(name: "Bench Press"),
            parentWorkout: Workout(gym: "tester")
        )
    ))
    .modelContainer(previewContainer)
}
