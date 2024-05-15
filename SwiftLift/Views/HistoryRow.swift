//
//  HistoryRow.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 12/20/23.
//

import SwiftUI

struct HistoryRow: View {
    var workout: Workout
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "calendar")
                    .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                Text("\(workout.startDate.formatted(.dateTime.month().day().year().hour().minute()))")
                Spacer()
            }
            .padding(.bottom, 1.0)
            .font(.title3)
            .foregroundStyle(gradient)
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                Text("\(workout.gym)")
                    .padding(.trailing, 5.0)
                Image(systemName: "clock")
                    .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                Text("\(formatTimeInterval(workout.time))")
                    .padding(.trailing, 5.0)
                Spacer()
            }
        }
        .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
//        .background(.red)
    }

    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute, .second]

        guard let formattedDuration = durationFormatter.string(from: abs(timeInterval)) else {
            return "Invalid Duration"
        }

        return formattedDuration
    }
}

#Preview {
    HistoryRow(workout: Workout(startDate: Date.now, time: TimeInterval.pi, activities: [Activity(name: "yep", gym: "mm")], totalWeight: 20.0, totalReps: 30, totalSets: 30, gym: "gymString"))
}
