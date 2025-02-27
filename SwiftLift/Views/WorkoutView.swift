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

    @Query private var exercises: [Exercise]

    @Binding var currentWorkout: Workout
    @Binding var workoutInProgress: Bool
    @Binding var selectedGym: String

    @State private var showDeleteAlert = false
    @State private var isDeleting: Bool = false

    @SceneStorage("isPresentingExerciseSearch") private var isPresentingExerciseSearch: Bool = false

    @State var time = TimeInterval()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "timer")
                    Text("\(formatTimeInterval(time))")
                        .onReceive(timer) { _ in
                            time = abs(currentWorkout.startDate.timeIntervalSinceNow)
                        }

                    Spacer()

                    Text(selectedGym)
                        .lineLimit(1)
                    Image(systemName: "mappin.circle")
                }
                .font(.lato(type: .light, size: .heading))
                .padding(.vertical)
                Spacer()
                HStack {
                    Text("\(currentWorkout.activities.count) Exercises:")
                    Spacer()
                    Button {
                        withAnimation(.interactiveSpring) {
                            isDeleting.toggle()
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(isDeleting ? .red : .blue)
                    }
                }
                .font(.lato(type: .light, size: .heading))
                .padding(.bottom, 10.0)

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
                .padding(.vertical, 5)

                Button {
                    isPresentingExerciseSearch.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add exercise")
                    }
                    .font(.lato(type: .regular, size: .subtitle))
                    .padding(10.0)
                }
            }
            .padding(.horizontal)
            }
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

        .sheet(isPresented: $isPresentingExerciseSearch) {
            ExerciseSearch(currentWorkout: $currentWorkout, isPresentingExerciseSearch: $isPresentingExerciseSearch)
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
        // Ensure workout duration is updated
        currentWorkout.duration = time

        // Filter activities to retain only those with checked sets
        currentWorkout.activities = currentWorkout.activities.compactMap { activity in
            let checkedWarmUpSets = activity.warmUpSets.filter { $0.isComplete && $0.reps > 0 && $0.weight > 0 }
            let checkedWorkingSets = activity.workingSets.filter { $0.isComplete && $0.reps > 0 && $0.weight > 0 }

            if !checkedWarmUpSets.isEmpty || !checkedWorkingSets.isEmpty {
                var filteredActivity = activity
                filteredActivity.warmUpSets = checkedWarmUpSets
                filteredActivity.workingSets = checkedWorkingSets
                return filteredActivity
            }
            return nil
        }

        for activity in currentWorkout.activities {
            // Update exercise stats if applicable
            if let exercise = exercises.first(where: { $0.name == activity.name }) {
                exercise.activities.append(activity)
            }
        }

        currentWorkout.gym = selectedGym

        // Add currentWorkout to SwiftData storage
        modelContext.insert(currentWorkout)

        // Save the changes to persist data
        try? modelContext.save()

        // Reset state
        workoutInProgress = false

        // Haptic feedback for success
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

}


#Preview {
    WorkoutView(
        currentWorkout: .constant(Workout(startDate: .now, duration: 3600, gym: "Sample Gym")),
        workoutInProgress: .constant(true),
        selectedGym: .constant("Default")
    )
    .modelContainer(previewContainer)
}
