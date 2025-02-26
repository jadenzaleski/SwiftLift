//
//  SwiftLiftApp.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 7/31/23.
// Green: #5bb275
// Purple: #604bb2

import SwiftUI
import SwiftData

@main
@MainActor
struct SwiftLiftApp: App {
    let appContainer: ModelContainer = {
        // Define schema with the current models
        let schema = Schema([
            Exercise.self,
            Activity.self,
            SetData.self,
            Workout.self
        ])

        do {
            // Create the container
            let container = try ModelContainer(for: schema)
            return container
        } catch {
            fatalError("[!] Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(appContainer) // Attach SwiftData model container
    }
}
