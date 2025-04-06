//
//  WorkoutView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI
import Combine

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

    private let lineRadius: CGFloat = 2
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
        let sortedActivities = currentWorkout.activities.sorted(by: { $0.index < $1.index })
        ForEach(Array(sortedActivities.enumerated()), id: \.1.id) { index, activity in
            rowItem(activity: $currentWorkout.activities[index], index: index)
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
    /// - Important: The ``index`` parameter is not the same as ``Activity.index``
    @ViewBuilder
    private func rowItem(activity: Binding<Activity>, index: Int) -> some View {
        let completedSets = activity.wrappedValue.sets.count(where: \.isComplete)
        let totalSets = activity.wrappedValue.sets.count
        let activityState: Int = {
            // Sets are either empty, complete, or in progress
            if activity.wrappedValue.sets.isEmpty {
                return 0 // Nothing in this activity
            } else if activity.wrappedValue.isComplete {
                return 1 // Completed
            } else {
                return 2 // In progress
            }
        }()

            NavigationLink(destination: ActivityView(activity: activity)) {
                HStack(alignment: .center, spacing: horizontalInsets) {
                    VStack {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: lineRadius,
                            bottomTrailingRadius: lineRadius,
                            topTrailingRadius: 0
                        )
                        .fill(index == 0 ? Color.clear : Color.gray)
                        .frame(width: lineWidth)

                        Image(systemName:
                                activityState == 1 ? "checkmark.circle.fill" :
                                activityState == 0 ? "circle" : "exclamationmark.circle"
                        )
                        .foregroundStyle(activityState == 1 ? .green :
                                            activityState == 0 ? Color.ld : .yellow)
                        .font(.lato(type: .regular, size: .subtitle))

                        UnevenRoundedRectangle(
                            topLeadingRadius: lineRadius,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: lineRadius
                        )
                        .fill(index == currentWorkout.activities.count - 1 ? Color.clear : Color.gray)
                        .frame(width: lineWidth)
                    }
                    Text(activity.wrappedValue.name)
                        .font(.lato(type: .regular, size: .subtitle))
                        .padding(.vertical, 20)

                    Spacer()

                    if activityState != 0 {
                        Gauge(value: Double(completedSets), in: 0...Double(totalSets)) {
                            Text("\(completedSets)/\(totalSets)")
                                .font(.lato(type: .bold, size: .body))
                        }
                        .padding(.trailing, horizontalInsets)
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(.accentColor)
                        .scaleEffect(0.7)
                    }
                }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(activity.wrappedValue)
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
    /// Preforms the move when the user drags the activity from one spot to another in the list.
    /// - Parameters:
    ///   - source: Original ``IndexSet`` to be moved.
    ///   - destination: The destionation of the moved item.
    private func moveActivity(from source: IndexSet, to destination: Int) {
        // First move the items in the array
        currentWorkout.activities.move(fromOffsets: source, toOffset: destination)

        // reorder the indices
        var counter = 0
        for activity in currentWorkout.activities {
            activity.index = counter
            counter += 1
        }
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
                                                SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, index: 0),
                                                SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: true, index: 1),
                                                SetData(type: .working, reps: 8, weight: 50.5, isComplete: true, index: 2),
                                                SetData(type: .working, reps: 8, weight: 50.0, isComplete: true, index: 3),
                                                SetData(type: .working, reps: 12, weight: 30.0, isComplete: true, index: 4)
                                            ],
                                            parentExercise: Exercise(name: "Bench Press"),
                                            parentWorkout: Workout(gym: "tester"), index: 0
                                        ),
                                        Activity(
                                            sets: [
                                                SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, index: 0),
                                                SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: false, index: 1),
                                                SetData(type: .working, reps: 8, weight: 50.5, isComplete: false, index: 2),
                                                SetData(type: .working, reps: 8, weight: 50.0, isComplete: false, index: 3),
                                                SetData(type: .working, reps: 12, weight: 30.0, isComplete: false, index: 4)
                                            ],
                                            parentExercise: Exercise(name: "Cable Tricep Press"),
                                            parentWorkout: Workout(gym: "tester"), index: 0
                                        ),
                                        Activity(
                                            sets: [
                                                SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, index: 0),
                                                SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: true, index: 1),
                                                SetData(type: .working, reps: 8, weight: 50.5, isComplete: false, index: 2),
                                                SetData(type: .working, reps: 8, weight: 50.0, isComplete: false, index: 3),
                                                SetData(type: .working, reps: 12, weight: 30.0, isComplete: false, index: 4)
                                            ],
                                            parentExercise: Exercise(name: "Dumbbell Press"),
                                            parentWorkout: Workout(gym: "tester"), index: 0
                                        ),
                                        Activity(
                                            sets: [],
                                            parentExercise: Exercise(name: "One Arm Tricep Extension"),
                                            parentWorkout: Workout(gym: "tester"), index: 0
                                        )
                                    ])
        )
        .environment(\.font, .lato(type: .regular))
    }
}
