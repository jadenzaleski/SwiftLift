//
//  HomeView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 7/31/23.
//

import SwiftUI
import UIKit
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]

    @SceneStorage("workoutInProgress") private var workoutInProgress = false
    @SceneStorage("selectedGym") private var selectedGym = "Default"
    @SceneStorage("newGym") private var newGym = ""
    @SceneStorage("showLifetime") private var showLifetime = true

    @State private var currentWorkout: Workout?
    @State private var showAlert = false
    /// Time since the workout has started.
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        NavigationStack {
            if !workoutInProgress {
                Button {
                    startWorkout()
                } label: {
                    VStack {
                        HStack {
                            Image(systemName: "figure.strengthtraining.functional")
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .font(.title)
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.title)
                            Image(systemName: "figure.highintensity.intervaltraining")
                                .font(.title)
                        }
                        Text("Start a Workout")
                            .font(.lato(type: .black, size: .medium))
                    }
                    .padding(25.0)
                    .foregroundStyle(Color("mainSystemColor"))
                    .background(gradient)
                    .clipShape(Capsule())
                }
                .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray5) : .secondary, radius: 20)
            } else if let workout = currentWorkout {
                WorkoutView(workoutInProgress: $workoutInProgress,
                            elapsedTime: elapsedTime,
                            stopWorkout: stopWorkout,
                            currentWorkout: workout)
            }
        }
        .onAppear {
            restoreWorkout()
        }
        .alert("Workout Restored", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your previous workout has been restored.")
        }
    }

    // MARK: - Helpers

    /// Starts a workout session.
    /// If an existing workout is already in progress, it sets the ``workoutInProgress`` flag to `true`.
    /// Otherwise, it creates a new ``Workout`` instance, inserts it into the model context, and starts a new workout session.
    private func startWorkout() {
        // Logging to indicate the workout has started
        print("Started Workout!")
        // Check if there is already a workout in progress
        if currentWorkout != nil {
            // If a workout is already ongoing, just mark it as in progress
            workoutInProgress = true
        } else {
            // If no workout is in progress, create a new workout
            let newWorkout = Workout(gym: selectedGym) // Create a new workout for the selected gym
            modelContext.insert(newWorkout) // Insert the new workout into the model context (database)
            try? modelContext.save()
            // Set the newly created workout as the current workout
            currentWorkout = newWorkout
            // Mark the workout as in progress
            workoutInProgress = true
            startTimer()
        }
        // Trigger a haptic feedback to indicate the workout has started successfully
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Restores an ongoing workout if available
    private func restoreWorkout() {
        if let ongoingWorkout = workouts.first(where: { $0.completionDate == nil }) {
            print("Workout has been restored!")
            currentWorkout = ongoingWorkout
            workoutInProgress = true
            showAlert = true  // Show alert when a workout is restored
        } else {
            workoutInProgress = false
            currentWorkout = nil
        }
    }

    /// Starts the timer and updates elapsed time every second
    private func startTimer() {
        timer?.invalidate() // Ensure previous timer is stopped
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
            currentWorkout?.duration = elapsedTime
            print("duration: ", currentWorkout?.duration ?? "error")
        }
    }

    /// Stops the timer when the view disappears
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Stops the current workout
    private func stopWorkout(saveIt: Bool) {
        if let workout = currentWorkout {
            stopTimer()
            if saveIt {
                // We need to go through and remove any sets that are not completed, or 0s
                for activity in workout.activities {
                    for set in activity.sets {
                        if set.reps == 0 || set.weight == 0 || !set.isComplete {
                            if let setToDelete = activity.sets.first(where: { $0 === set }) {
                                modelContext.delete(setToDelete)
                                activity.sets.removeAll { $0 === set }
                                print("Deleted set:", set, "because it was incomplete or empty.")
                            }
                        }
                    }

                    // Now remove any activites that have no completed sets in them
                    if activity.sets.isEmpty {
                        if let activityToDelete = workout.activities.first(where: { $0 === activity }) {
                            modelContext.delete(activityToDelete)
                            workout.activities.removeAll { $0 === activity }
                            print("Deleted activity:", activity,
                                  "because it had no completed sets.")
                        }
                    }
                }

                print("Workout has been stopped and saved!")
                workout.completionDate = .now
                try? modelContext.save()  // Persist changes
            } else {
                print("Workout has been stopped and deleted!")
                modelContext.delete(workout)  // Remove from SwiftData
                try? modelContext.save()  // Persist deletion
            }
        }
        workoutInProgress = false
        currentWorkout = nil
    }
}

#Preview {
    HomeView()
        .modelContainer(previewContainer)
}
