//
//  HistoryView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var history: History
    var body: some View {
        Text("History View")
            .onAppear {
                print(history)
            }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(History.sampleHistory)
    }
}
