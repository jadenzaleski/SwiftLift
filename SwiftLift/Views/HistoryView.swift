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
        NavigationStack {
            if let workouts = history.first?.workouts, !workouts.isEmpty {
                List(workouts.reversed()) { workout in
                    NavigationLink(destination: HistoryDetail(workout: workout)) {
                        HistoryRow(workout: workout)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {

                    ToolbarItem(placement: .principal) {
                        Text("History")
                            .font(.lato(type: .light, size: .toolbarTitle))
                    }
                }
            } else {
                Text("No Workouts Yet")
                    .font(.lato(type: .light, isItalic: true))
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [History.self, Exercise.self], inMemory: false)

}
