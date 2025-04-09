//
//  AV.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var activity: Activity

    @FocusState private var focusedField: PersistentIdentifier?

    @State private var swipedSetID: PersistentIdentifier?
    // Dictionary to store local state as strings
    @State private var localRepsText: [PersistentIdentifier: String] = [:]
    @State private var localWeightText: [PersistentIdentifier: String] = [:]

    var body: some View {
        ScrollView(showsIndicators: false) {
            sets(type: .warmUp, sets: $activity.sets)
                .padding(.horizontal)

            sets(type: .working, sets: $activity.sets)
                .padding(.horizontal)
        }
        .navigationTitle(Text(activity.name))
        .onTapGesture {
            // Clears focus to dismiss the keyboard and save changes
            saveCurrentFieldValue()
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
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue != nil && oldValue != newValue {
                // Save when focus changes from one field to another
                saveCurrentFieldValue(id: oldValue)
            }
        }
        .onDisappear {
            // Save all field values when view disappears
            saveAllFieldValues()
        }
        .onAppear {
            // Initialize local state for all sets when view appears
            initializeLocalState()
        }
    }

    // Initialize all local state from the activity sets
    private func initializeLocalState() {
        for set in activity.sets {
            localRepsText[set.id] = "\(set.reps)"
            localWeightText[set.id] = "\(set.weight)"
        }
    }

    /// This makes up each item in the warmp and working sets list.
    /// - Parameter set: The set to be edited by the TextFields
    /// - Returns: Return the item view for a singluar ``SetData``
    @ViewBuilder
    private func item(set: Binding<SetData>) -> some View {
        let isSwiped = swipedSetID == set.wrappedValue.id
        let setID = set.wrappedValue.id

        HStack {
            Button(action: { set.wrappedValue.isComplete.toggle() }) {
                Image(systemName: set.wrappedValue.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.wrappedValue.isComplete ? .green : .gray)
            }

            // Reps TextField using string input
            TextField("Reps", text: Binding(
                get: { localRepsText[setID] ?? "" },
                set: {
                    var filtered = $0.filter { "0123456789".contains($0) } // Only allow digits
                    // Remove leading zeros but allow "0" when the field is empty
                    filtered = String(filtered.drop(while: { $0 == "0" }))
                    // If filtered is empty, default to "0" to avoid blank input
                    localRepsText[setID] = filtered.isEmpty ? "0" : filtered
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .focused($focusedField, equals: setID)

            Spacer()
            Text("/ \(set.wrappedValue.sortIndex) /") // TODO: remove before commit
                .padding(.horizontal)
            Spacer()

            // Weight TextField using string input
            HStack {
                TextField("Weight", text: Binding(
                    get: { localWeightText[setID] ?? "" },
                    set: {
                        var filtered = $0.filter { "0123456789.".contains($0) }
                        // Ensure at most one decimal point
                        if filtered.filter({ $0 == "." }).count > 1 {
                            return
                        }
                        // Remove leading zeros (but allow "0." case)
                        if filtered.hasPrefix("0") && !filtered.hasPrefix("0.") {
                            filtered = String(filtered.drop(while: { $0 == "0" }))
                        }
                        // Remove trailing zeros after a decimal (e.g., "12.3400" -> "12.34")
                        if filtered.contains(".") {
                            filtered = filtered
                            // Remove leading zeros
                                .replacingOccurrences(of: #"^0+"#, with: "", options: .regularExpression)
                            // Remove trailing zeros
                                .replacingOccurrences(of: #"(\.\d*?[1-9])0+$"#, with: "$1", options: .regularExpression)
                            // Remove unnecessary ".0"
                                .replacingOccurrences(of: #"(\.0+)$"#, with: "", options: .regularExpression)
                        }
                        localWeightText[setID] = filtered.isEmpty ? "0" : filtered
                    }

                ))
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: setID)
            }
            .padding(5)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))

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
        .onAppear {
            // Ensure local state exists for this set
            ensureLocalStateExists(for: setID, set: set.wrappedValue)
        }
    }

    /// This view shows a list of sets for the provided input.
    /// - Parameters:
    ///   - type: The type of the sets.
    ///   - sets: an array of ``SetData`` objects.
    /// - Returns: A ``View`` displaying the count of sets, a title, list of set items, and the add activity button.
    @ViewBuilder
    private func sets(type: SetData.SetType, sets: Binding<[SetData]>) -> some View {
//        let filteredSets = sets.wrappedValue.indices.filter { sets.wrappedValue[$0].type == type }
        let filteredSets = sets.wrappedValue
            .filter { $0.type == type }
            .sorted(by: { $0.sortIndex < $1.sortIndex })

        HStack {
            let title = type == .warmUp ? "warm up" : "working"
            Text("\(filteredSets.count) \(title) set\(filteredSets.count == 1 ? ":" : "s:")")
                .font(.lato(type: .light, size: .subtitle))
            Spacer()
        }

//        ForEach(filteredSets, id: \.self) { index in
//            item(set: sets[index]) // Use direct binding to modify set
//        }
        ForEach(filteredSets, id: \.id) { set in
            if let binding = sets.first(where: { $0.id == set.id }) {
                item(set: binding)
            }
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
                // find the max values of all the sets and add one to it
                var index = activity.sets.max(by: { $0.sortIndex < $1.sortIndex })?.sortIndex ?? 0
                index += 1
                // For now, use the defualt values
                let newSet = SetData(type: type, parentActivity: activity, sortIndex: index)
                activity.sets.append(newSet)
                // Initialize local state for the new set
                localRepsText[newSet.id] = "\(newSet.reps)"
                localWeightText[newSet.id] = "\(newSet.weight)"
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

    /// Helper function to ensure local state exists for a set
    /// - Parameters:
    ///   - id: ID of the set.
    ///   - set: The ``SetData`` to draw from.
    private func ensureLocalStateExists(for id: PersistentIdentifier, set: SetData) {
        if localRepsText[id] == nil {
            localRepsText[id] = "\(set.reps)"
        }

        if localWeightText[id] == nil {
            localWeightText[id] = "\(set.weight)"
        }
    }

    /// Saves the current field value to the model if focus is leaving a field
    private func saveCurrentFieldValue(id: PersistentIdentifier? = nil) {
        let idToSave = id ?? focusedField

        guard let setID = idToSave else { return }

        // Find the set in the activity and update it
        if let index = activity.sets.firstIndex(where: { $0.id == setID }) {
            // Convert string to Int for reps
            if let repsText = localRepsText[setID], let reps = Int(repsText) {
                activity.sets[index].reps = reps
            }

            // Convert string to Double for weight
            if let weightText = localWeightText[setID], let weight = Double(weightText) {
                activity.sets[index].weight = weight
            }

            // Try to save to model context
            try? modelContext.save()
        }
    }

    /// Saves all local field values to the model
    private func saveAllFieldValues() {
        // Save current focused field first
        saveCurrentFieldValue()

        // Then save all other fields that have local state
        for (setID, repsText) in localRepsText {
            if let index = activity.sets.firstIndex(where: { $0.id == setID }), let reps = Int(repsText) {
                activity.sets[index].reps = reps
            }
        }

        for (setID, weightText) in localWeightText {
            if let index = activity.sets.firstIndex(where: { $0.id == setID }), let weight = Double(weightText) {
                activity.sets[index].weight = weight
            }
        }

        // Try to save to model context
        try? modelContext.save()
    }

    /// Deletes an ``SetData`` at the given index.
    /// - Parameter index: The index of the set to delete.
    private func deleteSet(at index: Int) {
        withAnimation {
            let setToDelete = activity.sets[index]
            // Remove from dictionaries to clean up
            localRepsText.removeValue(forKey: setToDelete.id)
            localWeightText.removeValue(forKey: setToDelete.id)
            // Remove from model context to actually delete the object
            modelContext.delete(setToDelete)
            try? modelContext.save()
            // Remove reference from the list
//            activity.sets.remove(at: index)
        }
        print("sets count: \(activity.sets.count)")
    }
}

#Preview {
    ActivityView(
        activity: .constant(
            Activity(
                sets: [
                    SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, sortIndex: 0),
                    SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: false, sortIndex: 1),
                    SetData(type: .working, reps: 8, weight: 50.5, isComplete: false, sortIndex: 2),
                    SetData(type: .working, reps: 8, weight: 50.0, isComplete: false, sortIndex: 3),
                    SetData(type: .working, reps: 12, weight: 30.0, isComplete: false, sortIndex: 4)
                ],
                parentExercise: Exercise(name: "Bench Press"),
                parentWorkout: Workout(gym: "tester"), sortIndex: 0
            )
        ))
}
