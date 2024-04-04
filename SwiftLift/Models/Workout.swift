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
    var totalSets: Int
    var gym: String
    
    init(id: String = UUID().uuidString, startDate: Date, time: TimeInterval, activities: [Activity], totalWeight: Double, totalReps: Int, totalSets: Int, gym: String) {
        self.id = id
        self.startDate = startDate
        self.time = time
        self.activities = activities
        self.totalWeight = totalWeight
        self.totalReps = totalReps
        self.totalSets = totalSets
        self.gym = gym
    }
    
    static var sampleWorkout: Workout {
        Workout(startDate: Date.now - 5000000, time: Date.timeIntervalSinceReferenceDate, activities: Activity.sampleActivites, totalWeight: 2000.0, totalReps: 200, totalSets: 100, gym: "gym2")
    }
    static var sampleWorkout2: Workout {
        Workout(startDate: Date.now - 1000000, time: Date.timeIntervalSinceReferenceDate, activities: Activity.sampleActivites, totalWeight: 1000.0, totalReps: 800, totalSets: 200, gym: "gym1")
    }
    
    static var sampleWorkout3: Workout {
        Workout(startDate: Date.now - 1000, time: Date.timeIntervalSinceReferenceDate, activities: Activity.sampleActivites, totalWeight: 1500.0, totalReps: 700, totalSets: 300, gym: "gym1")
    }
    
    static func blank(selectedGym: String) -> Workout {
        Workout(startDate: .now, time: 0, activities: [], totalWeight: 0, totalReps: 0, totalSets: 0, gym: selectedGym)
    }
    
    static func randomWorkout() -> Workout {
        let startDate = Date(timeIntervalSince1970: 0)  // January 1, 1970
        let endDate = Date()  // Current date and time
        let ti = TimeInterval(arc4random_uniform(UInt32(endDate.timeIntervalSince(startDate))))
        let x = startDate.addingTimeInterval(ti)
        let gyms = ["gym1", "gym2", "gym3"]
        return Workout(startDate: x, time: TimeInterval.random(in: 60...9000), activities: Activity.randomActivities(count: Int.random(in: 2...10)), totalWeight: Double.random(in: 1000.0...40000), totalReps: Int.random(in: 100...300), totalSets: Int.random(in: 10...100), gym: gyms.randomElement() ?? "gym1")
    }
    
    static func randomWorkouts(count: Int) -> [Workout] {
        return (0..<count).map { _ in randomWorkout() }
    }
}
