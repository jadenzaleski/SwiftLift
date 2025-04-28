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
    @StateObject private var appStorageManager = AppStorageManager()

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

    init() {
        print(appContainer.configurations.first?.url.path(percentEncoded: false) ?? "No URL")
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.font, .lato(type: .regular, size: .body))
                .environmentObject(appStorageManager)
        }
        .modelContainer(appContainer) // Attach SwiftData model container
    }
}
