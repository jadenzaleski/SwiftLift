//
//  CurrentWorkout.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/1/24.
//

import Foundation
import SwiftData

@Model
class CurrentWorkout {
    var id: String = UUID().uuidString
    var workout: Workout
    
    init(id: String = UUID().uuidString, workout: Workout) {
        self.workout = workout
    }
    
    func save(workout: Workout) {
        self.workout = workout
        print("⌾ Current workout saved.")
    }

}

