//
//  HomeView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 7/31/23.
//

import SwiftUI
import UIKit
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
    @Query private var currentWorkoutSave: [CurrentWorkout]
    @SceneStorage("workoutInProgress") private var workoutInProgress = false
    @SceneStorage("selectedGym") private var selectedGym = "Default"
    @SceneStorage("newGym") private var newGym = ""
    @State private var currentWorkout = Workout(startDate: .now, time: 0, activities: [],
                                                totalWeight: 0, totalReps: 0, totalSets: 0, gym: "")
    @SceneStorage("showLifetime") private var showLifetime = true
    @State private var rotationAngle: Double = 0
    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        NavigationStack {
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                showLifetime.toggle()
                            }
                        } label: {
                            Text("Lifetime")
                                .font(.headline)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.left")
                                .rotationEffect(.degrees(showLifetime ? -90 : 0))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    if showLifetime {
                        VStack {
                            HStack {
                                Image(systemName: "number")
                                Text("\(history[0].totalWorkouts)")
                                Spacer()
                                Text("\(history[0].getTimeFormattedLetters(useDays: true))")
                                Image(systemName: "clock")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 3.0)
                            HStack {
                                Image(systemName: "repeat")
                                Text("\(history[0].totalReps)")
                                Spacer()
                                Text("\(Int(history[0].totalWeight))")
                                Image(systemName: "scalemass")
                            }
                            .padding(.horizontal)
                        }
                        .transition(.asymmetric(insertion: .offset(x: 0, y: -25).combined(with: .opacity),
                                                removal: .offset(x: 0, y: -25).combined(with: .opacity)))
                    }

                    Spacer()
                    Button {
                        startWorkout()
                        // haptic feedback
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        VStack {
                            HStack {
                                Image(systemName: "figure.strengthtraining.functional")
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    .font(.title)
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.title)
                                Image(systemName: "figure.highintensity.intervaltraining")
                                    .font(.title)

                            }
                            Text("Start a Workout")
                                .fontWeight(Font.Weight.bold)
                        }
                        .padding(25.0)
                        .foregroundStyle(Color("mainSystemColor"))
                        .background(gradient)
                        .clipShape(Capsule())
                    }
                    .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray5) : .secondary, radius: 20)

                    Spacer()

                    HStack {
                        Text("Gym:")
                            .padding(10.0)
                        Spacer()
                        Picker("Select a gym", selection: $selectedGym) {
                            ForEach(history[0].gyms, id: \.self) { gym in
                                Text(gym).tag(gym)
                            }
                        }
                        .padding(10.0)
                        .onAppear {
                            if !history[0].gyms.contains(selectedGym) {
                                selectedGym = history[0].gyms.first ?? "Default"
                            }
                        }
                    }
                    .background(Color("offset"))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                    .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)

                }
                .onTapGesture {
                    self.hideKeyboard()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.crop.circle")
                        }

                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .navigationDestination(isPresented: $workoutInProgress) {
                    WorkoutView(currentWorkout: $currentWorkout,
                                workoutInProgress: $workoutInProgress, selectedGym: $selectedGym)
                        .navigationBarBackButtonHidden()

                }
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: scenePhase) {
            if workoutInProgress {
                if scenePhase == .inactive {
                    print("[+] SwiftLift inactive")
                } else if scenePhase == .active {
                    print("[+] SwiftLift active")
                    // update the State
                    currentWorkout = currentWorkoutSave[0].workout
                    print("[+] Updated currentWorkout @State")
                } else if scenePhase == .background {
                    print("[+] SwiftLift now in background")
                }
            }
        }
        .onChange(of: currentWorkout) {
            currentWorkoutSave[0].save(workout: currentWorkout)
        }
    }

    private func startWorkout() {
        currentWorkout = Workout.blank(selectedGym: selectedGym)
        workoutInProgress = true
    }
}

private extension UIScrollView {
    override open var clipsToBounds: Bool {
        get { false }
        set {}
    }
}

#Preview {
    HomeView()
        .modelContainer(previewContainer)
}
