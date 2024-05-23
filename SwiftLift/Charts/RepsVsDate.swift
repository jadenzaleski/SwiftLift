//
//  RepsVsDate.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 1/18/24.
//

import SwiftUI
import Charts
import SwiftData

struct RepsVsDate: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color.accentColor.opacity(0.4),
        Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)

    var body: some View {
        let his = history[0]
        let dates = his.workouts!.map { $0.startDate }

        let startDate = dates.min() ?? Date()
        let endDate = dates.max() ?? Date()

        Chart {
            ForEach(his.workouts!) { workout in
                LineMark(x: .value("Date", workout.startDate),
                         y: .value("Reps", workout.totalReps))
                .foregroundStyle(Color.accentColor)
                .symbol {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                }

            }
            .interpolationMethod(.cardinal)

            ForEach(his.workouts!) { workout in
                AreaMark(x: .value("Date", workout.startDate),
                         y: .value("Reps", workout.totalReps))
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(gradient)
        }
        .chartXAxis {
            AxisMarks(format: .dateTime.month(.defaultDigits).day(), values: dates)
        }
        .chartXScale(domain: (startDate - 1)...(endDate + 12))
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    RepsVsDate()
        .modelContainer(previewContainer)
}
