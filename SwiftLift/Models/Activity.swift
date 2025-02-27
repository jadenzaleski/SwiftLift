//
//  Activity.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation
import SwiftData

/// Represents an activity performed during a ``Workout``, including details such as the activity's name, gym, completed date,
/// and the sets associated with the activity. This class also holds relationships to ``Exercise`` and ``Workout`` instances.
/// You can create an instance of `Activity` using the initializer ``init(name:gym:completedDate:warmUpSets:workingSets:parentExercise:parentWorkout:)``.
@Model
final class Activity {
    /// The name of the ``Activity``.
    var name: String
    /// The name of the gym where the ``Activity`` takes place.
    var gym: String
    /// The date at which the ``Activity`` was completed
    var completedDate: Date?

    /// All of the warm-up sets for this ``Activity``.
    @Relationship(deleteRule: .cascade, inverse: \SetData.parentActivity)
    var warmUpSets: [SetData]

    /// All of the working sets for this ``Activity``.
    @Relationship(deleteRule: .cascade, inverse: \SetData.parentActivity)
    var workingSets: [SetData]

    /// The parent ``Exercise`` of this ``Activity``. Relationship handled in ``Exercise``
    var parentExercise: Exercise?

    /// The parent ``Workout`` of this ``Activity``. Relationship handled in ``Workout``
    var parentWorkout: Workout?

    /// Initializes a new ``Activity`` instance.
    ///
    /// - Parameters:
    ///   - name: The name of the activity (e.g., "Squat", "Bench Press").
    ///   - gym: The name of the gym where the activity was performed.
    ///   - completedDate: The date and time when the activity was completed.
    ///   - warmUpSets: An array of ``SetData`` representing warm-up sets associated with the activity. Defaults to an empty array.
    ///   - workingSets: An array of ``SetData`` representing working sets associated with the activity. Defaults to an empty array.
    ///   - parentExercise: An optional reference to the `Exercise` this activity belongs to. Defaults to nil.
    ///   - parentWorkout: An optional reference to the `Workout` this activity is part of. Defaults to nil.
    init(name: String, gym: String, completedDate: Date? = nil,
         warmUpSets: [SetData] = [], workingSets: [SetData] = [],
         parentExercise: Exercise? = nil, parentWorkout: Workout? = nil) {
        self.name = name
        self.gym = gym
        self.completedDate = completedDate
        self.warmUpSets = warmUpSets
        self.workingSets = workingSets
        self.parentExercise = parentExercise
        self.parentWorkout = parentWorkout
    }
}
