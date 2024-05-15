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
        print("[+] Current workout saved.")
    }

    func clear() {
        self.workout = Workout.blank(selectedGym: "")
        print("[+] Current workout cleared.")
    }

    static var blank: CurrentWorkout {
        CurrentWorkout(workout: Workout(startDate: .now, time: 0, activities: [], totalWeight: 0.0, totalReps: 0, totalSets: 0, gym: "Default"))
    }

}
