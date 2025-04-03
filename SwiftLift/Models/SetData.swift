//
//  SetData.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/30/23.
//

import Foundation
import SwiftData

/// Represents a set of an ``Exercise`` during a ``Workout``.
/// Each set records the number of repetitions, weight lifted, and whether it is complete.
/// You can create a `SetData` instance using the ``init(reps:weight:isComplete:parentActivity:)`` initializer.
@Model
final class SetData {
    /// Enum representing the type of set.
    /// Currently, either ``warmUp`` or ``working``
    enum SetType: String, Codable {
        case warmUp
        case working
    }
    /// The type of set.
    var type: SetType

    /// The number of repetitions in the set.
    var reps: Int

    /// The weight lifted during the set.
    var weight: Double

    /// A boolean indicating if the set is completed.
    var isComplete: Bool

    /// The parent ``Activity`` of this ``SetData``.  Relationship handled in ``Activity``.
    /// This must be optional in order to allow cascade deletion.
    var parentActivity: Activity?

    /// The index of the set.
    var index: Int

    /// Initializes a new ``SetData`` instance.
    /// 
    /// - Parameters:
    ///   - type: The ``SetType`` for the set.
    ///   - reps: The number of repetitions in the set.
    ///   - weight: The weight lifted for each rep in the set.
    ///   - isComplete: A boolean indicating whether the set is complete.
    ///   - parentActivity: The ``Activity`` this set is associated with (default is `nil`).
    init(type: SetType = .working, reps: Int = 0, weight: Double = 0.0,
         isComplete: Bool = false, parentActivity: Activity? = nil, index: Int) {
        self.type = type
        self.reps = reps
        self.weight = weight
        self.isComplete = isComplete
        self.parentActivity = parentActivity
        self.index = index
    }
}
