//
//  SwiftDataPreviewContainer.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 9/14/23.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Workout.self, Exercise.self
        )

        let sampleWorkout = Workout(completionDate: .now, duration: 10000, gym: "Sample Gym")
        container.mainContext.insert(sampleWorkout)

        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
