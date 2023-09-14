//
//  SettingsView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 9/3/23.
//
import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    
    var body: some View {
        List {
            Section {
                Text("settings to come...")
                Text("Change accent color?")

            } header: {
                Text("General")
            } footer: {
                Text("Main icon by [Solar Icons](https://www.figma.com/community/file/1166831539721848736?ref=svgrepo.com) in CC Attribution License via [SVG Repo](https://www.svgrepo.com/).\n\nVersion: \(appVersion ?? "-") (\(buildNumber ?? "-"))")
                
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
