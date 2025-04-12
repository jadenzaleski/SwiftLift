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
    @State var test = SetData(sortIndex: 0)
    @State var test2 = SetData(sortIndex: 1)
    @State var test3 = SetData(sortIndex: 2)

    private let horizontalSpacing: CGFloat = 15

    var body: some View {
        List {
            Section {
                warmUpSection()
            }
            .listSectionSeparator(.hidden)

            Section {
                workingSection()
            } header: {

            }
            .listSectionSeparator(.hidden)

        }
        .navigationTitle(activity.name)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func warmUpSection() -> some View {
        Text("\(activity.warmUpSets.count) warm up set\(activity.warmUpSets.count == 1 ? ":" : "s:")")
            .font(.lato(type: .light, size: .subtitle))
            .foregroundStyle(.ld)
            .listRowSeparator(.hidden)

        ForEach(Array(activity.warmUpSets.enumerated()), id: \.1.id) { index, set in
                listItem(set: set, index: index)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 2)
        }
        .onMove(perform: moveSet)

        Button {
            withAnimation(.easeInOut) {
                // Create new set with appropriate type
                let newSet = SetData(type: .warmUp, parentActivity: activity, sortIndex: activity.sets.count)

                // Find position to insert - right after the last warm-up set
                if let lastWarmUpIndex = activity.sets.lastIndex(where: { $0.type == .warmUp }) {
                    activity.sets.insert(newSet, at: lastWarmUpIndex + 1)
                } else if let firstWorkingIndex = activity.sets.firstIndex(where: { $0.type == .working }) {
                    // If no warm-up sets yet, insert before first working set
                    activity.sets.insert(newSet, at: firstWorkingIndex)
                } else {
                    // If no sets at all, just append
                    activity.sets.append(newSet)
                }

                updateSortIndices()
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(systemName: "plus")
                    .foregroundStyle(Color.accentColor)

                Text("Add set")
                    .font(.lato(type: .regular, size: .subtitle))
                    .foregroundStyle(Color.accentColor)
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: horizontalSpacing, bottom: 0, trailing: horizontalSpacing))
    }

    @ViewBuilder
    private func workingSection() -> some View {
        Text("\(activity.workingSets.count) working set\(activity.workingSets.count == 1 ? ":" : "s:")")
            .font(.lato(type: .light, size: .subtitle))
            .foregroundStyle(.ld)
            .listRowSeparator(.hidden)

        ForEach(Array(activity.workingSets.enumerated()), id: \.1.id) { index, set in
                listItem(set: set, index: index)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 2)
        }
        .onMove(perform: moveSet)

        Button {
            withAnimation(.easeInOut) {
                let newSet = SetData(type: .working, parentActivity: activity, sortIndex: activity.sets.count + 1)
                // Just add to end of list since we display working last
                activity.sets.append(newSet)
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(systemName: "plus")
                    .foregroundStyle(Color.accentColor)

                Text("Add set")
                    .font(.lato(type: .regular, size: .subtitle))
                    .foregroundStyle(Color.accentColor)
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: horizontalSpacing, bottom: 0, trailing: horizontalSpacing))
    }

    @ViewBuilder
    private func listItem(set: SetData, index: Int) -> some View {
        let setIndex = activity.sets.firstIndex(where: { $0.id == set.id })!
        let setBinding = $activity.sets[setIndex]

        HStack(alignment: .center, spacing: 0) {
            Button {
                setBinding.wrappedValue.isComplete.toggle()
            } label: {
                Image(systemName: set.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.isComplete ? .green : .gray)
                    .font(.lato(size: .subtitle))
            }
            .buttonStyle(.plain)
            .padding(.trailing, horizontalSpacing)
            // This blank text needs to be here so the list divider goes all the way to
            // the button, and doesn't stop at inbetween the textfields.
            Text("").frame(maxWidth: 0)
            HStack {
                TextField("reps", value: setBinding.reps, formatter: NumberFormatter())
            }
            .padding(5)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            // Divider
            Text("/si: \(set.sortIndex)")
                .padding(.horizontal, horizontalSpacing * 2)
            HStack {
                TextField("weight", value: setBinding.weight, formatter: NumberFormatter())
            }
            .padding(5)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .font(.lato(type: .bold))
    }

}

// MARK: - Helpers
extension ActivityView {
    /// Performs the move operation when the user drags an activity from one position to another in the list.
    /// This function maintains the proper sort order of sets by updating all sortIndex values.
    /// Had a hard time understand this so Claude helped.
    /// - Parameters:
    ///   - source: The original `IndexSet` containing the indices of items to be moved.
    ///   - destination: The destination index where the items should be moved to.
    private func moveSet(from source: IndexSet, to destination: Int) {
        // Create a mutable copy of the already sorted sets array
        // Even though this creates a new array, it contains references to the same SwiftData-managed
        // SetData objects, so modifying them here will update the actual objects in the database
        var sets = activity.sortedSets

        // Rearrange the items in our temporary array according to the drag operation
        sets.move(fromOffsets: source, toOffset: destination)

        // Update ALL sortIndex values to match the new order
        // Since SetData objects are reference types and tracked by SwiftData,
        // changing properties here directly updates the objects in the SwiftData store,
        // regardless of how we accessed them (through sortedSets or directly)
        for (index, set) in sets.enumerated() {
            set.sortIndex = index
        }

        // Save changes to ensure the updates are persisted
        try? modelContext.save()
        print("Move saved!")
    }

    // Add this helper function to update all sort indices
    private func updateSortIndices() {
        // First, separate sets by type
        let warmUpSets = activity.warmUpSets
        let workingSets = activity.workingSets

        // Then update sort indices for all sets
        var index = 0

        // Update warm-up sets first
        for set in warmUpSets {
            set.sortIndex = index
            index += 1
        }

        // Then update working sets
        for set in workingSets {
            set.sortIndex = index
            index += 1
        }

        // Force a refresh of the activity sets by reassigning
        let updatedSets = activity.sets
        activity.sets = updatedSets

        try? modelContext.save()
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
    .environment(\.font, .lato(type: .regular))

}
