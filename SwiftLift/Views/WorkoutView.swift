//
//  WorkoutView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/20/23.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var history: [History]
    @Query private var currentWorkoutSave: [CurrentWorkout]
    @Binding var currentWorkout: Workout
    @Binding var workoutInProgress: Bool
    @Binding var selectedGym: String
    @State private var showDeleteAlert = false
    @State private var isDeleting: Bool = false
    @SceneStorage("isPresentingExerciseSearch") private var isPresentingExerciseSearch: Bool = false
    @State var time = TimeInterval()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.title2)
                        Text("\(formatTimeInterval(time))")
                            .font(.title2)
                            .onReceive(timer) { _ in
                                time = abs(currentWorkout.startDate.timeIntervalSinceNow)
                            }

                        Spacer()

                        Text(selectedGym)
                            .font(.title2)
                            .lineLimit(1)
                        Image(systemName: "mappin.circle")
                            .font(.title2)
                    }
                    .padding()
                    Spacer()
                    HStack {
                        Text("\(currentWorkout.activities.count) Exercises:")
                            .font(.title)
                        Spacer()
                        Button {
                            withAnimation(.interactiveSpring) {
                                isDeleting.toggle()
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(isDeleting ? .red : .blue)
                                .font(.title)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5.0)

                    ForEach(Array(currentWorkout.activities.enumerated()), id: \.element.id) { index, _ in
                        HStack {
                            WorkoutPill(activity: $currentWorkout.activities[index])
                                .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4),
                                        radius: 5)
                            if isDeleting {
                                Button(action: {
                                    currentWorkout.activities.remove(at: index)
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
                    }
                    .padding(.vertical, 5.0)

                    Button {
                        isPresentingExerciseSearch.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title2)
                            Text("Add exercise")
                                .font(.title2)
                        }
                        .padding(10.0)
                    }
                }
                .padding(.horizontal)
                .toolbar {
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
                                workoutInProgress = false
                            } label: {
                                Text("Confirm")
                            }
                        } message: {
                            Text("All recorded data will be lost. This action cannot be undone.")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            stopWorkout()
                        } label: {
                            Image(systemName: "flag.checkered")
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentingExerciseSearch) {
                ExerciseSearch(currentWorkout: $currentWorkout, isPresentingExerciseSearch: $isPresentingExerciseSearch)
            }
        }
    }

    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute, .second]

        guard let formattedDuration = durationFormatter.string(from: abs(timeInterval)) else {
            return "Invalid Duration"
        }

        return formattedDuration
    }

    private func stopWorkout() {
        // Update current workout time
        currentWorkout.time = time
        // Filter activities to get only those with checked sets
        currentWorkout.activities = currentWorkout.activities.compactMap { activity in
            // Filter sets within the activity to include only checked sets with non-zero reps and weight
            let checkedWarmUpSets = activity.warmUpSets.filter { $0.isChecked && $0.reps > 0 && $0.weight > 0 }
            let checkedWorkingSets = activity.workingSets.filter { $0.isChecked && $0.reps > 0 && $0.weight > 0 }
            // Check if there are any checked sets in either warm-up or working sets
            if !checkedWarmUpSets.isEmpty || !checkedWorkingSets.isEmpty {
                // Replace activity with filtered sets
                var filteredActivity = activity
                filteredActivity.warmUpSets = checkedWarmUpSets
                filteredActivity.workingSets = checkedWorkingSets
                return filteredActivity
            } else {
                // Exclude activity if no sets are checked or all have zero reps or weight
                return nil
            }
        }
        // Calculate totals based on checked sets with non-zero reps and weight
        var totalReps = 0
        var totalSets = 0
        var totalWeight = 0.0
        // Iterate through filtered activities and their sets
        for activity in currentWorkout.activities {
            for set in activity.warmUpSets + activity.workingSets {
                // Include set in totals
                totalReps += set.reps
                totalSets += 1
                totalWeight += Double(set.weight) * Double(set.reps)
            }
        }
        // Assign calculated totals to currentWorkout
        currentWorkout.totalReps = totalReps
        currentWorkout.totalSets = totalSets
        currentWorkout.totalWeight = totalWeight
        // Set selected gym to current workout
        currentWorkout.gym = selectedGym
        // Add current workout to history
        history[0].addWorkout(workout: currentWorkout)
        // Reset workout in progress flag
        workoutInProgress = false
        // Provide haptic feedback for success
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

}

#Preview {
    WorkoutView(currentWorkout: .constant(Workout.sampleWorkout),
                workoutInProgress: .constant(true), selectedGym: .constant("Default"))
    .modelContainer(for: [History.self, Exercise.self], inMemory: true)

}
