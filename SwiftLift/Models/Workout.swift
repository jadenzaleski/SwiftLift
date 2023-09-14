//
//  Workout.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation

struct Workout: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var startDate: Date
    var time: TimeInterval
    var activities: [Activity] // may not need, could be a list of exercise names/uuid
    var totalWeight: Double
    var totalReps: Int
    var gym: String
    
    init(id: String = UUID().uuidString, startDate: Date, time: TimeInterval, activities: [Activity], totalWeight: Double, totalReps: Int, gym: String) {
        self.id = id
        self.startDate = startDate
        self.time = time
        self.activities = activities
        self.totalWeight = totalWeight
        self.totalReps = totalReps
        self.gym = gym
    }
    
    static var sampleWorkout: Workout {
        Workout(startDate: Date.now, time: Date.timeIntervalSinceReferenceDate, activities: Activity.sampleActivites, totalWeight: 2000.0, totalReps: 100, gym: "gym2")
    }
}
