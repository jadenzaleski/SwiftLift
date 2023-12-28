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
            HStack() {
                Image(systemName: "clock")
                    .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                Text("\(formatTimeInterval(workout.time))")
                    .padding(.trailing, 5.0)
                Image(systemName: "repeat")
                    .padding(.trailing, -5.0)
                Text("\(workout.totalReps)")
                    .padding(.trailing, 5.0)
                Image(systemName: "scalemass")
                    .padding(.trailing, -5.0)
                Text("\(Int(workout.totalWeight))")
                Spacer()
            }
        }
        .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
//        .background(.red)
    }
    
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d:%02d", abs(hours), abs(minutes), abs(seconds))
    }
}

#Preview {
    HistoryRow(workout: Workout(startDate: Date.now, time: TimeInterval.pi, activities: [Activity(name: "yep", gym: "mm")], totalWeight: 20.0, totalReps: 30, gym: "gymString"))
}
