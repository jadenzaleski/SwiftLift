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
/// You can create an instance of `Activity` using the initializer
/// ``init(completionDate:sets:parentExercise:parentWorkout:)``.
@Model
final class Activity {
    /// All of the sets for this ``Activity``.
    @Relationship(deleteRule: .cascade, inverse: \SetData.parentActivity)
    var sets: [SetData]

    /// The parent ``Exercise`` of this ``Activity``. Relationship handled in ``Exercise``
    /// This must be optional in order to allow cascade deletion.
    var parentExercise: Exercise?

    /// The parent ``Workout`` of this ``Activity``. Relationship handled in ``Workout``
    /// This must be optional in order to allow cascade deletion.
    var parentWorkout: Workout?

    /// The Index of the ``Activity``.
    var index: Int

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
    init(sets: [SetData] = [],
         parentExercise: Exercise,
         parentWorkout: Workout,
         index: Int) {
        self.sets = sets
        self.parentExercise = parentExercise
        self.parentWorkout = parentWorkout
        self.index = index
    }
}

// MARK: - Computed Properties
extension Activity {
    /// All the warm up sets in this ``Activity``
    @Transient
    var warmUpSets: [SetData] {
        sets.filter { $0.type == .warmUp }
    }

    /// All the working sets in this ``Activity``
    @Transient
    var workingSets: [SetData] {
        sets.filter { $0.type == .working }
    }

    /// Calculate wether or not this activity is complete.
    /// Completion is determined by the wether or not all ``sets`` are complete.
    var isComplete: Bool {
        sets.allSatisfy(\.isComplete)
    }
    /// Name of the ``Activity``.
    var name: String {
        parentExercise?.name ?? ""
    }

    /// The date at which the ``Activity`` was completed. This is pulled from the parent ``Workout`` ``endDate``.
    var completionDate: Date? {
        parentWorkout?.endDate
    }
}
