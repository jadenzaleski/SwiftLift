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
        Text("history: \(history.count), exercise: \(exercises.count)")
    }
}

#Preview {
    HistoryView()
}
