//
//  SwiftLiftApp.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 7/31/23.
//

import SwiftUI

@main
struct SwiftLiftApp: App {
    @StateObject var history = History(workouts: [], exercises: [], totalWorkouts: 0, totalWeight: 0, totalReps: 0, totalTime: 0, gyms: ["Default"])
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(history)
        }
    }
    
}
