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

    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]

    @SceneStorage("workoutInProgress") private var workoutInProgress = false
    @SceneStorage("selectedGym") private var selectedGym = "Default"
    @SceneStorage("newGym") private var newGym = ""
    @SceneStorage("showLifetime") private var showLifetime = true

    @State private var currentWorkout = Workout(startDate: .now, duration: 0, gym: "", activities: [])
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
                                .font(.lato(type: .bold, size: .medium))
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
                                Text("\(workouts.count)")
                                    .font(.lato(type: .regular, size: .body))
                                Spacer()
                                // FIXME: get sum of time worked out.
                                Text("\(workouts.first?.startDate.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
                                    .font(.lato(type: .regular, size: .body))
                                Image(systemName: "clock")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 3.0)

                            HStack {
                                Image(systemName: "repeat")
                                Text("\(workouts.reduce(0) { $0 + $1.totalReps })")
                                    .font(.lato(type: .regular, size: .body))

                                Spacer()
                                Text("\(Int(workouts.reduce(0) { $0 + $1.totalWeight }))")
                                    .font(.lato(type: .regular, size: .body))
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
                                .font(.lato(type: .black, size: .medium))

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
                            .font(.lato(type: .regular, size: .medium))

                        Spacer()
                        Picker("Select a gym", selection: $selectedGym) {
                            ForEach(Array(Set(workouts.map { $0.gym })), id: \.self) { gym in
                                Text(gym)
                                    .font(.lato(type: .regular, size: .medium))
                                    .tag(gym)
                            }
                        }

                        .padding(10.0)
                        .onAppear {
                            let availableGyms = Set(workouts.map { $0.gym })
                            if !availableGyms.contains(selectedGym) {
                                selectedGym = availableGyms.first ?? "Default"
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
                        NavigationLink(destination: ProfileView().withCustomBackButton()) {
                            Image(systemName: "person.crop.circle")
                        }

                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView().withCustomBackButton()
) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .navigationDestination(isPresented: $workoutInProgress) {
                    WorkoutView(currentWorkout: $currentWorkout,
                                workoutInProgress: $workoutInProgress,
                                selectedGym: $selectedGym
                    )
                    .navigationBarBackButtonHidden()

                }
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: scenePhase) { newPhase in
            if workoutInProgress {
                switch newPhase {
                case .inactive:
                    print("[+] SwiftLift inactive")
                case .active:
                    print("[+] SwiftLift active")
                case .background:
                    print("[+] SwiftLift now in background")
                default:
                    break
                }
            }
        }
        .onChange(of: currentWorkout) {
            // TODO: Handle persistence if needed
        }
    }

    private func startWorkout() {
        currentWorkout = Workout(startDate: .now, duration: 0, gym: selectedGym, activities: [])
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
