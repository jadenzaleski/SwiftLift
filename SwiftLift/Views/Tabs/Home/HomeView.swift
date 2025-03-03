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

    @State private var rotationAngle: Double = 0

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        NavigationStack {
            if !workoutInProgress {
                Button {
                    workoutInProgress = true
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
            } else {
                WorkoutView(workoutInProgress: $workoutInProgress)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(previewContainer)
}
