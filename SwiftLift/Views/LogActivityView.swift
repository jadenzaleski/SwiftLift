//
//  LogActivityView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/21/23.
//

import SwiftUI
import SwiftData

struct LogActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.dismiss) var dismiss
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
    @Binding var activity: Activity
    @State var notes = ""
    @SceneStorage("isDeleting") private var isDeleting: Bool = false
    private let debouncer = Debouncer()

    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Text("\(activity.name)")
                    .font(.lato(type: .light, size: .title))
                Spacer()
            }
            Divider()
            HStack {
                let count = activity.warmUpSets.count
                Text(count == 1 ? "\(count) warmup set:" : "\(count) warmup sets:")
                    .font(.lato(type: .light, size: .subtitle))
                Spacer()
            }
            .padding(.horizontal)

            ForEach(Array(activity.warmUpSets.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    SetPill(set: $activity.warmUpSets[index], isDeleting: $isDeleting)
                        .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)
                    if isDeleting {
                        Button(action: {
                            activity.warmUpSets.remove(at: index)
                            // haptic feedback
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }, label: {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundStyle(Color.red)
                        })
                        .padding(.leading, 5.0)
                    }
                }
                .padding(.vertical, 2.0)
            }

            Button(action: {
                activity.warmUpSets.append(SetData(reps: 0, weight: 0, isChecked: false))
                // haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }, label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                    Text("Add warm up set")
                        .font(.lato(type: .regular, size: .subtitle))
                    Spacer()
                }
            })
            .padding(.top, 5.0)

            HStack {
                let count = activity.workingSets.count
                Text(count == 1 ? "\(count) working set:" : "\(count) working sets:")
                    .font(.lato(type: .light, size: .subtitle))
                Spacer()
            }
            .padding([.top, .horizontal])

            ForEach(Array(activity.workingSets.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    SetPill(set: $activity.workingSets[index], isDeleting: $isDeleting)
                        .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)
                    if isDeleting {
                        Button(action: {
                            activity.workingSets.remove(at: index)
                            // haptic feedback
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }, label: {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundStyle(Color.red)
                        })
                        .padding(.leading, 5.0)
                    }
                }
                .padding(.vertical, 2.0)
            }

            Button(action: {
                activity.workingSets.append(SetData(reps: 0, weight: 0.0, isChecked: false))
                // haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }, label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                    Text("Add working set")
                        .font(.lato(type: .regular, size: .subtitle))
                    Spacer()
                }
            })
            .padding(.top, 5.0)

            HStack {
                Text("Notes:")
                    .font(.lato(type: .light, size: .subtitle))
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)
            TextField("Add note", text: $notes, axis: .vertical)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .font(.lato(type: .regular, size: .body))
                .onAppear {
                    notes = exercises[getExerciseIndex(name: activity.name)].notes
                }
                .onChange(of: notes) {
                    debouncer.debounce(interval: 3.0) {
                        exercises[getExerciseIndex(name: activity.name)].notes = notes
                    }
                }
                .background(Color("offset"))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)

        }
        .navigationTitle(Text(activity.name))
        .scrollDismissesKeyboard(.immediately)
        .padding(.horizontal)
        // for some strange reason xcode throws and error if you combine the below two toolbars
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                    Button {
                        withAnimation(.interactiveSpring) {
                            isDeleting.toggle()
                        }
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

    private func getExerciseIndex(name: String) -> Int {
        return exercises.firstIndex(where: { $0.name == name }) ?? 0
    }
}

#Preview {
    LogActivityView(activity: .constant(Activity.sampleActivites[0]))
        .modelContainer(for: [History.self, Exercise.self], inMemory: false)
}
