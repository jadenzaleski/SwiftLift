//
//  AV.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI

struct AV: View {
    @Binding var activity: Activity

    var body: some View {
        ScrollView(showsIndicators: false) {
            sets(title: "warmup", sets: $activity.warmUpSets)
            sets(title: "working", sets: $activity.workingSets)
        }
        .navigationTitle(Text(activity.name))
    }

    @ViewBuilder
    private func item(set: Binding<SetData>) -> some View {
        HStack {
            Button(action: { set.wrappedValue.isComplete.toggle() }) {
                Image(systemName: set.wrappedValue.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.wrappedValue.isComplete ? .green : .gray)
            }
            TextField("Reps", value: set.reps, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            Spacer()
            Text("/")
            Spacer()
            TextField("Weight", value: set.weight, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
        }
    }

    @ViewBuilder
    private func sets(title: String, sets: Binding<[SetData]>) -> some View {
        Text("\(sets.count) \(title) set\(sets.count == 1 ? ":" : "s:")")
            .font(.lato(type: .light, size: .subtitle))

        ForEach(sets) { $set in
            item(set: $set)
        }
    }
}

#Preview {
    AV(activity: .constant(
        Activity(name: "tester", gym: "default",
                 warmUpSets: [
                    SetData(reps: 10, weight: 20.0, isComplete: true),
                    SetData(reps: 15, weight: 30.0, isComplete: false)],
                 workingSets: [
                    SetData(reps: 8, weight: 50.5, isComplete: false),
                    SetData(reps: 8, weight: 50.0, isComplete: false),
                    SetData(reps: 12, weight: 30.0, isComplete: false)]
                )
    ))
}
