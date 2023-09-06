//
//  WorkoutPill.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/29/23.
//

import SwiftUI

struct WorkoutPill: View {
    @EnvironmentObject var history: History
    @Binding var activity: Activity
    @State var isComplete: Bool = false
    var body: some View {
        NavigationStack {
            NavigationLink {
                LogActivityView(activity: $activity)
                    .environmentObject(history)
            } label: {
                HStack {
                    Image(systemName: isComplete ? "checkmark.circle.fill" : "exclamationmark.circle")
                        .font(.title2)
                        .foregroundStyle(isComplete ? .green : .yellow)
                    Text("\(activity.name)")
                        .font(.title2)
                        .padding(.leading)
                        .foregroundStyle(Color.ld)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundStyle(Color.ld)
                }
                .padding()
                .background(Color.lg)
                .clipShape(Capsule())
                .overlay(isComplete ? Capsule(style: .continuous).stroke(Color.green, lineWidth: 2).padding(.horizontal, 1.0) : nil)
                .onChange(of: (activity.warmUpSets + activity.workingSets)) {
                    let allSets = activity.warmUpSets + activity.workingSets
                    isComplete = !allSets.isEmpty && allSets.allSatisfy { $0.isChecked }
                }
            }
        }
    }
}

struct WorkoutPill_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPill(activity: .constant(Activity.sampleActivites[1]))
    }
}
