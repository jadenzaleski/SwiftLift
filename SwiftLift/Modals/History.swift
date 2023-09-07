//
//  File.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation

class History: ObservableObject {
    @Published var workouts: [Workout]
    @Published var exercises: [Exercise]
    @Published var totalWorkouts: Int
    @Published var totalWeight: Double
    @Published var totalReps: Int
    @Published var totalTime: TimeInterval
    @Published var gyms: [String]
    
    init(workouts: [Workout], exercises: [Exercise], totalWorkouts: Int, totalWeight: Double, totalReps: Int, totalTime: TimeInterval, gyms: [String]) {
        self.workouts = workouts
        self.exercises = exercises
        self.totalWorkouts = totalWorkouts
        self.totalWeight = totalWeight
        self.totalReps = totalReps
        self.totalTime = totalTime
        self.gyms = gyms
    }
    
    static var sampleHistory: History {
        History(workouts: [Workout.sampleWorkout], exercises: Exercise.sampleExercises, totalWorkouts: 2, totalWeight: 250.0, totalReps: 500, totalTime: 1000000, gyms: ["gym1", "gym2"])
    }
    
    func notesForExercise(target: String) -> String? {
        guard let targetExercise = exercises.first(where: { $0.name == target }) else {
            return ""
        }
        return targetExercise.notes
    }
    
    func setNotesForExercise(target: String, notes: String) {
        guard let targetExerciseIndex = exercises.firstIndex(where: { $0.name == target }) else {
            // Handle the case where the exercise with the specified target doesn't exist
            return
        }
        exercises[targetExerciseIndex].notes = notes
    }
    
    func addWorkout(workout: Workout) {
        self.workouts.append(workout)
        self.totalReps += workout.totalReps
        self.totalWeight += workout.totalWeight
        self.totalWorkouts += 1
        self.totalTime += workout.time
        if !self.gyms.contains(workout.gym) {
            self.gyms.append(workout.gym)
        }
        
        workout.activities.forEach { activity in
            guard let index = exercises.firstIndex(where: { $0.name == activity.name }) else {
                // Handle the case where the exercise with the specified target doesn't exist
                print("history addWorkout() error")
                return
            }
            exercises[index].update(activity: activity)
        }
    }
    
    func getTimeFormatted(ifDays: Bool) -> String {
        let days = Int(self.totalTime / 86400)
        let remainingTime = self.totalTime - Double(days * 86400)
        let (hours, minutes, seconds) = (Int(remainingTime / 3600), Int((remainingTime / 60).truncatingRemainder(dividingBy: 60)), Int(remainingTime.truncatingRemainder(dividingBy: 60)))
        let timeFormat = ifDays ? "%02d:%02d:%02d:%02d" : "%02d:%02d:%02d"
        return ifDays ? String(format: timeFormat, abs(days), abs(hours), abs(minutes), abs(seconds)) : String(format: timeFormat, abs(hours + (24 * days)), abs(minutes), abs(seconds))
    }
    
    /// Adds an Exercise to the list of exercises only if the exercise name does not exist and is not blank. Case insensitive.
    /// - Parameter name: Name of exercise to be added.
    func addExercise(name: String) -> Bool {
        if !self.exercises.contains(where: { $0.name.localizedCaseInsensitiveContains(name) }) && name != "" {
            self.exercises.append(Exercise(name: name.capitalized, notes: ""))
            return true
        }
        return false
    }
    
    func addGym(gym: String) -> Bool {
        if !self.gyms.contains(gym) && gym != "" {
            self.gyms.append(gym.capitalized)
            return true
        }
        return false
    }
    
    func getExerciseCount(name: String) -> Int {
        let exercise = exercises.first { $0.name.localizedCaseInsensitiveContains(name) }
        return exercise!.count
    }

}


