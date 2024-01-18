//
//  VolumeVsDate.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 1/14/24.
//

import SwiftUI
import SwiftData
import Charts

struct VolumeVsDate: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4), Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter
        }()
    
    
    var body: some View {
        let h = history[0]
        let dates = h.workouts!.map { $0.startDate }
        var volumes = h.workouts!.map { $0.totalWeight }
 
        let startDate = dates.min() ?? Date()
        let endDate = dates.max() ?? Date()
        
        Chart {
            ForEach(h.workouts!) { workout in
                let formattedDate = dateFormatter.string(from: workout.startDate)
                LineMark(x: .value("Date", workout.startDate),
                         y: .value("Volume", workout.totalWeight))
                .foregroundStyle(Color.accentColor)

                PointMark(x: .value("Date", workout.startDate),
                          y: .value("Volume", workout.totalWeight))
                
            }
            .interpolationMethod(.cardinal)
            
            ForEach(h.workouts!) { workout in
                AreaMark(x: .value("Date", workout.startDate),
                         y: .value("Volume", workout.totalWeight))
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(gradient)
        }
        .chartXAxis {
            AxisMarks(format: .dateTime.month(.defaultDigits).day(), values: dates)
        }
//        .chartYAxis {
//            
//            AxisMarks(values: volumes)
//        }
        .chartXScale(domain: (startDate - 1)...(endDate + 12))
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VolumeVsDate()
        .modelContainer(previewContainer)
}
