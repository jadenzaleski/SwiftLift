//
//  SwiftLiftApp.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 7/31/23.
//

import SwiftUI
import SwiftData

@main
@MainActor
struct SwiftLiftApp: App {
    let appContainer: ModelContainer = {
        // all the models we want to store will be in this schema
        let schema = Schema([History.self, Exercise.self, CurrentWorkout.self])
        
        do {
            // create the container
            let container = try ModelContainer(for: schema)
            
            // test to see if the persistant store is empty for History
            var historyFD = FetchDescriptor<History>()
            historyFD.fetchLimit = 1
            
            // test to see if the persistant store is empty for History
            var currentWorkoutFD = FetchDescriptor<CurrentWorkout>()
            currentWorkoutFD.fetchLimit = 1
            
            // check to see if there is an entry in each
            let historyNotFound = try container.mainContext.fetch(historyFD).count == 0
            let currentWorkoutNotFound = try container.mainContext.fetch(currentWorkoutFD).count == 0
            // if both are found return the container
            guard historyNotFound || currentWorkoutNotFound else {
                print("[+] History and CurrentWorkout models found.")
                return container
            }
            // The below code will only run if the persistent store does not have both.
            if (historyNotFound) {
                print("[+] History model not found in persistant store. Creating it...")
                container.mainContext.insert(History.blank)
                // for testing random data:
//                container.mainContext.insert(History.sample)
                print("[+] History model created.")
            }
            
            if (currentWorkoutNotFound) {
                print("[+] CurrentWorkout model not found in persistant store. Creating it...")
                container.mainContext.insert(CurrentWorkout.blank)
                print("[+] CurrentWorkout model created.")
            }
            
            return container
        } catch {
            fatalError("[+] Could not create ModelContainer: \(error)")
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
        .modelContainer(appContainer)
        
    }
    
}

/*

import SwiftUI
import SwiftData

@main
@MainActor
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
    
    if (history.isEmpty) {
        print("[+] First time running app, creating empty history.")
        modelContext.insert(History(workouts: [], totalWorkouts: 0, totalWeight: 0.0, totalReps: 0, totalSets: 0, totalTime: 0, gyms: ["Default"]))
        //                modelContext.insert(History.sample)
        
    }
    if (cw.isEmpty) {
        print("[+] No current workout save, creating inital index")
        modelContext.insert(CurrentWorkout(workout: Workout(startDate: .now, time: 0, activities: [], totalWeight: 0.0, totalReps: 0, totalSets: 0, gym: "Default")))
    }
    
    
    
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
*/
