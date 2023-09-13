//
//  ExerciseSearch.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 9/2/23.
//

import SwiftUI
import SwiftData

struct ExerciseSearch: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
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
                                Text("\(exerciseName)")
                                Image(systemName: selectedExercises.contains(exerciseName) ? "checkmark.square.fill" :"square")
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundStyle(selectedExercises.contains(exerciseName) ? Color.green : Color("ld"))
                        
                    }
                    HStack {
                        TextField("Add a new exercise", text: $newExercise)
                        Button(action: {
                            modelContext.insert(Exercise(name: newExercise, notes: ""))
                                // haptic feedback
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                newExercise = ""
                            
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
            return exercises.map { $0.name }
        } else {
            return exercises.map { $0.name }.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
#Preview {
    ExerciseSearch(currentWorkout: .constant(Workout.sampleWorkout), isPresentingExerciseSearch: .constant(true))
}
