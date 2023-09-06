//
//  TabView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject var history: History
    //    let lgLeading = LinearGradient(colors: [.purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
    //    let lgTrailing = LinearGradient(colors: [.purple, .blue, .green], startPoint: .topTrailing, endPoint: .bottomLeading)
    //    let lg = LinearGradient(colors: [.purple, .blue, .green, .blue, .purple], startPoint: .leading, endPoint: .trailing)
    
    /// Adds custom font and background to TabView
    init() {
        UITabBar.appearance().backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "OpenSans-Regular", size: 12)! ], for: .normal)
    }
    var body: some View {
        
        TabView {
            HomeView()
                .environmentObject(history)
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("Home")
                }
            StatsView()
                .environmentObject(history)
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Stats")
                }
            HistoryView()
                .environmentObject(history)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
        }
        
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(History.sampleHistory)
    }
}
