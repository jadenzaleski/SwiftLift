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
    @State private var color = Color.accentColor
    @AppStorage("selectedTheme") private var selectedTheme = "Automatic"
    @AppStorage("bold") private var bold = false
    @AppStorage("metric") private var metric = false

    let themes = ["Automatic", "Light", "Dark"]
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ComingSoon()
                    } label: {
                        Text("Export/restore data")
                    }
                    Toggle(isOn: $metric) {
                        Text("Metric")
                    }
                } header: {
                    Text("General")
                        .font(.lato(type: .regular, size: .caption))
                }

                Section {
                    Picker("Appearance", selection: $selectedTheme) {
                        ForEach(themes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle(isOn: $bold) {
                        Text("Bold Text")
                    }
                    ColorPicker("Accent Color", selection: $color)

                } header: {
                    Text("Appearance")
                        .font(.lato(type: .regular, size: .caption))
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
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                        })
                        .disabled(newGym.isEmpty)
                    }
                } header: {
                    Text("Gyms")
                        .font(.lato(type: .regular, size: .caption))
                } footer: {
                    Text("Swipe left on a gym to delete it. There must be at least one gym in the list at all times.")
                        .font(.lato(type: .light, size: .caption))

                }

                Section {

                    NavigationLink {
                        ComingSoon()
                    } label: {
                        Text("Write a review")
                    }
                    NavigationLink {
                        ComingSoon()
                    } label: {
                        Text("Leave a rating")
                    }
                    NavigationLink {
                        ComingSoon()
                    } label: {
                        Text("Report a bug")
                    }
                } header: {
                    Text("Feedback")
                        .font(.lato(type: .regular, size: .caption))
                }

                Section {
                    Text("Version: \(appVersion ?? "-")")
                    Text("Build: \(buildNumber ?? "-")")
                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Image("github")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Contribute")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right") // Arrow indicator
                                .font(.custom("", size: 13))
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }

                } header: {
                    Text("About")
                } footer: {
                    // The below text needs to be in one string to allow for
                    // swift to recognize markdown.
                    // swiftlint:disable:next line_length
                    Text("Main icon by [SolarIcons](https://www.figma.com/community/file/1166831539721848736?ref=svgrepo.com) in CC Attribution License via [SVG Repo](https://www.svgrepo.com/).")
                    .font(.lato(type: .light, size: .caption))

                }
            }
            .font(.lato(type: .regular, size: .body))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.lato(type: .light, size: .toolbarTitle))
                }
                ToolbarItemGroup(placement: .keyboard) {
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
