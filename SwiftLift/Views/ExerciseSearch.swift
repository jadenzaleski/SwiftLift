//
//  ExerciseSearch.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 9/2/23.
//

import SwiftUI

struct ExerciseSearch: View {
    @EnvironmentObject var history: History
    @Binding var currentWorkout: Workout
    @Binding var isPresentingExerciseSearch: Bool
    @State private var searchText = ""
    @State private var newExercise = ""
    @State private var selectedExercises: [String] = []
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(searchResults, id: \.self) { exerciseName in
                        Button {
                            if selectedExercises.contains(exerciseName) {
                                selectedExercises = selectedExercises.filter { $0 != exerciseName }
                            } else {
                                selectedExercises.append(exerciseName)
                            }
                            // haptic feedback
                            UISelectionFeedbackGenerator().selectionChanged()
                        } label: {
                            HStack {
                                Text(exerciseName)
                                Spacer()
                                Text("\(history.getExerciseCount(name: exerciseName))")
                                Image(systemName: selectedExercises.contains(exerciseName) ? "checkmark.square.fill" :"square")
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundStyle(selectedExercises.contains(exerciseName) ? Color.green : Color("ld"))
                        
                    }
                    HStack {
                        TextField("Add a new exercise", text: $newExercise)
                        Button(action: {
                            if history.addExercise(name: newExercise) {
                                // haptic feedback
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                newExercise = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newExercise.isEmpty)
                    }
                } footer: {
                    Text("When adding a new exercise, each name must be unique and not empty.")
                }
            }
            .navigationTitle("Exercises")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .keyboardType(.alphabet)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresentingExerciseSearch = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add(\(selectedExercises.count))") {
                        for name in selectedExercises {
                            currentWorkout.activities.append(Activity(name: name, gym: currentWorkout.gym))
                        }
                        isPresentingExerciseSearch = false
                    }
                }
            }
        }
    }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return history.exercises.map { $0.name }
        } else {
            return history.exercises.map { $0.name }.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
struct ExerciseSearch_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSearch(currentWorkout: .constant(Workout.sampleWorkout), isPresentingExerciseSearch: .constant(true))
            .environmentObject(History.sampleHistory)
    }
}
