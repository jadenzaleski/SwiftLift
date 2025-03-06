//
//  AV.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI
import SwiftData

struct AV: View {
    @Binding var activity: Activity
    @FocusState private var focusedField: PersistentIdentifier?

    var body: some View {
        ScrollView(showsIndicators: false) {
            sets(title: "warmup", sets: $activity.warmUpSets)
                .padding(.horizontal)

            sets(title: "working", sets: $activity.workingSets)
                .padding(.horizontal)
        }
        .navigationTitle(Text(activity.name))
        .onTapGesture {
            // Clears focus to dismiss the keyboard
            focusedField = nil
        }
    }
    
    /// This makes up each item in the warmp and working sets list.
    /// - Parameter set: The set to be edited by the TextFields
    /// - Returns: Return the item view for a singluar ``SetData``
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
                .focused($focusedField, equals: set.id)
            Spacer()
            Text("/")
                .padding(.horizontal)
            Spacer()
            TextField("Weight", value: set.weight, formatter: decimalFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: set.id)
        }
    }

    /// This view shows a list of sets for the provided input.
    /// - Parameters:
    ///   - title: The title of the sets.
    ///   - sets: and Array of ``SetData`` objects.
    /// - Returns: A ``View`` displaying the count of sets, a title, list of set items, and the add activity button.
    @ViewBuilder
    private func sets(title: String, sets: Binding<[SetData]>) -> some View {
        HStack {
            Text("\(sets.count) \(title) set\(sets.count == 1 ? ":" : "s:")")
                .font(.lato(type: .light, size: .subtitle))
            Spacer()
        }

        ForEach(sets) { $set in
            item(set: $set)
        }

        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                sets.wrappedValue.append(SetData(reps: 0, weight: 0.0, isComplete: false, parentActivity: activity))
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.title3)
                Text("Add \(title) set")
                    .font(.lato(type: .regular, size: .subtitle))
            }
        }
        .padding(.vertical, 5.0)
    }

    // MARK: - Helpers
    /// A ``NumberFormatter`` for ``SetData.weight`` which allows the following formats:
    /// 50, 50.5, 50.25
    /// It will autocorrect to these formats.
    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0   // Allow whole numbers without decimal places
        formatter.maximumFractionDigits = 2   // Allow up to two decimal places
        formatter.alwaysShowsDecimalSeparator = false // No forced decimal unless needed
        return formatter
    }()
}

#Preview {
    AV(
        activity: .constant(
            Activity(
                name: "tester", gym: "default",
                warmUpSets: [
                    SetData(reps: 10, weight: 20.0, isComplete: true),
                    SetData(reps: 15, weight: 30.0, isComplete: false)
                ],
                workingSets: [
                    SetData(reps: 8, weight: 50.5, isComplete: false),
                    SetData(reps: 8, weight: 50.0, isComplete: false),
                    SetData(reps: 12, weight: 30.0, isComplete: false)
                ]
            )
        ))
}
