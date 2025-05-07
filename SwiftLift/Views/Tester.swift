//
//  Tester.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/28/23.
//

import SwiftUI
import UIKit
import SwiftData

struct Tester: View {
    @State var index = 0
    @State var num = 0.0
    @FocusState private var focusedField: UUID?
    @Environment(\.modelContext) var modelContext
    @Query private var exercises: [Exercise]
    @Query private var activites: [Activity]
    @Query private var sets: [SetData]
    @Query private var workouts: [Workout]

    @State private var testDataCount = 100

    var body: some View {
        ScrollView {
            Button("Tap") {
                index += 1
                print("[+] Running Tester: \(index)")
                focusedField = nil

                switch index {
                case 1:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)

                case 2:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                case 3:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)

                case 4:
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()

                case 5:
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                case 6:
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()

                case 7:
                    let generator = UIImpactFeedbackGenerator(style: .rigid)
                    generator.impactOccurred()

                case 8:
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()

                default:
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    index = 0
                }
            }

            TextField("TesterField", value: $num, formatter: decimalFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: UUID())
                .padding()
            Text("My num: \(num)")

            VStack {
                Slider(value: Binding(
                    get: { Double(testDataCount) },
                    set: { testDataCount = Int($0) }
                ), in: 1...1000, step: 1)
                Text("Number of Test Items: \(testDataCount)")
            }
            .padding()

            Button("Create Test Data") {
                print("Creating Test Data...")
                createTestData()
            }
            .buttonStyle(.borderedProminent)

            Button("Clear ALL Test Data") {
                print("Clearing Test Data...")
                do {
                    try modelContext.delete(model: Exercise.self)
                    try modelContext.delete(model: Workout.self)
                } catch {
                    fatalError(error.localizedDescription)
                }

            }
            .buttonStyle(.bordered)

            Text("Workouts: \(workouts.count)")
            Text("Exercises: \(exercises.count)")
            Text("Activties: \(activites.count)")
            Text("sets: \(sets.count)")
        }
    }

    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0   // Allow whole numbers without decimal places
        formatter.maximumFractionDigits = 2   // Allow up to two decimal places
        formatter.alwaysShowsDecimalSeparator = false // No forced decimal unless needed
        return formatter
    }()

    // swiftlint:disable identifier_name
    private func createTestData() {
        let notes: [String] = ["This is a note", "Another note", "Yet another note"]

        let exerciseCount = max(1, testDataCount / 4)
        var exerciseNames = Set<String>()
        for index in 0..<exerciseCount {
            var name: String
            repeat {
                name = "Exercise-\(UUID().uuidString.prefix(12))"
            } while exerciseNames.contains(name)
            exerciseNames.insert(name)

            let exercise = Exercise(name: name, notes: notes.randomElement() ?? "notes")
            modelContext.insert(exercise)
        }

        try? modelContext.save()

        let gyms: [String] = ["Gym", "Gym 2", "Gym 3", "Gym 4", "Gym 5"]

        for _ in 0..<testDataCount {
            let start = Date.random()
            let end = start.addingTimeInterval(TimeInterval.random(in: 3600...28800))
            let workout = Workout(startDate: start, endDate: end, gym: gyms.randomElement() ?? "Gym")
            for j in 0...Int.random(in: 1...10) {
                let activity = Activity(parentExercise: exercises.randomElement()!, parentWorkout: workout, sortIndex: j)
                for k in 0...Int.random(in: 1...15) {
                    let rb = Bool.random()
                    let weight = round(Double.random(in: 10.0...300.0) * 100) / 100.0
                    let set = SetData(type: rb ? .warmUp : .working,
                                      reps: Int.random(in: 1...10),
                                      weight: weight,
                                      isComplete: true,
                                      parentActivity: activity,
                                      sortIndex: k)
                    activity.sets.append(set)
                }
                workout.activities.append(activity)
            }

            modelContext.insert(workout)
        }

        try? modelContext.save()
    }
}

extension Date {
    static func random() -> Date {
        let randomTime = TimeInterval(Int32.random(in: 0...Int32.max))
        return Date(timeIntervalSince1970: randomTime)
    }
}

#Preview {
    Tester()
        .modelContainer(previewContainer)
}
