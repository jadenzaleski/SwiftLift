//
//  WorkoutPill.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/29/23.
//

import SwiftUI

struct WorkoutPill: View {
    @Binding var activity: Activity
    @State private var isComplete: Bool = false
    @State private var inProgress: Bool = false
    var body: some View {
        NavigationLink(destination: LogActivityView(activity: $activity).withCustomBackButton()) {
            HStack {
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.custom("", size: 24))
                        .foregroundStyle(.green)
                } else if inProgress {
                    Image(systemName: "exclamationmark.circle")
                        .font(.custom("", size: 24))
                        .foregroundStyle(.yellow)
                } else {
                    Image(systemName: "circle")
                        .font(.custom("", size: 24))
                        .foregroundStyle(Color("ld"))
                }
                Text("\(activity.name)")
                    .padding(.leading)
                    .foregroundStyle(Color.ld)
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.ld)
            }
            .font(.lato(type: .regular, size: .subtitle))
            .padding()
            .background(Color("offset"))
            .clipShape(Capsule())
            .overlay(isComplete ?
                     Capsule(style: .continuous).stroke(Color.green, lineWidth: 2).padding(.horizontal, 1.0) : nil)
            .onChange(of: (activity.warmUpSets + activity.workingSets)) {
                let allSets = activity.warmUpSets + activity.workingSets
                isComplete = !allSets.isEmpty && allSets.allSatisfy { $0.isComplete }
                inProgress = !allSets.isEmpty && (allSets.first(where: {$0.isComplete }) != nil)
            }
            .onAppear {
                let allSets = activity.warmUpSets + activity.workingSets
                isComplete = !allSets.isEmpty && allSets.allSatisfy { $0.isComplete }
                inProgress = !allSets.isEmpty && (allSets.first(where: {$0.isComplete }) != nil)
            }
        }
//        .id(UUID())
    }
}

#Preview {
    WorkoutPill(activity: .constant(
        Activity(name: "Tester",
                 gym: "Default",
                 completedDate: .now,
                 warmUpSets: [SetData(reps: 10, weight: 20.0, isComplete: false )],
                 workingSets: [SetData(reps: 10, weight: 20.0, isComplete: false )]
                )
    ))
}
