//
//  File.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation
import SwiftData

@Model
final class History {
    var workouts: [Workout]? = []
    var totalWorkouts: Int
    var totalWeight: Double
    var totalReps: Int
    var totalTime: TimeInterval
    var gyms: [String]
    var joinDate: Date
    
    init(workouts: [Workout], totalWorkouts: Int, totalWeight: Double, totalReps: Int, totalTime: TimeInterval, gyms: [String], joinDate: Date = Date.now) {
        self.workouts = workouts
        self.totalWorkouts = totalWorkouts
        self.totalWeight = totalWeight
        self.totalReps = totalReps
        self.totalTime = totalTime
        self.gyms = gyms
        self.joinDate = joinDate
    }
    
    static var sampleHistory: History {
        History(workouts: [Workout.sampleWorkout], totalWorkouts: 2, totalWeight: 250.0, totalReps: 500, totalTime: 1000000, gyms: ["gym1", "gym2"])
    }
    
    func addWorkout(workout: Workout) {
        self.workouts?.append(workout)
        self.totalReps += workout.totalReps
        self.totalWeight += workout.totalWeight
        self.totalWorkouts += 1
        self.totalTime += workout.time
        if !self.gyms.contains(workout.gym) {
            self.gyms.append(workout.gym)
        }
    }
    
    func getTimeFormatted(ifDays: Bool) -> String {
        let days = Int(self.totalTime / 86400)
        let remainingTime = self.totalTime - Double(days * 86400)
        let (hours, minutes, seconds) = (Int(remainingTime / 3600), Int((remainingTime / 60).truncatingRemainder(dividingBy: 60)), Int(remainingTime.truncatingRemainder(dividingBy: 60)))
        let timeFormat = ifDays ? "%02d:%02d:%02d:%02d" : "%02d:%02d:%02d"
        return ifDays ? String(format: timeFormat, abs(days), abs(hours), abs(minutes), abs(seconds)) : String(format: timeFormat, abs(hours + (24 * days)), abs(minutes), abs(seconds))
    }
    
    func addGym(gym: String) -> Bool {
        if !self.gyms.contains(gym) && gym != "" {
            self.gyms.append(gym.capitalized)
            return true
        }
        return false
    }

}


