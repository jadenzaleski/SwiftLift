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
    @Query private var exercises: [Exercise]
    @Binding var currentWorkout: Workout
    @Binding var isPresentingExerciseSearch: Bool
    @SceneStorage("searchText") private var searchText = ""
    @SceneStorage("newExercise") private var newExercise = ""
    @State private var selectedExercises: Set<String> = []

    private var searchResults: [Exercise] {
        searchText.isEmpty ? exercises : exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    // Extracted Exercise Row
                    ForEach(searchResults, id: \.self) { exercise in
                        exerciseRow(for: exercise)
                    }

                    // Extracted Add Exercise Section
                    addExerciseSection
                } footer: {
                    footerText
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .keyboardType(.alphabet)
            .toolbar {
                toolbarContent
            }
        }
    }

    private func exerciseRow(for exercise: Exercise) -> some View {
        Button {
            toggleSelection(for: exercise.name)
        } label: {
            HStack {
                Text(exercise.name)
                Spacer()
                // FIXME: Somehow Query all uses
//                Text("\(exercise.count)")
                Image(systemName: selectedExercises.contains(exercise.name) ? "checkmark.square.fill" : "square")
            }
            .padding(.vertical, 10.0)
        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundStyle(selectedExercises.contains(exercise.name) ? Color.green : Color("ld"))
    }

    private var addExerciseSection: some View {
        HStack {
            TextField("Add a new exercise", text: $newExercise)
                .font(.lato(type: .regular))
            Button {
                addNewExercise()
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(newExercise.isEmpty)
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 10.0)
    }

    private var footerText: some View {
        Text("When adding a new exercise, each name must be unique and contain at least one character.")
            .font(.lato(type: .light, size: .caption))
    }

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    isPresentingExerciseSearch = false
                } label: {
                    Text("Cancel").font(.lato(type: .regular))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Exercises").font(.lato(type: .light, size: .toolbarTitle))
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    addSelectedExercisesToWorkout()
                } label: {
                    Text("Add (\(selectedExercises.count))").font(.lato(type: .regular))
                }
            }
        }
    }

    // MARK: - Functions

    private func toggleSelection(for exerciseName: String) {
        if selectedExercises.contains(exerciseName) {
            selectedExercises.remove(exerciseName)
        } else {
            selectedExercises.insert(exerciseName)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func addNewExercise() {
        let trimmedName = newExercise.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !exercises.contains(where: { $0.name == trimmedName }) else { return }

        let newExerciseObj = Exercise(name: trimmedName, notes: "")
        modelContext.insert(newExerciseObj)

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        newExercise = ""
    }

    private func addSelectedExercisesToWorkout() {
        for name in selectedExercises {
            let newActivity = Activity(name: name, gym: currentWorkout.gym, parentWorkout: currentWorkout)
            currentWorkout.activities.append(newActivity)
            print("appended \(name)")
        }
        isPresentingExerciseSearch = false
    }
}

#Preview {
    ExerciseSearch(
        currentWorkout: .constant(Workout(gym: "Sample Gym")),
        isPresentingExerciseSearch: .constant(true)
    )
    .modelContainer(previewContainer)
}
