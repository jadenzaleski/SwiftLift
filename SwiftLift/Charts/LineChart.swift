//
//  VolumeVsDate.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 1/14/24.
//

import SwiftUI
import SwiftData
import Charts

struct PlottingData: Identifiable {
    var id = UUID()
    var yAxis: Double
    var date: Date
    var xAxis: Int

    init(id: UUID = UUID(), xAxis: Int, yAxis: Double, date: Date) {
        self.id = id
        self.yAxis = yAxis
        self.date = date
        self.xAxis = xAxis
    }
}

struct LineChart: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color.accentColor.opacity(0.4),
        Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)
    @Binding var pastDays: Int
    @Binding var yAxis: String

    var body: some View {
        let his = history[0]
        // num is the number of workouts to display. min of input and count of workouts
        let num = pastDays == -1 ? his.workouts!.count : min(pastDays, his.workouts?.count ?? 0)
        // let dates = h.workouts?.prefix(n).compactMap { $0.startDate } ?? []
        // sort the workouts so the most recent is on top i think
        let orderedWorkouts = his.workouts!.sorted { (workout1, workout2) in
            return workout1.startDate < workout2.startDate
        }

        let selectedWorkouts = orderedWorkouts.suffix(num)
        // data to plot, change based on passed in yAxis value
        let data: [PlottingData] = selectedWorkouts.enumerated().map { index, workout in
            var possibleY = 0.0
            if yAxis == "duration" {
                possibleY = Double(workout.time)
            } else if yAxis == "volume" {
                possibleY = workout.totalWeight
            } else {
                possibleY = Double(workout.totalReps)
            }
            return PlottingData(xAxis: Int(index), yAxis: possibleY, date: workout.startDate)
        }

        let maxX = data.max(by: { $0.xAxis < $1.xAxis })?.xAxis ?? 0
        let maxY = data.max(by: { $0.yAxis < $1.yAxis })?.yAxis ?? 0
        let minY = data.min(by: { $0.yAxis < $1.yAxis })?.yAxis ?? 0
        let totalY = data.reduce(0.0) { $0 + $1.yAxis }
        let avgY =  data.isEmpty ? 0.0 : totalY / Double(data.count)
        let ySpan = maxY - minY
        // 12.5% spacing between max and min y values
        let spacing = 0.125 * ySpan
        let lowerBound = minY - spacing
        let upperBound = maxY + spacing

        var avgText: String {
            if yAxis == "duration" {
                return "Avg: " + formatTimeInterval(avgY)
            } else {
                return "Avg: " + formatNumberString(from: avgY)
            }
        }

        Chart {
            ForEach(data) { datum in
                LineMark(
                    x: .value("Day", datum.xAxis),
                    y: .value("Weight", datum.yAxis)
                )
                .foregroundStyle(Color.accentColor)
            }
            .symbol {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8)
            }
            ForEach(data) { datum in
                AreaMark(
                    x: .value("Day", datum.xAxis),
                    yStart: .value("low", 0),
                    yEnd: .value("high", datum.yAxis)
                )
                .foregroundStyle(gradient)

            }
            RuleMark(y: .value("Average", avgY))
                .foregroundStyle(Color.secondary)
                .lineStyle(StrokeStyle(lineWidth: 0.8, dash: [10]))
                .annotation(alignment: .trailing) {
                    Text(avgText)
                        .font(.subheadline).bold()
                        .padding(.trailing, 32)
                        .foregroundStyle(Color.secondary)
                }

        }
        .frame(height: 250)

        .chartXAxis {
            AxisMarks(preset: .aligned, values: data.map { $0.xAxis }) { value in
                if let index = value.as(Int.self) {
                    AxisGridLine()
                    AxisValueLabel(orientation: .vertical, horizontalSpacing: -6.5, verticalSpacing: 6.5) {
                        if let item = data.first(where: { $0.xAxis == index }) {
                            Text("\(item.date, format: .dateTime.month(.twoDigits).day(.twoDigits).year())")

                        }
                    }

                }
            }

        }
        .chartYAxis {
            AxisMarks { value in
                if let index = value.as(Int.self) {
                    AxisGridLine()
                    AxisValueLabel {
                        Text("\(formatYValue(index))")
                    }
                }
            }
        }

         // y padding that needs a better solution
        .chartYScale(domain: min(lowerBound, upperBound)...max(lowerBound, upperBound))
        .chartScrollableAxes(.horizontal)
        // only show max of 14 at a time
        .chartXVisibleDomain(length: min((num + 1), 14))
        // add one at the beginning and end for padding
        .chartXScale(domain: -1...maxX + 1)
        .chartScrollPosition(initialX: Date.distantFuture)
    }

    // format the times into 0h 0m
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute]

        guard let formattedDuration = durationFormatter.string(from: timeInterval) else {
            return "Invalid Duration"
        }

        return formattedDuration
    }

    // function to format labels for y axis based on passed in var 'yAxis'
    func formatYValue(_ value: Int) -> String {
        if yAxis == "duration" {
            return formatTimeInterval(TimeInterval(value))
        } else {
            // add k instead of 1000
            let absValue = abs(value)
            if absValue >= 1000 {
                let formattedValue = String(format: "%.1fk", Double(value) / 1000)
                return formattedValue.replacingOccurrences(of: ".0", with: "")
            } else {
                return "\(value)"
            }
        }
    }

    func formatNumberString(from number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let formattedNumber = numberFormatter.string(from: NSNumber(value: Int(number))) {
            return formattedNumber
        } else {
            return String(Int(number))
        }
    }
}

#Preview {
    LineChart(pastDays: .constant(7), yAxis: .constant("volume"))
        .modelContainer(previewContainer)
}
