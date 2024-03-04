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
    var y: Double
    var date: Date
    var x: Int
    
    init(id: UUID = UUID(), x: Int, y: Double, date: Date) {
        self.id = id
        self.y = y
        self.date = date
        self.x = x
    }
}

struct LineChart: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4), Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)
    @Binding var pastDays: Int
    @Binding var yAxis: String
    
    
    
    var body: some View {
//        let h = history[0]
        let h = History.sampleHistory
        // n is the number of workouts to display. min of input and count of workouts
        let n = pastDays == -1 ? h.workouts!.count : min(pastDays, h.workouts?.count ?? 0)
        //let dates = h.workouts?.prefix(n).compactMap { $0.startDate } ?? []
        // sort the workouts so the most recent is on top i think
        let sortedWorkouts = h.workouts!.prefix(n).sorted { (workout1, workout2) in
            return workout1.startDate < workout2.startDate
        }
        // data to plot, change based on passed in yAxis value
        let data: [PlottingData] = sortedWorkouts.enumerated().map { index, workout in
            var y = 0.0
            if (yAxis == "duration") {
                y = Double(workout.time)
            } else if (yAxis == "volume") {
                y = workout.totalWeight
            } else {
                y = Double(workout.totalReps)
            }
            return PlottingData(x: Int(index), y: y, date: workout.startDate)
        }
        
        let maxX = data.max(by: { $0.x < $1.x })?.x ?? 0
        let maxY = data.max(by: { $0.y < $1.y })?.y ?? 0
        let minY = data.min(by: { $0.y < $1.y })?.y ?? 0
        let totalY = data.reduce(0.0) { $0 + $1.y }
        let avgY =  data.isEmpty ? 0.0 : totalY / Double(data.count)
//        let maxDate = data.map { $0.date }.max() ?? Date()
//        let minDate = data.map { $0.date }.min() ?? Date()
        
        var avgText: String {
            if yAxis == "duration" {
                return formatTimeInterval(avgY)
            } else {
                return String(Int(avgY))
            }
        }
        
        Chart {
            ForEach(data) { d in
                LineMark(
                    x: .value("Day", d.x),
                    y: .value("Weight", d.y)
                )
                .foregroundStyle(Color.accentColor)
            }
            .symbol {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8)
            }
            ForEach(data) { d in
                AreaMark(
                    x: .value("Day", d.x),
                    yStart: .value("low", 0),
                    yEnd: .value("high",  d.y)
                )
                .foregroundStyle(gradient)
                
            }
            RuleMark(y: .value("Average", avgY))
                .foregroundStyle(Color.secondary)
                .lineStyle(StrokeStyle(lineWidth: 0.8, dash: [10]))
                .annotation(alignment: .topTrailing) {
                    Text("Avg: " + avgText)
                        .font(.subheadline).bold()
                        .padding(.trailing, 32)
                        .foregroundStyle(Color.secondary)
                }
            
        }
        .frame(height: 250)
        
        .chartXAxis {
            AxisMarks(preset: .aligned, values: data.map { $0.x }) { value in
                if let index = value.as(Int.self) {
                    AxisGridLine()
                    AxisValueLabel(orientation: .vertical, horizontalSpacing: -6.5, verticalSpacing: 6.5) {
                        if let pd = data.first(where: { $0.x == index }) {
                            Text("\(pd.date, format: .dateTime.month(.twoDigits).day(.twoDigits))")
                            
                        }
                    }
                    
                }
            }
            
        }
        .chartYAxis {
            AxisMarks() { value in
                if let index = value.as(Int.self) {
                    AxisGridLine()
                    AxisValueLabel() {
                        Text("\(formatYValue(index))")
                    }
                }
            }
        }
         // y padding that needs a better solution
        .chartYScale(domain: (minY - (minY / 1.5))...(maxY + (maxY * 0.05)))
        .chartScrollableAxes(.horizontal)
        // only show max of 14 at a time
        .chartXVisibleDomain(length: min((n + 1), 14))
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
        if (yAxis == "duration") {
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
}

#Preview {
    LineChart(pastDays: .constant(20), yAxis: .constant("duration"))
        .modelContainer(previewContainer)
}
