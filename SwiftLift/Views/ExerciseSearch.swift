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
    @SceneStorage("searchText") private var searchText = ""
    @SceneStorage("newExercise") private var newExercise = ""
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
                                Image(systemName: selectedExercises.contains(exercise.name) ?
                                      "checkmark.square.fill" : "square")
                            }
                            .padding(.vertical, 10.0)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundStyle(selectedExercises.contains(exercise.name) ? Color.green : Color("ld"))

                    }
                    HStack {
                        TextField("Add a new exercise", text: $newExercise)
                            .font(.lato(type: .regular))
                        Button(action: {
                            newExercise = newExercise.capitalized
                            modelContext.insert(Exercise(name: newExercise, notes: ""))
                                // haptic feedback
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                newExercise = ""

                        }, label: {
                            Image(systemName: "plus.circle.fill")
                        })
                        .disabled(newExercise.isEmpty)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 10.0)
                } footer: {
                    Text("When adding a new exercise, each name must be unique and contain at least one character.")
                        .font(.lato(type: .light, size: .caption))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .keyboardType(.alphabet)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isPresentingExerciseSearch = false
                    } label: {
                        Text("Cancel")
                            .font(.lato(type: .regular))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Exercises")
                        .font(.lato(type: .light, size: .toolbarTitle))

                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        for name in selectedExercises {
                            currentWorkout.activities.append(Activity(name: name, gym: currentWorkout.gym))
                        }
                        isPresentingExerciseSearch = false
                    } label: {
                        Text("Add(\(selectedExercises.count))")
                            .font(.lato(type: .regular))
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
