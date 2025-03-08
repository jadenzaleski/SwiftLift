//
//  Activity.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation
import SwiftData
import SwiftUI

/// Represents an activity performed during a ``Workout``, including details such as the activity's name, gym, completed date,
/// and the sets associated with the activity. This class also holds relationships to ``Exercise`` and ``Workout`` instances.
/// You can create an instance of `Activity` using the initializer ``init(name:gym:completionDate:warmUpSets:workingSets:parentExercise:parentWorkout:)``.
@Model
final class Activity {
    /// The date at which the ``Activity`` was completed
    var completionDate: Date?

    /// All of the warm-up sets for this ``Activity``.
    @Relationship(deleteRule: .cascade, inverse: \SetData.parentActivity)
    var warmUpSets: [SetData]

    /// All of the working sets for this ``Activity``.
    @Relationship(deleteRule: .cascade, inverse: \SetData.parentActivity)
    var workingSets: [SetData]

    /// The parent ``Exercise`` of this ``Activity``. Relationship handled in ``Exercise``
    /// This must be optional in order to allow cascade deletion.
    var parentExercise: Exercise?

    /// The parent ``Workout`` of this ``Activity``. Relationship handled in ``Workout``
    /// This must be optional in order to allow cascade deletion.
    var parentWorkout: Workout?

    /// Initializes a new ``Activity`` instance.
    ///
    /// - Parameters:
    ///   - completionDate: The date and time when the activity was completed.
    ///   - warmUpSets: An array of ``SetData`` representing warm-up sets associated with the activity.
    ///   Defaults to an empty array.
    ///   - workingSets: An array of ``SetData`` representing working sets associated with the activity.
    ///   Defaults to an empty array.
    ///   - parentExercise: An reference to the `Exercise` this activity belongs to.
    ///   - parentWorkout: An reference to the `Workout` this activity is part of.
    init(completionDate: Date? = nil,
         warmUpSets: [SetData] = [], workingSets: [SetData] = [],
         parentExercise: Exercise, parentWorkout: Workout) {
        self.completionDate = completionDate
        self.warmUpSets = warmUpSets
        self.workingSets = workingSets
        self.parentExercise = parentExercise
        self.parentWorkout = parentWorkout
    }
}

// MARK: - Computed Properties
extension Activity {
    /// Calculate wether or not this activity is complete.
    /// Completion is determined by the wether or not all ``warmUpSets`` and ``workingSets`` are complete
    var isComplete: Bool {
        warmUpSets.allSatisfy(\.isComplete) && workingSets.allSatisfy(\.isComplete)
    }

    var name: String {
        return parentExercise?.name ?? ""
    }
}
