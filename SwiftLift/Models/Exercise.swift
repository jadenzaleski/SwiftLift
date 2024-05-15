//
//  Exercise.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/3/23.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    @Attribute(.unique) var name: String
    var notes: String
    var count: Int
    var history: [Activity]? = []
    var maxWeight: Double
    var maxReps: Int
    var totalWeight: Double
    var totalReps: Int

    init(id: String = UUID().uuidString, name: String, notes: String, count: Int = 0, history: [Activity] = [], maxWeight: Double = 0.0, maxReps: Int = 0, totalWeight: Double = 0, totalReps: Int = 0) {
        self.id = id
        self.name = name
        self.notes = notes
        self.count = count
        self.history = history
        self.maxWeight = maxWeight
        self.maxReps = maxReps
        self.totalWeight = totalWeight
        self.totalReps = totalReps
    }

    static var sampleExercises: [Exercise] = [
        Exercise(name: "Bench Press", notes: "Note for bench press", count: 4, history: [Activity(name: "", gym: "")], maxWeight: 100.0, maxReps: 10, totalWeight: 2000.0, totalReps: 100),
        Exercise(name: "Back Squat", notes: "Note for back squat", count: 3, history: [Activity(name: "", gym: "")], maxWeight: 200.0, maxReps: 20, totalWeight: 3000.0, totalReps: 200)
    ]

    func update(activity: Activity) {
        self.history?.append(activity)
        self.count += 1
        activity.warmUpSets.forEach { set in
            if set.reps > self.maxReps {
                self.maxReps = set.reps
            }
            if set.weight > self.maxWeight {
                self.maxWeight = set.weight
            }
            self.totalReps += set.reps
            self.totalWeight += set.weight
        }
        activity.workingSets.forEach { set in
            if set.reps > self.maxReps {
                self.maxReps = set.reps
            }
            if set.weight > self.maxWeight {
                self.maxWeight = set.weight
            }
            self.totalReps += set.reps
            self.totalWeight += set.weight
        }
    }
}
