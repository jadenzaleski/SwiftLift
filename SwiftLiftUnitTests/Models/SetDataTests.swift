//
//  SetDataTests.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 3/14/25.
//

import Testing
import Foundation

@testable import SwiftLift

@Suite struct SetDataTests {
    @Test func setDataInitialization() throws {
        let now = Date()
        let set = SetData(type: .warmUp, reps: 10, weight: 25.0, isComplete: false, parentActivity: nil, created: now)
        #expect(set.type == .warmUp)
        #expect(set.reps == 10)
        #expect(set.weight == 25.0)
        #expect(set.isComplete == false)
        #expect(set.parentActivity == nil)
        #expect(set.created == now)
    }
}
