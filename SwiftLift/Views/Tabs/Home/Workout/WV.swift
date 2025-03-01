//
//  WV.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI
import Combine

struct WV: View {
    @Binding var workoutInProgress: Bool
    @State var showDeleteAlert: Bool = false
    @State var currentworkout = Workout(startDate: .now, duration: 0, gym: "")

    var body: some View {
        ScrollView(showsIndicators: false) {
            Text("activites count: \(currentworkout.activities.count)")

            Button {
                currentworkout.activities.append(Activity(name: "test", gym: "gym"))
            } label: {
                Text("Add Activity")
            }

            ForEach(currentworkout.activities.indices, id: \.self) { index in
                NavigationLink(value: index) {
                    Text(currentworkout.activities[index].name)
                }
            }
            .navigationDestination(for: Int.self) { index in
                AV(activity: activityBinding(for: index))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "xmark")
                }
                .alert(
                    "Cancel your lift?",
                    isPresented: $showDeleteAlert
                ) {
                    Button(role: .destructive) {
                        workoutInProgress = false
                    } label: {
                        Text("Confirm")

                    }
                } message: {
                    Text("All recorded data will be lost. This action cannot be undone.")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    workoutInProgress = false
                } label: {
                    Image(systemName: "flag.checkered")
                }
            }
        }
    }

    /// Returns a binding to an ``Activity`` within the `currentworkout.activities` array based on the provided index.
    /// This allows for two-way data binding, enabling modifications to ``Activity`` instances directly in views.
    ///
    /// - Parameter id: The index of the ``Activity`` in the `currentworkout.activities` array.
    /// - Returns: A `Binding<Activity>` that reflects changes to the corresponding `Activity` in the array.
    private func activityBinding(for id: Array<Activity>.Index) -> Binding<Activity> {
        Binding {
            // Retrieves the activity at the specified index from the activities array.
            currentworkout.activities[id]
        } set: { newValue in
            // Updates the activity at the specified index when changes occur.
            currentworkout.activities[id] = newValue
        }
    }
}

#Preview {
    WV(workoutInProgress: .constant(true))
}
