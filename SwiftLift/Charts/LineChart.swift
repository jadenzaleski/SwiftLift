//
//  VolumeVsDate.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 1/14/24.
//

import SwiftUI
import Charts
import SwiftData

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
    @Environment(\.colorScheme) var colorScheme

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color.accentColor.opacity(0.4),
        Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)

    @Binding var pastDays: Int
    @Binding var yAxis: String

    @Query private var workouts: [Workout]

    var body: some View {
        let num = pastDays == -1 ? workouts.count : min(pastDays, workouts.count)

        // Sort and filter workouts
        let orderedWorkouts = workouts
            .compactMap { $0.endDate != nil ? $0 : nil }
            .sorted { $0.endDate! < $1.endDate! }
        let selectedWorkouts = orderedWorkouts.suffix(num)

        // Convert workouts to plotting data
        let data: [PlottingData] = selectedWorkouts.enumerated().map { index, workout in
            let possibleY: Double
            switch yAxis {
            case "duration":
                possibleY = Double(workout.duration)
            case "volume":
                possibleY = workout.totalWeight
            default:
                possibleY = Double(workout.totalReps)
            }
            return PlottingData(xAxis: index, yAxis: possibleY, date: workout.endDate ?? .now)
        }

        let maxX = data.map(\.xAxis).max() ?? 0
        let maxY = data.map(\.yAxis).max() ?? 0
        let minY = data.map(\.yAxis).min() ?? 0
        let totalY = data.reduce(0.0) { $0 + $1.yAxis }
        let avgY = data.isEmpty ? 0.0 : totalY / Double(data.count)
        let ySpan = maxY - minY
        let spacing = 0.125 * ySpan
        let lowerBound = minY - spacing
        let upperBound = maxY + spacing

        var avgText: String {
            yAxis == "duration" ? "Avg: \(formatTimeInterval(avgY))" : "Avg: \(formatNumberString(from: avgY))"
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
                if let index = value.as(Int.self), let item = data.first(where: { $0.xAxis == index }) {
                    AxisGridLine()
                    AxisValueLabel(orientation: .vertical, horizontalSpacing: -6.5, verticalSpacing: 6.5) {
                        Text("\(item.date, format: .dateTime.month(.twoDigits).day(.twoDigits).year())")
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

    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: timeInterval) ?? "Invalid Duration"
    }

    func formatYValue(_ value: Int) -> String {
        if yAxis == "duration" {
            return formatTimeInterval(TimeInterval(value))
        } else if abs(value) >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000).replacingOccurrences(of: ".0", with: "")
        } else {
            return "\(value)"
        }
    }

    func formatNumberString(from number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: Int(number))) ?? String(Int(number))
    }
}

#Preview {
    LineChart(pastDays: .constant(7), yAxis: .constant("volume"))
        .modelContainer(for: Workout.self, inMemory: true)
}
