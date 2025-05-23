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
    @SceneStorage("selectedTab") private var selectedTab = 0
    // Adds custom font and background to TabView
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("offset"))
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.init(name: "OpenSans-Regular", size: 12)! ], for: .normal)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("Home")
                        .font(.lato(type: .regular, size: .caption))
                }
                .tag(0)

            StatsView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Stats")
                        .font(.lato(type: .regular, size: .caption))

                }
                .tag(1)
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                        .font(.lato(type: .regular, size: .caption))

                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                        .font(.lato(type: .regular, size: .caption))

                }
                .tag(3)
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
