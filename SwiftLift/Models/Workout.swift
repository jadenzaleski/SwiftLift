//
//  Workout.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation
import SwiftData

/// Represents a workout session, including its start date, duration, gym, and associated activities.
/// You can create an instance of `Workout` using the initializer ``init(startDate:duration:gym:activities:)``.
@Model
final class Workout {
    /// The start date of this ``Workout``.
    var startDate: Date
    /// The duration of this ``Workout``.
    var duration: TimeInterval
    /// The gym at which this ``Workout`` takes place.
    var gym: String

    /// All the activities that take place in this ``Workout``.
    @Relationship(deleteRule: .cascade, inverse: \Activity.parentWorkout)
    var activities: [Activity]

    /// Initializes a new ``Workout`` instance.
    ///
    /// - Parameters:
    ///   - startDate: The date when the workout started.
    ///   - duration: The total duration of the workout in seconds.
    ///   - gym: The name of the gym where the workout took place.
    ///   - activities: A list of `Activity` objects associated with this workout. Defaults to an empty array.
    init(startDate: Date, duration: TimeInterval, gym: String, activities: [Activity] = []) {
        self.startDate = startDate
        self.duration = duration
        self.gym = gym
        self.activities = activities
    }
}
