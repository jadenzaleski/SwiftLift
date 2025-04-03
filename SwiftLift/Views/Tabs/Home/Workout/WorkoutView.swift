//
//  WorkoutView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI
import Combine

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var workoutInProgress: Bool
    /// This comes from ``HomeView`` `stopWorkout` and is the function used to stop the workout.
    /// Pass in a ``Bool`` that tells the function to save it to the database or not.
    var stopWorkout: (Bool) -> Void
    let timerTick: Int

    @SceneStorage("isPresentingExerciseSearch") private var isPresentingExerciseSearch: Bool = false

    /// Boolean to keep track of wether or not the delete workout alert is showing. In ``workoutToolbar``.
    @State var showDeleteAlert: Bool = false
    /// The current ``Workout``, if any.
    @State var currentWorkout: Workout
    /// Keeps track of the offsets for each activity in the ``ForEach`` loop in ``activityList``.
    @State var offsets: [CGSize] = []

    // Limits for the swipe gesture
    private let swipeLeftLimit: CGFloat = -60
    private let swipeRightLimit: CGFloat = 60
    private let swipeLeftLimitToShow: CGFloat = -40
    private let swipeRightLimitToHide: CGFloat = 40

    var body: some View {
        ScrollView(showsIndicators: false) {
            workoutHeader()
                .padding(.horizontal)
            activityList()
                .padding(.horizontal)
            // Add Exercise button
            Button {
                isPresentingExerciseSearch.toggle()
                updateOffsets()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Exercise")
                }
                .font(.lato(type: .regular, size: .subtitle))
            }
            .padding(.top)
        }
        .toolbar {
            workoutToolbar()
        }
        .onChange(of: currentWorkout.activities) {
            updateOffsets()
            print("onChange updateOffsets")
        }
        .onAppear {
            updateOffsets()
            print("onAppear updateOffsets")
        }
        .sheet(isPresented: $isPresentingExerciseSearch) {
            ExerciseSearch(currentWorkout: $currentWorkout, isPresentingExerciseSearch: $isPresentingExerciseSearch)
        }
    }

    // MARK: - Header
    /// The header that displayes when a ``workoutInProgress`` is true.
    @ViewBuilder
    private func workoutHeader() -> some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "timer")
                Text(timeString(from: currentWorkout.duration))
                    .monospacedDigit()
                Spacer()
                Text(currentWorkout.gym)
                    .lineLimit(1)
                Image(systemName: "location")
            }
            .padding(.bottom, 2.0)
            .font(.lato(type: .light, size: .heading))

            HStack {
                let count = currentWorkout.activities.count
                let text = count == 1 ? "Exercise" : "Exercises"
                Text("\(currentWorkout.activities.count) \(text):")
                    .font(.lato(type: .light, size: .heading))
                Spacer()
            }
        }
    }

    // MARK: - Activity List
    /// Displays a list of activities with navigation links.
    @ViewBuilder
    private func activityList() -> some View {
        let sortedIndices = currentWorkout.activities.indices.sorted {
            currentWorkout.activities[$0].index < currentWorkout.activities[$1].index
        }

        ForEach(sortedIndices, id: \.self) { index in
            // If you want to slide the whole item to the left:
            /*
             ZStack(alignment: .trailing) {
             // DELETE BUTTON (Initially behind)
             deleteButton(for: index)
             .zIndex(offsets[index].width < 0 ? 1 : 0) // Move forward only on swipe

             // NAVIGATION LINK (Above by default)
             NavigationLink(value: index) {
             item(index: index)
             }
             .offset(x: offsets[index].width)
             .gesture(dragGesture(for: index))
             .zIndex(2) // Always above deleteButton initially
             }
             .padding(.bottom, 8.0)
             */
            // If you only want to shrink the width of the item:
            HStack {
                NavigationLink(value: index) {
                    // If there is a moment where the index and count are not in sync, don't display the item.
                    if index < currentWorkout.activities.count {
                        item(index: index)
                    }
                }
                // If this is not a highPriorityGesture or simultaneousGesture, the NavigationLink will take precedent
                .highPriorityGesture(dragGesture(for: index))
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: safeOffset(for: index).width)
                // Show delete button only when swiped left
                if safeOffset(for: index).width < 0 {
                    deleteButton(for: index)
                }
            }
            .padding(.bottom, 8.0)
        }
        .navigationDestination(for: Int.self) { index in
            ActivityView(activity: activityBinding(for: index))
        }
    }

    /// For each item in the ``activityList``, display this view.
    @ViewBuilder
    private func item(index: Int) -> some View {
        let activity = currentWorkout.activities[index]
        let activityState: Int = {
            // Sets are either empty, complete, or in progress
            if (activity.warmUpSets + activity.workingSets).isEmpty {
                return 0
            } else if activity.isComplete {
                return 1
            } else {
                return 2
            }
        }()

        HStack {
            // Change the color and the type of image based on activity compeltion status
            Image(systemName:
                    activityState == 1 ? "checkmark.circle.fill" :
                    activityState == 0 ? "circle" : "exclamationmark.circle"
            )
            .foregroundStyle(activityState == 1 ? .green :
                                activityState == 0 ? Color.ld : .yellow)
            .font(.lato(type: .thin, size: .subtitle))
            Text("\(activity.name) \(activity.index)") // TODO: remove before commit
                .font(.lato(type: .bold, size: .subtitle))
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.lato(type: .thin, size: .subtitle))

        }
        .foregroundStyle(Color.ld)
        .padding()
        .background(Color("offset"))
        .clipShape(Capsule())
        .overlay {
            if let borderColor = borderColor(for: activityState) {
                Capsule(style: .continuous)
                    .stroke(borderColor, lineWidth: 2)
                    .padding(.horizontal, 1.0)
            }
        }
    }

    /// Creates a delete button for an activity
    @ViewBuilder
    private func deleteButton(for index: Int) -> some View {
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
        .contentShape(Rectangle())
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
                    stopWorkout(false)
                } label: {
                    Text("Confirm")
                }
            } message: {
                Text("All recorded data from this current lift will be lost. This action cannot be undone.")
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                stopWorkout(true)
            } label: {
                Image(systemName: "flag.checkered")
            }
        }
    }
}

// MARK: - Helpers
extension WorkoutView {
    /// Returns a binding to an ``Activity`` within the `currentworkout.activities` array based on the provided index.
    /// This allows for two-way data binding, enabling modifications to ``Activity`` instances directly in views.
    ///
    /// - Parameter id: The index of the ``Activity`` in the `currentworkout.activities` array.
    /// - Returns: A `Binding<Activity>` that reflects changes to the corresponding `Activity` in the array.
    private func activityBinding(for id: Array<Activity>.Index) -> Binding<Activity> {
        Binding {
            // Retrieves the activity at the specified index from the activities array.
            currentWorkout.activities[id]
        } set: { newValue in
            // Updates the activity at the specified index when changes occur.
            currentWorkout.activities[id] = newValue
        }
    }

    // swiftlint:disable:next line_length
    /// Code from: [Stackoverflow question](https://stackoverflow.com/questions/67238383/how-to-swipe-to-delete-in-swiftui-with-only-a-foreach-and-not-a-list)
    /// Creates a drag gesture for handling swipe-to-delete functionality.
    ///
    /// This gesture allows users to swipe an ``item`` to the left to reveal a delete option. It prevents
    /// swiping to the right beyond the original position and ensures a smooth swipe animation.
    /// This is overkill if we only want to change the with of the ``item`` but it will work for either implementation.
    /// - Parameter index: The index of the item being swiped.
    /// - Returns: A `Gesture` that handles swipe interactions.
    private func dragGesture(for index: Int) -> some Gesture {
        DragGesture(minimumDistance: 15)
            .onChanged { gesture in
                // Ensure the gesture is more horizontal than vertical
                guard abs(gesture.translation.width) > abs(gesture.translation.height) else {
                    return
                }

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
                // Ensure the gesture is more horizontal than vertical
                guard abs(gesture.translation.width) > abs(gesture.translation.height) else {
                    return
                }

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

    /// Deletes an ``Activity`` at the given index.
    /// - Parameter index: The index of the activity to delete.
    private func deleteActivity(at index: Int) {
        updateOffsets()
        // set all offsets to zero
        offsets = offsets.map { _ in CGSize.zero }

        withAnimation {
            let activityToDelete = currentWorkout.activities[index]
            // Remove from model context to actually delete the object
            modelContext.delete(activityToDelete)
            try? modelContext.save()
        }

        print("Deleted activity at array index \(index)")
    }

    /// This function ensures the ``offsets`` array matches the number of activities.
    private func updateOffsets() {
        // Ensure the offsets array matches the size of the activities array
        if offsets.count < currentWorkout.activities.count {
            // Append new zero-sized offsets for new activities
            offsets.append(contentsOf: [CGSize](
                repeating: .zero,
                count: currentWorkout.activities.count - offsets.count
            ))
        } else if offsets.count > currentWorkout.activities.count {
            // Trim excess offsets in case activities are removed
            offsets = Array(offsets.prefix(currentWorkout.activities.count))
        }
    }

    /// Function that returns 0 if the offset does not yet exist for the item.
    /// - Parameter index: The index of the offset.
    /// - Returns: The offset or zero if it does not exist.
    private func safeOffset(for index: Int) -> CGSize {
        if index < offsets.count {
            return offsets[index]
        } else {
            return .zero // Prevent index out of bounds
        }
    }

    /// Helps return the overlay color for the item border.
    /// - Parameter state: Current state of the activity.
    /// - Returns: A ``Color`` or ``nil``.
    private func borderColor(for state: Int) -> Color? {
        switch state {
        case 1: return .green   // Completed
        case 0: return .clear // No sets
        case 2: return .yellow  // In progress
        default: return nil     // No border
        }
    }
    /// Converts elapsed time into HH:MM:SS format
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    WorkoutView(
        workoutInProgress: .constant(true),
        stopWorkout: { saveIt in print("Stop workout called with saveIt: \(saveIt)") }, timerTick: 0,
        currentWorkout: Workout(gym: "Preview Test")
    )
    .environment(\.font, .lato(type: .regular))
}
