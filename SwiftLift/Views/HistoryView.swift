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
}

#Preview {
    HistoryView()
        .modelContainer(for: [History.self, Exercise.self], inMemory: true)

}
