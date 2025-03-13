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
    /// A list of completed workouts sorted by start date.
    @Query(filter: #Predicate<Workout> { $0.duration > 0 }, sort: \Workout.completionDate, order: .reverse)
    private var workouts: [Workout]

    var body: some View {
        NavigationStack {
            if workouts.isEmpty {
                VStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No Workouts Yet")
                        .font(.lato(type: .light, isItalic: true))
                }
            } else {
                List(workouts) { workout in
                    NavigationLink(value: workout) {
                        HistoryRow(workout: workout)
                    }
                }
                .navigationDestination(for: Workout.self) { workout in
                    HistoryDetail(workout: workout)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("History")
                            .font(.lato(type: .light, size: .toolbarTitle))
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Workout.self], inMemory: false)
}
