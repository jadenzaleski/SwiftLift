//
//  StatsView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    /// An array of exercises.
    @Query private var exercises: [Exercise]

    @State private var totalWorkouts: Int = 0
    @State private var totalTime: TimeInterval = 0
    @State private var totalWeight: Double = 0
    @State private var totalSets: Int = 0
    @State private var totalReps: Int = 0

    enum DateYValue: String, CaseIterable, Identifiable {
        case volume, reps, duration
        var id: Self { self }
        var text: String {
            get {
                switch self {
                case .duration: return "duration"
                case .reps: return "reps"
                case .volume: return "volume"
                }
            }
            // swiftlint:disable:next unused_setter_value
            nonmutating set {
                // do nothing when set becuase we only read this value
                return
            }
        }
    }

    @State private var selectedYDateValue: DateYValue = .volume
    @State private var selectedPastLength: Int = 7
    @State private var selectedGym = "All Gyms"

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Lifetime totals:")
                            .font(.lato(type: .light, size: .subtitle))
                        Divider()
                            .padding(.vertical, 3)

                        HStack {
                            Image(systemName: "number")
                                .fontWeight(.regular)
                            Text("Workouts:")
                            Text("\(exercises.count)")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "clock")
                                .fontWeight(.regular)
                            Text("Time:")
                            Text("\(formatTimeInterval(totalTime))")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "scalemass")
                                .fontWeight(.regular)
                            Text("Weight:")
                            Text("\(Int(totalWeight))")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "checklist.checked")
                                .fontWeight(.regular)
                            Text("Sets:")
                            Text("\(totalSets)")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "repeat")
                                .fontWeight(.regular)
                            Text("Reps:")
                            Text("\(totalReps)")
                                .foregroundStyle(gradient)
                        }

                    }
                    .font(.lato(type: .regular, size: .body))
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray5),
                            radius: 5, x: 0, y: 0)
                }
                .listRowInsets(EdgeInsets())
                Section {
                    VStack {
                        Picker("Y Value", selection: $selectedYDateValue) {
                            Text("Volume").tag(DateYValue.volume)
                            Text("Reps").tag(DateYValue.reps)
                            Text("Duration").tag(DateYValue.duration)
                        }
                        .pickerStyle(.segmented)
                        Picker("Y Value", selection: $selectedPastLength) {
                            Text("7").tag(7)
                            Text("30").tag(30)
                            Text("90").tag(90)
                            Text("180").tag(180)
                            Text("365").tag(365)
                            Text("All").tag(-1)
                        }
                        .padding(.top, 8.0)
                        .pickerStyle(.segmented)

                        HStack {
                            Text("\(selectedYDateValue.text.capitalized) vs. Date")
                                .font(.lato(type: .light, size: .subtitle))
                            Spacer()
                        }
                        .padding(.top, 20.0)
                        HStack {
                            if selectedPastLength == -1 {
                                Text("All workouts")
                                    .font(.lato(type: .light, size: .body))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Past \(selectedPastLength) workouts")
                                    .font(.lato(type: .light, size: .body))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        LineChart(pastDays: $selectedPastLength, yAxis: $selectedYDateValue.text)
                    }
                    .padding()
                    .background()

                }
                .listRowInsets(EdgeInsets())
            }
            .listSectionSpacing(15)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Statistics")
                        .font(.lato(type: .light, size: .toolbarTitle))
                }
            }
        }
    }

    /// Computes statistics.
    private func calculateStats() {
        totalWorkouts = exercises.count

        totalTime = exercises.reduce(0) { total, exercise in
            total + exercise.activities.reduce(0) { $0 + ($1.completionDate?.timeIntervalSince1970 ?? 0) }
        }

        totalWeight = exercises.reduce(0) { total, exercise in
            let activityWeight = exercise.activities.reduce(0) { actTotal, activity in
                let warmUpWeight = activity.warmUpSets.reduce(0) { $0 + $1.weight }
                let workingSetWeight = activity.workingSets.reduce(0) { $0 + $1.weight }
                return actTotal + warmUpWeight + workingSetWeight
            }
            return total + activityWeight
        }

        totalSets = exercises.reduce(0) { total, exercise in
            total + exercise.activities.reduce(0) { $0 + $1.warmUpSets.count + $1.workingSets.count }
        }

        totalReps = exercises.reduce(0) { total, exercise in
            let reps = exercise.activities.reduce(0) { actTotal, activity in
                let warmUpReps = activity.warmUpSets.reduce(0) { $0 + $1.reps }
                let workingSetReps = activity.workingSets.reduce(0) { $0 + $1.reps }
                return actTotal + warmUpReps + workingSetReps
            }
            return total + reps
        }
    }

    // format the times into 0h 0m
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute]
        return formatter.string(from: abs(timeInterval)) ?? "Invalid Duration"
    }

}

#Preview {
    StatsView()
        .modelContainer(previewContainer)
}
