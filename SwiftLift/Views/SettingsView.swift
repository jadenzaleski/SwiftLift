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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    @State private var newGym = ""
    
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("settings to come...")
                    Text("Change accent color?")
                    Text("Light/Dark/System color?")
                    Text("Backup/restore data?")
                    
                } header: {
                    Text("General")
                }
                
                Section {
                    ForEach(history[0].gyms, id: \.self) { gym in
                        Text(gym)
                    }
                    .onDelete(perform: { indexSet in
                        history[0].gyms.remove(atOffsets: indexSet)
                    })
                    .deleteDisabled(history[0].gyms.count <= 1)
                    
                    HStack {
                        TextField("Add a new gym", text: $newGym)
                        
                        Button(action: {
                            addNewGym()
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newGym.isEmpty)
                    }
                } header: {
                    Text("Gyms")
                } footer: {
                    Text("Swipe left on a gym to delete it. There must be at least one gym in the list at all times.")
                }
                
                Section {
                    
                    NavigationLink {
                        Tester()
                    } label: {
                        Text("Write a review")
                    }
                    NavigationLink {
                        Tester()
                    } label: {
                        Text("Leave a rating")
                    }
                    NavigationLink {
                        Tester()
                    } label: {
                        Text("Report a bug")
                    }
                } header: {
                    Text("Feedback")
                }
                
                Section {
                    Text("Version: \(appVersion ?? "-")")
                    Text("Build: \(buildNumber ?? "-")")
                } header: {
                    Text("About")
                } footer: {
                    Text("Main icon by [Solar Icons](https://www.figma.com/community/file/1166831539721848736?ref=svgrepo.com) in CC Attribution License via [SVG Repo](https://www.svgrepo.com/).")
                }
            }
            .navigationTitle("Settings")
            .toolbar{
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button {
                        UIApplication.shared.dismissKeyboard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .padding(.all, 5.0)
                }
            }
        }
    }
    
    private func addNewGym() {
        if !history[0].gyms.isEmpty && !history[0].gyms.contains(newGym) {
            withAnimation {
                history[0].gyms.append(newGym.capitalized)
                self.hideKeyboard()
            }
            newGym = ""
            // haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
    }
}

#Preview {
    SettingsView()
        .modelContainer(previewContainer)
}
