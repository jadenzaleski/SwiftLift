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
    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var appStorageManager: AppStorageManager

    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]

    @AppStorage("selectedGym") private var selectedGym = "Default"

    @SceneStorage("workoutInProgress") private var workoutInProgress = false
    @SceneStorage("newGym") private var newGym = ""
    @SceneStorage("showLifetime") private var showLifetime = true

    @State private var currentWorkout: Workout?
    @State private var showAlert = false
    @State private var timer: Timer?
    @State private var timerTick = 0
    @State private var animateGradient = false
    @State private var hasRestoredWorkout = false

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        NavigationStack {
            if !workoutInProgress {
                header()
                    .padding(.horizontal)
                Spacer()
                Button {
                    startWorkout()
                } label: {
                    button()
                }
                Spacer()
                footer()
                    .padding([.leading, .bottom, .trailing])
            } else if let workout = currentWorkout {
                WorkoutView(workoutInProgress: $workoutInProgress,
                            stopWorkout: stopWorkout,
                            timerTick: timerTick,
                            currentWorkout: workout)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active, !hasRestoredWorkout {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                    restoreWorkout()
                    hasRestoredWorkout = true
                }
            }
        }
        .alert("Workout Restored", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                startTimer()
            }
        } message: {
            Text("Your previous workout has been restored.")
        }
    }

    @ViewBuilder
    private func header() -> some View {
        HStack {
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle")
            }

            Spacer()

#if targetEnvironment(simulator)
            NavigationLink(destination: Tester()) {
                Image(systemName: "hammer.fill")
            }
#endif
        }
        .font(.lato(type: .regular, size: .heading))
    }

    @ViewBuilder
    private func footer() -> some View {
        HStack {
            Text("Gym:")
            Spacer()
            Picker("Gym:", selection: $selectedGym) {
                ForEach(appStorageManager.gyms, id: \.self) { gym in
                    Text(gym)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(10)
        .background(Color("offset"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .font(.lato(type: .regular, size: .medium))
    }

    @ViewBuilder
    private func button() -> some View {
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
        .foregroundStyle(Color.mainSystem)
        .padding(.horizontal, 45.0)
        .padding(.vertical, 20.0)
        .background(gradient)
        .clipShape(Capsule())
        .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : .secondary, radius: 10, x: 0, y: 10)
    }
}

// MARK: - Helpers
extension HomeView {
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
        }
        startTimer()
        // Trigger a haptic feedback to indicate the workout has started successfully
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Restores an ongoing workout if available
    private func restoreWorkout() {
        print("restore workout has been called!")
        if let ongoingWorkout = workouts.first(where: { $0.endDate == nil }) {
            print("Workout has been restored!")
            currentWorkout = ongoingWorkout
            showAlert = true  // Show alert when a workout is restored
            workoutInProgress = true
            // Start the timer in the Button
        } else {
            workoutInProgress = false
            currentWorkout = nil
        }
    }

    /// Starts the timer and updates elapsed time every second
    private func startTimer() {
        timer?.invalidate() // Ensure previous timer is stopped
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerTick += 1 // Trigger SwiftUI updates
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
                workout.endDate = .now
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
        .environmentObject(AppStorageManager())
}
