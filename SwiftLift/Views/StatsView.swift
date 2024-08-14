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
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
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
                            Text("\(history[0].totalWorkouts)")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "clock")
                                .fontWeight(.regular)
                            Text("Time:")
                            Text("\(formatTimeInterval(history[0].totalTime))")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "scalemass")
                                .fontWeight(.regular)
                            Text("Weight:")
                            Text("\(Int(history[0].totalWeight))")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "checklist.checked")
                                .fontWeight(.regular)
                            Text("Sets:")
                            Text("\(history[0].totalSets)")
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "repeat")
                                .fontWeight(.regular)
                            Text("Reps:")
                            Text("\(history[0].totalReps)")
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

    // format the times into 0h 0m
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.day, .hour, .minute]

        guard let formattedDuration = durationFormatter.string(from: abs(timeInterval)) else {
            return "Invalid Duration"
        }
        return formattedDuration
    }

}

#Preview {
    StatsView()
        .modelContainer(previewContainer)
}
