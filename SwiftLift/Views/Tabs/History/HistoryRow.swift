//
//  HistoryRow.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 12/20/23.
//

import SwiftUI

struct HistoryRow: View {
    var workout: Workout

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label(
                    title: { Text(workout.completionDate?.formatted(.dateTime.month().day().year().hour().minute()) ?? "In progress...") },
                    icon: { Image(systemName: "calendar") }
                )
                Spacer()
            }
            .font(.lato(type: .regular, size: .large))
            .foregroundStyle(gradient)

            HStack(spacing: 10) {
                Label(workout.gym, systemImage: "mappin.and.ellipse")
                Label(formatTimeInterval(workout.duration), systemImage: "clock")
                Spacer()
            }
            .font(.lato(type: .regular))
        }
        .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
    }

    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: abs(timeInterval)) ?? "Invalid Duration"
    }
}

#Preview {
    HistoryRow(workout: Workout(
        completionDate: Date(),
        duration: 3600, // 1 hour
        gym: "Local Gym",
        activities: [Activity(name: "Bench Press", gym: "Local Gym", completedDate: Date())]
    ))
}
