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
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
    @State var workoutInProgress = false
    @State private var selectedGym = ""
    @State private var newGymAlert = false
    @State var newGym = ""
    @State var currentWorkout = Workout(startDate: .now, time: 0, activities: [], totalWeight: 0, totalReps: 0, gym: "")
    @State private var showLifetime = true
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        NavigationStack {
            if !workoutInProgress {
                VStack {
                    HStack {
                        Button {
                            withAnimation() {
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
                    if (showLifetime) {
                        VStack {
                            HStack {
                                Image(systemName: "number")
                                Text("\(history[0].totalWorkouts)")
                                Spacer()
                                Text("\(history[0].getTimeFormatted(ifDays: true))")
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
                        .transition(.asymmetric(insertion: .offset(x: 0, y: -25).combined(with: .opacity), removal: .offset(x: 0, y: -25).combined(with: .opacity)))
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
                    }
                    Spacer()
                    List {
                        Picker("Gym", selection: $selectedGym) {
                            ForEach(history[0].gyms, id: \.self) { gym in
                                Text("\(gym)")
                            }
                        }
                        .listRowBackground(Color.lg)
                        HStack {
                            TextField("Add a new gym", text: $newGym)
                            Button(action: {
                                if history[0].addGym(gym: newGym) {
                                    selectedGym = newGym
                                    newGym = ""
                                    // haptic feedback
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }
                                                               
                            }) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newGym.isEmpty)
                        }
                        .listRowBackground(Color.lg)
                    }
                    .frame(height: 150)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: Tester()) {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
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
            } else {
                WorkoutView(currentWorkout: $currentWorkout, workoutInProgress: $workoutInProgress, selectedGym: $selectedGym)
            }
        }
    }
    
    private func startWorkout() {
        if selectedGym == "" {
            selectedGym = history[0].gyms[0]
        }
        currentWorkout = Workout(startDate: .now, time: 0, activities: [], totalWeight: 0, totalReps: 0, gym: selectedGym)
        workoutInProgress = true;
    }
}

#Preview {
    HomeView()
}
