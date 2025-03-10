//
//  AV.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI
import SwiftData

struct AV: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var activity: Activity
    @FocusState private var focusedField: PersistentIdentifier?
    @State private var swipedSetID: PersistentIdentifier? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            sets(type: .warmUp, sets: $activity.sets)
                .padding(.horizontal)

            sets(type: .working, sets: $activity.sets)
                .padding(.horizontal)
        }
        .navigationTitle(Text(activity.name))
        .onTapGesture {
            // Clears focus to dismiss the keyboard
            focusedField = nil
            withAnimation(.snappy) {
                swipedSetID = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.snappy) {
                swipedSetID = nil // Dismiss swipe when keyboard appears
            }
        }
    }

    /// This makes up each item in the warmp and working sets list.
    /// - Parameter set: The set to be edited by the TextFields
    /// - Returns: Return the item view for a singluar ``SetData``
    @ViewBuilder
    private func item(set: Binding<SetData>) -> some View {
        let isSwiped = swipedSetID == set.wrappedValue.id
        HStack {
            Button(action: { set.wrappedValue.isComplete.toggle() }) {
                Image(systemName: set.wrappedValue.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.wrappedValue.isComplete ? .green : .gray)
                    .font(.lato(type: .regular, size: .medium))
            }
            TextField("Reps", value: set.reps, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .focused($focusedField, equals: set.id)
            Spacer()
            Text("/")
                .padding(.horizontal)
            Spacer()
            TextField("Weight", value: set.weight, formatter: decimalFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: set.id)

            if isSwiped {
                Button(action: {
                    withAnimation(.snappy) {
                        if let index = activity.sets.firstIndex(where: { $0.id == set.wrappedValue.id }) {
                            deleteSet(at: index)
                        }
                        swipedSetID = nil
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.red)
                        .clipShape(Circle())
                }
//                .transition(.move(edge: .trailing))
            }
        }
        .padding(.vertical, 5.0)
        .contentShape(Rectangle()) // Makes the whole row draggable
        .gesture(
            DragGesture()
            
                .onChanged { value in
                    if value.translation.width < -50 {
                        withAnimation {
                            swipedSetID = set.wrappedValue.id
                        }
                    }
                }
        )
    }

    /// This view shows a list of sets for the provided input.
    /// - Parameters:
    ///   - type: The type of the sets.
    ///   - sets: an array of ``SetData`` objects.
    /// - Returns: A ``View`` displaying the count of sets, a title, list of set items, and the add activity button.
    @ViewBuilder
    private func sets(type: SetData.SetType, sets: Binding<[SetData]>) -> some View {
        let filteredSets = sets.wrappedValue.indices.filter { sets.wrappedValue[$0].type == type }

        HStack {
            let title = type == .warmUp ? "warm up" : "working"
            Text("\(filteredSets.count) \(title) set\(filteredSets.count == 1 ? ":" : "s:")")
                .font(.lato(type: .light, size: .subtitle))
            Spacer()
        }

        ForEach(filteredSets, id: \.self) { index in
            item(set: sets[index]) // Use direct binding to modify set
        }

        addSetButton(type: type)
    }

    /// The add set button for the list of sets.
    /// - Parameter type: The type of set. Can be any ``SetData.SetType``.
    /// - Returns: A ``View`` of the add set button.
    @ViewBuilder
    private func addSetButton(type: SetData.SetType) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                // For now, use the defualt values
                let newSet = SetData(type: type, parentActivity: activity)
                activity.sets.append(newSet)
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.title3)
                let title = type == .warmUp ? "warm up" : "working"
                Text("Add \(title) set")
                    .font(.lato(type: .regular, size: .subtitle))
            }
        }
        .padding(.vertical, 5.0)
    }

    // MARK: - Helpers
    /// A ``NumberFormatter`` for ``SetData.weight`` which allows the following formats:
    /// 50, 50.5, 50.25
    /// It will autocorrect to these formats.
    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0   // Allow whole numbers without decimal places
        formatter.maximumFractionDigits = 2   // Allow up to two decimal places
        formatter.alwaysShowsDecimalSeparator = false // No forced decimal unless needed
        return formatter
    }()

    /// Deletes an ``SetData`` at the given index.
    /// - Parameter index: The index of the set to delete.
    private func deleteSet(at index: Int) {
        withAnimation {
            let setToDelete = activity.sets[index]
            // Remove from model context to actually delete the object
            modelContext.delete(setToDelete)
            // Remove reference from the list
            activity.sets.remove(at: index)
            try? modelContext.save()
        }
        print("Deleted activity at index \(index)")
    }
}

#Preview {
    AV(
        activity: .constant(
            Activity(
                sets: [
                    SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true),
                    SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: false),
                    SetData(type: .working, reps: 8, weight: 50.5, isComplete: false),
                    SetData(type: .working, reps: 8, weight: 50.0, isComplete: false),
                    SetData(type: .working, reps: 12, weight: 30.0, isComplete: false)
                ],
                parentExercise: Exercise(name: "Bench Press"),
                parentWorkout: Workout(gym: "tester")
            )
        ))
}
