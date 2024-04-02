//
//  SwiftLiftApp.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 7/31/23.
//

import SwiftUI
import SwiftData

@main
struct SwiftLiftApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            History.self, Exercise.self, CurrentWorkout.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
#if DEBUG
                    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
#endif
                }
        }
        .modelContainer(sharedModelContainer)
        
    }
    
}
