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
        var searchResults: [Exercise] {
            if searchText.isEmpty {
                return exercises.map { $0 }
            } else {
                return exercises.map { $0 }.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        NavigationView {
            List {
                Section {
                    ForEach(searchResults, id: \.self) { exercise in
                        Button {
                            if selectedExercises.contains(exercise.name) {
                                selectedExercises = selectedExercises.filter { $0 != exercise.name }
                            } else {
                                selectedExercises.append(exercise.name)
                            }
                            // haptic feedback
                            UISelectionFeedbackGenerator().selectionChanged()
                        } label: {
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                Text("\(exercise.count)")
                                Image(systemName: selectedExercises.contains(exercise.name) ? "checkmark.square.fill" : "square")
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundStyle(selectedExercises.contains(exercise.name) ? Color.green : Color("ld"))
                        
                    }
                    HStack {
                        TextField("Add a new exercise", text: $newExercise)
                        Button(action: {
                            newExercise = newExercise.capitalized
                            modelContext.insert(Exercise(name: newExercise, notes: ""))
                                // haptic feedback
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                newExercise = ""
                            
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newExercise.isEmpty)
                        .buttonStyle(BorderlessButtonStyle())                    }
                } footer: {
                    Text("When adding a new exercise, each name must be unique and contain at least one character.")
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
}
#Preview {
    ExerciseSearch(currentWorkout: .constant(Workout.sampleWorkout), isPresentingExerciseSearch: .constant(true))
        .modelContainer(previewContainer)
}
