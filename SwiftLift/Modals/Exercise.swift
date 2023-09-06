//
//  Exercise.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/3/23.
//

import Foundation

struct Exercise: Identifiable {
    var id: UUID
    var name: String
    var notes: String
    var count: Int
    var history: [Activity]
    var maxWeight: Double
    var maxReps: Int
    var totalWeight: Double
    var totalReps: Int
    
    init(id: UUID = UUID(), name: String, notes: String, count: Int = 0, history: [Activity] = [], maxWeight: Double = 0.0, maxReps: Int = 0, totalWeight: Double = 0, totalReps: Int = 0) {
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
}
