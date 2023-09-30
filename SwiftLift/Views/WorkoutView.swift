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
    @Binding var currentWorkout: Workout
    @Binding var workoutInProgress: Bool
    @Binding var selectedGym: String
    @State private var showDeleteAlert = false
    @State var isDeleting: Bool = false
    @State var isPresentingExerciseSearch: Bool = false
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
                            .onReceive(timer) { input in
                                time = currentWorkout.startDate.timeIntervalSinceNow
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
                    
                    ForEach(Array(currentWorkout.activities.enumerated()), id: \.element.id) { index, activity in
                        HStack {
                            WorkoutPill(activity: $currentWorkout.activities[index])
                                .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)
                            if isDeleting {
                                Button(action: {
                                    currentWorkout.activities.remove(at: index)
                                    // haptic feedback
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }) {
                                    Image(systemName: "trash")
                                        .font(.title2)
                                        .foregroundStyle(Color.red)
                                }
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
                        Button() {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Cancel your lift?"),
                                message: Text("All recorded data will be lost. This action cannot be undone. "),
                                primaryButton: .default(Text("Cancel")),
                                secondaryButton: .destructive(Text("Confirm"), action: {
                                    workoutInProgress = false
                                })
                            )
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button() {
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
    
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d:%02d", abs(hours), abs(minutes), abs(seconds))
    }
    
    private func stopWorkout() {
        currentWorkout.time = time
        currentWorkout.activities.removeAll { activity in
            let allSets = activity.warmUpSets + activity.workingSets
            return !allSets.isEmpty && !allSets.contains { $0.isChecked }
            //            return !allSets.isEmpty && allSets.allSatisfy { $0.isChecked }
        }
        currentWorkout.totalReps += currentWorkout.activities
            .flatMap { $0.warmUpSets + $0.workingSets }
            .map { $0.reps }
            .reduce(0, +)
        currentWorkout.totalWeight += currentWorkout.activities
            .flatMap { $0.warmUpSets + $0.workingSets }
            .map { $0.weight }
            .reduce(0, +)
        currentWorkout.gym = selectedGym
        history[0].addWorkout(workout: currentWorkout)
        workoutInProgress = false
        // haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

//#Preview {
//    WorkoutView(currentWorkout: .constant(Workout.sampleWorkout), workoutInProgress: .constant(true), selectedGym: .constant("Default"))
//        .modelContainer(for: [History.self, Exercise.self], inMemory: true)
//
//}
