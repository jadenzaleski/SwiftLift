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
    // Adds custom font and background to TabView
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("offset"))
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "OpenSans-Regular", size: 12)! ], for: .normal)
    }
    var body: some View {
        
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("Home")
                        
                }
                .tag(0)
            StatsView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Stats")
                }
                .tag(1)
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)
        }
//        .toolbar{
//            ToolbarItemGroup(placement: .keyboard){
//                Spacer()
//                Button {
//                        UIApplication.shared.dismissKeyboard()
//                } label: {
//                    Image(systemName: "keyboard.chevron.compact.down")
//                }
//                .padding(.all, 5.0)
//            }
//        }
        .onAppear(perform: {
            if (history.isEmpty) {
                print("first time running app, creating empty history.")
                modelContext.insert(History(workouts: [], totalWorkouts: 0, totalWeight: 0.0, totalReps: 0, totalTime: 0, gyms: ["Default"]))
            }
        })
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        UIApplication.shared.dismissKeyboard()

    }
}
#endif

#Preview {
    MainTabView()
        .modelContainer(previewContainer)

}
