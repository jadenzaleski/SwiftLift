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
    var startDate: Date?
    /// The end date of this ``Workout``.
    var endDate: Date?
    /// The gym at which this ``Workout`` takes place.
    var gym: String

    /// All the activities that take place in this ``Workout``.
    @Relationship(deleteRule: .cascade, inverse: \Activity.parentWorkout)
    var activities: [Activity]

    /// Initializes a new ``Workout`` instance.
    ///
    /// - Parameters:
    ///   - startDate: The date when the workout started.
    ///   - endDate: The date when the workout ended.
    ///   - gym: The name of the gym where the workout took place.
    ///   - activities: A list of `Activity` objects associated with this workout. Defaults to an empty array.
    init(startDate: Date? = .now, endDate: Date? = nil, gym: String, activities: [Activity] = []) {
        self.startDate = startDate
        self.endDate = endDate
        self.gym = gym
        self.activities = activities
    }
}

// MARK: - Computed Properties
extension Workout {
    /// The total number of sets completed in this ``Workout``. Includes warm-up and working sets.
    var totalSets: Int {
        activities.reduce(0) { total, activity in
            total + activity.warmUpSets.count + activity.workingSets.count
        }
    }

    /// The total number of reps completed in this ``Workout``. Includes warm-up and working sets.
    var totalReps: Int {
        activities.reduce(0) { total, activity in
            total + activity.warmUpSets.reduce(0) { $0 + $1.reps }
            + activity.workingSets.reduce(0) { $0 + $1.reps }
        }
    }

    /// The total weight lifted in this ``Workout``. Includes warm-up and working sets.
    var totalWeight: Double {
        activities.reduce(0) { total, activity in
            total + activity.warmUpSets.reduce(0) { $0 + $1.weight }
            + activity.workingSets.reduce(0) { $0 + $1.weight }
        }
    }

    /// The duration of this ``Workout``.
    var duration: TimeInterval {
        abs(startDate?.timeIntervalSince(endDate ?? .now) ?? 0)
    }

    var sortedActivities: [Activity] {
        activities.sorted(by: { $0.sortIndex < $1.sortIndex })
    }
}
