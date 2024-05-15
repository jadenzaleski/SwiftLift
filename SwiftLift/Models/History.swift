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
    var totalSets: Int
    var totalTime: TimeInterval
    var gyms: [String]
    var joinDate: Date

    init(workouts: [Workout], totalWorkouts: Int, totalWeight: Double, totalReps: Int, totalSets: Int, totalTime: TimeInterval, gyms: [String], joinDate: Date = Date.now) {
        self.workouts = workouts
        self.totalWorkouts = totalWorkouts
        self.totalWeight = totalWeight
        self.totalReps = totalReps
        self.totalSets = totalSets
        self.totalTime = totalTime
        self.gyms = gyms
        self.joinDate = joinDate
    }

    static var sample: History {
        History(workouts: Workout.randomWorkouts(count: 1000), totalWorkouts: 1000, totalWeight: 200050.0, totalReps: 5000, totalSets: 3000, totalTime: 10000000, gyms: ["gym1", "gym2", "gym3"])
    }

    static var blank: History {
        History(workouts: [], totalWorkouts: 0, totalWeight: 0.0, totalReps: 0, totalSets: 0, totalTime: 0, gyms: ["Default"])
    }

    func addWorkout(workout: Workout) {
        self.workouts?.append(workout)
        self.totalReps += workout.totalReps
        self.totalSets += workout.totalSets
        self.totalWeight += workout.totalWeight
        self.totalWorkouts += 1
        self.totalTime += workout.time
        if !self.gyms.contains(workout.gym) {
            self.gyms.append(workout.gym)
        }
    }

    func getTimeFormattedDigits(useDays: Bool) -> String {
        let days = Int(self.totalTime / 86400)
        let remainingTime = self.totalTime - Double(days * 86400)
        let (hours, minutes, seconds) = (Int(remainingTime / 3600), Int((remainingTime / 60).truncatingRemainder(dividingBy: 60)), Int(remainingTime.truncatingRemainder(dividingBy: 60)))
        let timeFormat = useDays ? "%02d:%02d:%02d:%02d" : "%02d:%02d:%02d"
        return useDays ? String(format: timeFormat, abs(days), abs(hours), abs(minutes), abs(seconds)) : String(format: timeFormat, abs(hours + (24 * days)), abs(minutes), abs(seconds))
    }

    func getTimeFormattedLetters(useDays: Bool) -> String {

        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        if useDays {
            durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        } else {
            durationFormatter.allowedUnits = [.hour, .minute, .second]
        }
        guard let formattedDuration = durationFormatter.string(from: abs(totalTime)) else {
            return "Invalid Duration"
        }

        return formattedDuration
    }

    func addGym(gym: String) -> Bool {
        if !self.gyms.contains(gym) && gym != "" {
            self.gyms.append(gym.capitalized)
            return true
        }
        return false
    }

}
