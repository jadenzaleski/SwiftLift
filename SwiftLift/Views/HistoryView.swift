//
//  HistoryView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
    var body: some View {
        NavigationSplitView {
            if let workouts = history.first?.workouts, !workouts.isEmpty {
                List(workouts.reversed()) { workout in
                            NavigationLink {
                                HistoryDetail(workout: workout)
                            } label: {
                                HistoryRow(workout: workout)
                            }
                            .navigationTitle("History")
                        }
                    } else {
                        Text("No Workouts Yet")
                    }
        } detail: {
            Text("Select a Workout")
        }
        
    }
    
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d:%02d", abs(hours), abs(minutes), abs(seconds))
    }
}

#Preview {
    HistoryView()
        //.modelContainer(for: [History.self, Exercise.self], inMemory: true)

}
