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
    /// Boolean to keep track of wether or not the delete workout alert is showing. In ``workoutToolbar``.
    @State var showDeleteAlert: Bool = false
    @State var currentworkout = Workout(startDate: .now, duration: 0, gym: "The testing gym")
    /// Keeps track of the offsets for each activity in the ``ForEach`` loop in ``activityList``.
    @State var offsets = [CGSize](repeating: CGSize.zero, count: 6)

    private let swipeLeftLimit: CGFloat = -60
    private let swipeRightLimit: CGFloat = 60
    private let swipeLeftLimitToShow: CGFloat = -40
    private let swipeRightLimitToHide: CGFloat = 40

    var body: some View {
        ScrollView(showsIndicators: false) {
            workoutHeader()
            activityList()

            Button {
                currentworkout.activities.append(Activity(name: "test", gym: "gym"))
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Exercise")
                }
                .font(.lato(type: .regular, size: .subtitle))
            }
            .padding(.top)
        }
        .padding()
        .toolbar {
            workoutToolbar()
        }
    }

    // MARK: - Header
    /// The header that displayes when a ``workoutInProgress`` is true.
    @ViewBuilder
    private func workoutHeader() -> some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "timer")
                Text("00:00:00")
                Spacer()
                Text(currentworkout.gym)
                    .lineLimit(1)
                Image(systemName: "location")
            }
            .padding(.bottom, 2.0)
            .font(.lato(type: .light, size: .heading))

            HStack {
                let count = currentworkout.activities.count
                let text = count == 1 ? "Exercise" : "Exercises"
                Text("\(currentworkout.activities.count) \(text):")
                    .font(.lato(type: .light, size: .heading))
                Spacer()
            }
        }
    }

    // MARK: - Activity List
    /// Displays a list of activities with navigation links.
    @ViewBuilder
    private func activityList() -> some View {
        ForEach(currentworkout.activities.indices, id: \.self) { index in
            ZStack(alignment: .trailing) {
                // DELETE BUTTON (Initially behind)
                deleteButton(for: index)
                    .zIndex(offsets[index].width < 0 ? 1 : 0) // Move forward only on swipe

                // NAVIGATION LINK (Above by default)
                NavigationLink(value: index) {
                    item(index: index)
                }
                .offset(x: offsets[index].width)
                // If this is not a highPriorityGesture, the NavigationLink will take precedent
                .highPriorityGesture(dragGesture(for: index))
                .zIndex(2) // Always above deleteButton initially
            }
            .padding(.bottom, 8.0)
        }
        .navigationDestination(for: Int.self) { index in
            AV(activity: activityBinding(for: index))
        }
    }

    /// For each item in the ``activityList``, display this view.
    @ViewBuilder
    private func item(index: Int) -> some View {
        let activity = currentworkout.activities[index]
        HStack {
            // Change the color and the type of image based on activity compeltion status
            Image(systemName: activity.isComplete ? "checkmark.circle.fill" : "exclamationmark.circle")
                .foregroundStyle(activity.isComplete ? .green : .yellow)
                .font(.lato(type: .thin, size: .subtitle))
            Text("\(activity.name)")
                .font(.lato(type: .bold, size: .subtitle))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.lato(type: .thin, size: .subtitle))

        }
        .foregroundStyle(Color.ld)
        .padding()
        .background(Color("offset"))
        .clipShape(Capsule())
        .overlay(
            activity.isComplete ?
            Capsule(style: .continuous)
                .stroke(Color.green, lineWidth: 2)
                .padding(.horizontal, 1.0) : nil
        )
    }

    /// Creates a delete button for an activity
    @ViewBuilder
    private func deleteButton(for index: Int) -> some View {
        HStack {
            Spacer()
            Button {
                deleteActivity(at: index)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.red)
                    .clipShape(Circle())
                    .opacity(offsets[index].width < swipeLeftLimitToShow ? 1 : 0)
                    .animation(.easeIn(duration: 0.2), value: offsets[index].width)
            }
            .padding(.trailing, 3.0)
            .contentShape(Rectangle()) // Ensures tap recognition
        }
    }
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func workoutToolbar() -> some ToolbarContent {
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
                Text("All recorded data from this current lift will be lost. This action cannot be undone.")
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

    // MARK: - Helpers
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

    // swiftlint:disable:next line_length
    /// Code from: [Stackoverflow question](https://stackoverflow.com/questions/67238383/how-to-swipe-to-delete-in-swiftui-with-only-a-foreach-and-not-a-list)
    /// Creates a drag gesture for handling swipe-to-delete functionality.
    ///
    /// This gesture allows users to swipe an item to the left to reveal a delete option. It prevents
    /// swiping to the right beyond the original position and ensures a smooth swipe animation.
    ///
    /// - Parameter index: The index of the item being swiped.
    /// - Returns: A `Gesture` that handles swipe interactions.
    private func dragGesture(for index: Int) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                // Prevent swipe to the right in default position
                if offsets[index].width == 0 && gesture.translation.width > 0 {
                    return
                }

                // Prevent drag more than swipeLeftLimit points
                if gesture.translation.width < swipeLeftLimit * 10 {
                    return
                }

                // Prevent swipe againt to the left if it's already swiped
                if offsets[index].width == swipeLeftLimit && gesture.translation.width < 0 {
                    return
                }

                // If view already swiped to the left and we start dragging to the right
                // Firstly will check if it's swiped left
                if offsets[index].width >= swipeLeftLimit {
                    // And here checking if swiped to the right more than swipeRightLimit points
                    // If more - need to set the view to zero position
                    if gesture.translation.width > swipeRightLimit {
                        self.offsets[index] = .zero
                        return
                    }

                    // Check if only swiping to the right - update distance by minus swipeLeftLimit points
                    if offsets[index].width != 0 && gesture.translation.width > 0 {
                        self.offsets[index] = .init(width: swipeLeftLimit + gesture.translation.width,
                                                    height: gesture.translation.height)
                        return
                    }
                }

                self.offsets[index] = gesture.translation
            }
            .onEnded { gesture in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    // Left swipe handle:
                    if self.offsets[index].width < swipeLeftLimitToShow {
                        self.offsets[index].width = swipeLeftLimit
                        return
                    }
                    if self.offsets[index].width < swipeLeftLimit {
                        self.offsets[index].width = swipeLeftLimit
                        return
                    }

                    // Right swipe handle:
                    if gesture.translation.width > swipeRightLimitToHide {
                        self.offsets[index] = .zero
                        return
                    }
                    if gesture.translation.width < swipeRightLimitToHide {
                        self.offsets[index].width = swipeLeftLimit
                        return
                    }

                    self.offsets[index] = .zero
                }
            }
    }

    /// Deletes an activity at the given index
    private func deleteActivity(at index: Int) {
        /*
        withAnimation {
            currentworkout.activities.remove(at: index)
            offsets.remove(at: index) // Keep offsets array in sync
        }
         */
        print("deleting \(index)")
    }
}

#Preview {
    WV(workoutInProgress: .constant(true))
        .environment(\.font, .lato(type: .regular))

}
