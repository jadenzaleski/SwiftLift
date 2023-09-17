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
            for: History.self, Exercise.self
        )
        
        container.mainContext.insert(History.sampleHistory)
        
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
