//
//  TabView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI
import UIKit
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var history: [History]
    /// Adds custom font and background to TabView
    init() {
        UITabBar.appearance().backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "OpenSans-Regular", size: 12)! ], for: .normal)
    }
    var body: some View {
        
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("Home")
                }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Stats")
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
        }
        .onAppear(perform: {
            if (history.isEmpty) {
                print("first time running app, creating empty history.")
                modelContext.insert(History(workouts: [], totalWorkouts: 0, totalWeight: 0.0, totalReps: 0, totalTime: 0, gyms: ["Default"]))
            }
        })
        
    }
}

#Preview {
    MainTabView()
        .modelContainer(previewContainer)

}
