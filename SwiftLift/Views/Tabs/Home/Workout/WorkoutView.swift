//
//  WorkoutView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var workoutInProgress: Bool
    /// This comes from ``HomeView`` `stopWorkout` and is the function used to stop the workout.
    /// Pass in a ``Bool`` that tells the function to save it to the database or not.
    var stopWorkout: (Bool) -> Void
    /// This does not need to be used and is only here to trigger a UI update for this ``View``.
    let timerTick: Int

    @SceneStorage("isPresentingExerciseSearch") private var isPresentingExerciseSearch: Bool = false

    /// Boolean to keep track of wether or not the delete workout alert is showing. In ``workoutToolbar``.
    @State var showDeleteAlert: Bool = false
    /// The current ``Workout``, if any.
    @State var currentWorkout: Workout

    private let lineCornerRadius: CGFloat = 2
    private let lineWidth: CGFloat = 2
    private let horizontalInsets: CGFloat = 15

    var body: some View {
        List {
            Section {
                workoutHeader()
            }
            .listSectionSeparator(.hidden)

            Section {
                activityList()
            }
            .listSectionSeparator(.hidden, edges: .bottom)

        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .sheet(isPresented: $isPresentingExerciseSearch) {
            ExerciseSearch(currentWorkout: $currentWorkout, isPresentingExerciseSearch: $isPresentingExerciseSearch)
        }
        .toolbar {
            workoutToolbar()
        }
    }

    // MARK: - Header
    /// The header that displayes when a ``workoutInProgress`` is true.
    @ViewBuilder
    private func workoutHeader() -> some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "timer")
                Text(timeString(from: currentWorkout.duration))
                    .monospacedDigit()
                Spacer()
                Text(currentWorkout.gym)
                    .lineLimit(1)
                Image(systemName: "location")
            }
            .padding(.bottom, 2.0)
            .font(.lato(type: .light, size: .heading))

            HStack {
                let count = currentWorkout.activities.count
                let text = count == 1 ? "Exercise" : "Exercises"
                Text("\(currentWorkout.activities.count) \(text):")
                    .font(.lato(type: .light, size: .heading))
                Spacer()
            }
        }
        .listRowInsets(.init(top: 0, leading: horizontalInsets, bottom: 0, trailing: horizontalInsets))
    }

    // MARK: - Activity List
    /// Displays a list of activities with navigation links.
    @ViewBuilder
    private func activityList() -> some View {
        ForEach(Array(currentWorkout.sortedActivities.enumerated()), id: \.1.id) { index, activity in
            rowItem(activity: activity, index: index)
        }
        .onMove(perform: moveActivity)

        Button {
            isPresentingExerciseSearch.toggle()
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(systemName: "plus")
                    .foregroundStyle(Color.accentColor)

                Text("Add Exercise")
                    .font(.lato(type: .regular, size: .subtitle))
                    .foregroundStyle(Color.accentColor)
                    .padding(.vertical, 25)
                Spacer()
            }
        }
        .listRowInsets(.init(top: 0, leading: horizontalInsets, bottom: 0, trailing: horizontalInsets))
    }

    /// The view for each list item in the list of activites.
    /// - Parameters:
    ///   - activity: The ``Activity`` Binding to be shown.
    ///   - index: The index of the activity in the array.
    /// - Returns: ``View`` of the activity for a list.
    /// - Important: The ``index`` parameter is not always the same as ``Activity.sortIndex``
    @ViewBuilder
    private func rowItem(activity: Activity, index: Int) -> some View {
        // Get the actual index in the unsorted array for binding
        let activityIndex = currentWorkout.activities.firstIndex(where: { $0.id == activity.id })!
        let activityBinding = $currentWorkout.activities[activityIndex]
        let completedSets = activity.sets.count(where: \.isComplete)
        let totalSets = activity.sets.count
        // Is this activity empty, in progress, or complete?
        let activityState: Int = activity.sets.isEmpty ? 0 : (activity.isComplete ? 1 : 2)

        let topLineFillColor: Color = {
            if index == 0 {
                return .clear // No line for the first activity
            }
            let previousActivity = currentWorkout.sortedActivities[index - 1]
            // Only show green line if both activities are complete AND have sets
            return activity.isComplete && !activity.sets.isEmpty &&
            previousActivity.isComplete && !previousActivity.sets.isEmpty ? .green : .gray
        }()

        let bottomLineFillColor: Color = {
            if index == currentWorkout.activities.count - 1 {
                return .clear // No line for the last activity
            }
            let nextActivity = currentWorkout.sortedActivities[index + 1]
            // Only show green line if both activities are complete AND have sets
            return activity.isComplete && !activity.sets.isEmpty &&
            nextActivity.isComplete && !nextActivity.sets.isEmpty ? .green : .gray
        }()

        NavigationLink(destination: ActivityView(activity: activityBinding)) {
            HStack(alignment: .center, spacing: horizontalInsets) {
                VStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: lineCornerRadius,
                        bottomTrailingRadius: lineCornerRadius,
                        topTrailingRadius: 0
                    )
                    .fill(topLineFillColor)
                    .frame(width: lineWidth)

                    Image(systemName:
                            activityState == 1 ? "checkmark.circle.fill" :
                            activityState == 0 ? "circle.dotted" : "circle"
                    )
                    .foregroundStyle(activityState == 1 ? .green : .gray)
                    .font(.lato(type: .regular, size: .subtitle))

                    UnevenRoundedRectangle(
                        topLeadingRadius: lineCornerRadius,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: lineCornerRadius
                    )
                    .fill(bottomLineFillColor)
                    .frame(width: lineWidth)
                }
                Text(activity.name)
                    .lineLimit(1)
                    .font(.lato(type: .regular, size: .subtitle))
                    .padding(.vertical, 20)

                Spacer()

                if activityState != 0 {
                    Gauge(value: Double(completedSets), in: 0...Double(totalSets)) {
                        Text("\(completedSets)/\(totalSets)")
                            .font(.lato(type: .bold, size: .body))
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(activityState == 1 ? .green : .accentColor)
                    .scaleEffect(0.7)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(activity)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .listRowInsets(.init(top: 0, leading: horizontalInsets, bottom: 0, trailing: horizontalInsets))
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func workoutToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "xmark")
            }
            .alert(
                "Cancel your lift?",
                isPresented: $showDeleteAlert
            ) {
                Button(role: .destructive) {
                    stopWorkout(false)
                } label: {
                    Text("Confirm")
                }
            } message: {
                Text("All recorded data from this current lift will be lost. This action cannot be undone.")
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                stopWorkout(true)
            } label: {
                Image(systemName: "flag.checkered")
            }
        }
    }
}

// MARK: - Helpers
extension WorkoutView {
    /// Performs the move operation when the user drags an activity from one position to another in the list.
    /// This function maintains the proper sort order of activities by updating all sortIndex values.
    /// Had a hard time understand this so Claude helped.
    /// - Parameters:
    ///   - source: The original `IndexSet` containing the indices of items to be moved.
    ///   - destination: The destination index where the items should be moved to.
    private func moveActivity(from source: IndexSet, to destination: Int) {
        // Create a mutable copy of the already sorted activities array
        // Even though this creates a new array, it contains references to the same SwiftData-managed
        // Activity objects, so modifying them here will update the actual objects in the database
        var activities = currentWorkout.sortedActivities

        // Rearrange the items in our temporary array according to the drag operation
        activities.move(fromOffsets: source, toOffset: destination)

        // Update ALL sortIndex values to match the new order
        // Since Activity objects are reference types and tracked by SwiftData,
        // changing properties here directly updates the objects in the SwiftData store,
        // regardless of how we accessed them (through sortedActivities or directly)
        for (index, activity) in activities.enumerated() {
            activity.sortIndex = index
        }

        // Save changes to ensure the updates are persisted
        try? modelContext.save()
        print("Move saved!")
    }

    /// Converts elapsed time into HH:MM:SS format
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    NavigationView {
        WorkoutView(
            workoutInProgress: .constant(true),
            stopWorkout: { saveIt in print("Stop workout called with saveIt: \(saveIt)") }, timerTick: 0,
            currentWorkout: Workout(gym: "Preview Test",
                                    activities: [
                                        Activity(
                                            sets: [
                                                SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, sortIndex: 0),
                                                SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: true, sortIndex: 1),
                                                SetData(type: .working, reps: 8, weight: 50.5, isComplete: true, sortIndex: 2),
                                                SetData(type: .working, reps: 8, weight: 50.0, isComplete: true, sortIndex: 3),
                                                SetData(type: .working, reps: 12, weight: 30.0, isComplete: true, sortIndex: 4)
                                            ],
                                            parentExercise: Exercise(name: "Bench Press"),
                                            parentWorkout: Workout(gym: "tester"), sortIndex: 0
                                        ),
                                        Activity(
                                            sets: [
                                                SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, sortIndex: 0),
                                                SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: true, sortIndex: 1),
                                                SetData(type: .working, reps: 8, weight: 50.5, isComplete: true, sortIndex: 2),
                                                SetData(type: .working, reps: 8, weight: 50.0, isComplete: true, sortIndex: 3),
                                                SetData(type: .working, reps: 12, weight: 30.0, isComplete: true, sortIndex: 4)
                                            ],
                                            parentExercise: Exercise(name: "Cable Tricep Press"),
                                            parentWorkout: Workout(gym: "tester"), sortIndex: 0
                                        ),
                                        Activity(
                                            sets: [
                                                SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, sortIndex: 0),
                                                SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: true, sortIndex: 1),
                                                SetData(type: .working, reps: 8, weight: 50.5, isComplete: false, sortIndex: 2),
                                                SetData(type: .working, reps: 8, weight: 50.0, isComplete: false, sortIndex: 3),
                                                SetData(type: .working, reps: 12, weight: 30.0, isComplete: false, sortIndex: 4)
                                            ],
                                            parentExercise: Exercise(name: "Dumbbell Press"),
                                            parentWorkout: Workout(gym: "tester"), sortIndex: 0
                                        ),
                                        Activity(
                                            sets: [],
                                            parentExercise: Exercise(name: "One Arm Tricep Extension"),
                                            parentWorkout: Workout(gym: "tester"), sortIndex: 0
                                        )
                                    ])
        )
        .environment(\.font, .lato(type: .regular))
    }
}
