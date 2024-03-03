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

struct VolumeVsDate: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4), Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)
    @Binding var pastDays: Int
    @Binding var yAxis: String
    
    //    var body: some View {
    ////        let h = history[0]
    //        let h = History.sampleHistory
    //        let n = pastDays == -1 ? h.workouts!.count : min(pastDays, h.workouts?.count ?? 0)
    //
    //        let dates = h.workouts?.prefix(n).compactMap { $0.startDate } ?? []
    //
    //        let startDate = dates.min() ?? Date()
    //        let endDate = dates.max() ?? Date()
    //        let totalY = h.workouts!.reduce(0, { $0 + $1.totalWeight })
    //        let avgY =  h.workouts!.isEmpty ? 0.0 : totalY / Double(h.totalWorkouts)
    //
    //        Chart {
    //            ForEach(h.workouts!) { workout in
    //                LineMark(x: .value("Date", workout.startDate),
    //                         y: .value("Volume", workout.totalWeight))
    //                .foregroundStyle(Color.accentColor)
    //                .symbol {
    //                    Image(systemName: "circle.fill")
    //                        .font(.system(size: 8))
    //                }
    //
    //            }
    //
    //            ForEach(h.workouts!) { workout in
    //                AreaMark(x: .value("Date", workout.startDate),
    //                         y: .value("Volume", workout.totalWeight))
    //            }
    //            .foregroundStyle(gradient)
    //
    //            RuleMark(y: .value("Average", avgY))
    //                            .foregroundStyle(Color.secondary)
    //                            .lineStyle(StrokeStyle(lineWidth: 0.8, dash: [10]))
    //                            .annotation(alignment: .topTrailing) {
    //                                Text("Avg: " + "\(Int(avgY))")
    //                                    .font(.subheadline).bold()
    //                                    .padding(.trailing, 32)
    //                                    .foregroundStyle(Color.secondary)
    //                            }
    //        }
    //        .chartXAxis {
    //            AxisMarks(format: .dateTime.month(.defaultDigits).day(), values: dates)
    //        }
    ////        .chartXScale(domain: (startDate - 1)...(endDate + 12))
    //        .frame(height: 250)
    ////        .aspectRatio(1, contentMode: .fit)
    //    }
    
    var body: some View {
        //        let h = history[0]
        let h = History.sampleHistory
        //        let dates = h.workouts!.map { $0.startDate }
        //        let volumes = h.workouts!.map { $0.totalWeight }
        let n = pastDays == -1 ? h.workouts!.count : min(pastDays, h.workouts?.count ?? 0)
        let dates = h.workouts?.prefix(n).compactMap { $0.startDate } ?? []
        let sortedWorkouts = h.workouts!.prefix(n).sorted { (workout1, workout2) in
            return workout1.startDate < workout2.startDate
        }
        
        let data: [PlottingData] = sortedWorkouts.enumerated().map { index, workout in
            return PlottingData(x: Int(index), y: workout.totalWeight, date: workout.startDate)
        }
        
        
        
        //        var currentDay = Date.now
        //        let n = min(pastDays, sortedWorkouts.count)
        //        let data: [PlottingData] = (0..<n).map { i in
        //            if (currentDay.distance(to: sortedWorkouts[i].startDate) > 24 * 60 * 60) {
        //                currentDay = sortedWorkouts[i].startDate
        //                return PlottingData(y: 0, date: sortedWorkouts[i].startDate);
        //            } else {
        //                currentDay = sortedWorkouts[i].startDate
        //                return PlottingData(y: sortedWorkouts[i].totalWeight, date:
        //                                        sortedWorkouts[i].startDate)
        //            }
        //
        //        }
        
        
        let maxX = data.max(by: { $0.x < $1.x })?.x ?? 0
        let maxY = data.max(by: { $0.y < $1.y })?.y ?? 0
        let minY = data.min(by: { $0.y < $1.y })?.y ?? 0
        let totalY = data.reduce(0.0) { $0 + $1.y }
        let avgY =  data.isEmpty ? 0.0 : totalY / Double(data.count)
        let maxDate = data.map { $0.date }.max() ?? Date()
        let minDate = data.map { $0.date }.min() ?? Date()
        let dateFormatter = DateFormatter()
        
        Text("\(n)");
        Text("\(yAxis)");
        
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
                    Text("Avg: " + "\(Int(avgY))")
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
                            Text("\(pd.date, format: .dateTime.month(.twoDigits).day(.twoDigits).year(.twoDigits))")
                            
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
                        Text("\(formatK(index))")
                    }
                }
            }
        }
        
        .chartYScale(domain: (minY - (minY / 2))...(maxY + (maxY * 0.1)))
        .chartScrollableAxes(.horizontal)
        // only show max of 14 at a time
        .chartXVisibleDomain(length: min((n + 1), 14))
        .chartXScale(domain: -1...maxX + 1)
        .chartScrollPosition(initialX: minDate.timeIntervalSince1970)
        
    }
}

// Function to format labels with 'k' for thousands
func formatK(_ value: Int) -> String {
    let absValue = abs(value)
    if absValue >= 1000 {
        let formattedValue = String(format: "%.1fk", Double(value) / 1000)
        return formattedValue.replacingOccurrences(of: ".0", with: "")
    } else {
        return "\(value)"
    }
}

#Preview {
    VolumeVsDate(pastDays: .constant(20), yAxis: .constant("volume"))
        .modelContainer(previewContainer)
}
