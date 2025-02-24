//
//  Exercise.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/3/23.
//

import Foundation
import SwiftData

/// Represents an exercise performed by the user, such as "Bench Press" or "Squat".
/// You can create an instance of `Exercise` using ``init(name:notes:activities:)``.
/// - Important: Deleting an `Exercise` does **not** delete the activities (``Activity``) associatied with it.
@Model
final class Exercise {
    /// The name of the ``Exercise`` (e.g., "Bench Press").
    var name: String
    /// Additional notes about the ``Exercise`` (optional).
    /// You can use this field to store any additional information or instructions.
    var notes: String?

    /// The list of activities (``Activity``)  associated with this ``Exercise``.
    /// Each activity represents a specific instance of the exercise performed during a workout.
    @Relationship(deleteRule: .nullify, inverse: \Activity.parentExercise)
    var activities: [Activity]

    /// Initializes a new ``Exercise`` instance.
    ///
    /// - Parameters:
    ///   - name: The name of the exercise (e.g., "Bench Press").
    ///   - notes: Optional additional notes about the exercise.
    ///   - activities: Optional list of activities related to this exercise. Defaults to an empty list.
    init(name: String, notes: String? = nil, activities: [Activity] = []) {
        self.name = name
        self.notes = notes
        self.activities = activities
    }
}

