//
//  WorkoutPill.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/29/23.
//

import SwiftUI

struct WorkoutPill: View {
    @Binding var activity: Activity
    @State var isComplete: Bool = false
    @State var inProgress: Bool = false
    var body: some View {
        NavigationStack {
            NavigationLink {
                LogActivityView(activity: $activity)
            } label: {
                HStack {
                    if (isComplete) {
                        Image(systemName:"checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    } else if (inProgress) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                    } else {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundStyle(Color("ld"))
                    }
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
                    inProgress = !allSets.isEmpty && (allSets.first(where: {$0.isChecked }) != nil)
                }
            }
        }
    }
}

#Preview {
    WorkoutPill(activity: .constant(Activity.sampleActivites[0]))
}
