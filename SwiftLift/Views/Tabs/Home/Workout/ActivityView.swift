import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme

    @Binding var activity: Activity
    @FocusState private var focusedField: FieldFocus?

    // Temporary state for editing fields
    @State private var editingReps: [PersistentIdentifier: String] = [:]
    @State private var editingWeight: [PersistentIdentifier: String] = [:]
    @State private var currentlyEditingSet: SetData?

    private let horizontalSpacing: CGFloat = 15
    private let lineCornerRadius: CGFloat = 2
    private let lineWidth: CGFloat = 2
    private let decimalSeparator = Locale.current.decimalSeparator ?? "."

    /// Focus state enum to track which field is focused.
    enum FieldFocus: Hashable {
        case reps(PersistentIdentifier)
        case weight(PersistentIdentifier)
    }

    var body: some View {
        List {
            Section {
                warmUpSection()
            }
            .listSectionSeparator(.hidden)

            Section {
                workingSection()
            } header: {

            }
            .listSectionSeparator(.hidden)
        }
        .navigationTitle(activity.name)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            if currentlyEditingSet != nil {
                toolbarView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            // Save current edits when focus changes
            if oldValue != nil {
                saveCurrentEdits()
                print("saved changes due to focus change")
            }

            withAnimation {
                if let focus = newValue {
                    switch focus {
                    case .reps(let id), .weight(let id):
                        currentlyEditingSet = activity.sets.first(where: { $0.persistentModelID == id })
                    }
                } else {
                    currentlyEditingSet = nil
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background {
                // Save any pending edits when app moves to background
                saveCurrentEdits()
                print("[\(Date.now)] Changes saved due to scene phase change to \(newPhase)")
            }
        }
    }

    /// The toolbar above the the keypad.
    private var toolbarView: some View {
        HStack(alignment: .center, spacing: 5) {
            Button {
                if let set = currentlyEditingSet {
                    saveCurrentEdits()
                    duplicateSet(set: set)
                    print("Set duplicated")
                }
            } label: {
                Label("Duplicate", systemImage: "plus.square.fill.on.square.fill")
                    .font(.lato())
                    .labelStyle(.iconOnly)
                    .padding(10)
                    .background(Circle().fill(Color.accentColor))
                    .foregroundStyle(.white)
                    .shadow(radius: 0)
            }
            .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : .secondary, radius: 5, x: 0, y: 2.5)

            Spacer()

            Button {
                if let set = currentlyEditingSet {
                    set.isComplete = true
                }
                // We don't need to save changes because that already
                // happens when we change the focusedField.
                moveToNextSet() // Changes focusedField
            } label: {
                Label("Done", systemImage: "checkmark")
                    .font(.lato(type: .bold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Capsule().fill(Color.green))
                    .foregroundStyle(.white)
                    .shadow(radius: 0)
            }
            .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : .secondary, radius: 5, x: 0, y: 2.5)

            Spacer()

            Button {
                focusedField = nil
            } label: {
                Label("Close", systemImage: "keyboard.chevron.compact.down")
                    .font(.lato())
                    .labelStyle(.iconOnly)
                    .padding(10)
                    .background(Circle().fill(Color.gray))
                    .foregroundStyle(.white)
                    .shadow(radius: 0)
            }
            .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : .secondary, radius: 5, x: 0, y: 2.5)
        }
        .padding(horizontalSpacing)
        .background(.clear)
    }

    // MARK: - Sections
    /// The warm up secion of the list.
    /// - Returns: The warm up section view.
    @ViewBuilder
    private func warmUpSection() -> some View {
        Text("\(activity.warmUpSets.count) warm up set\(activity.warmUpSets.count == 1 ? ":" : "s:")")
            .font(.lato(type: .light, size: .subtitle))
            .foregroundStyle(.ld)
            .listRowSeparator(.hidden)

        ForEach(Array(activity.warmUpSets.enumerated()), id: \.1.persistentModelID) { _, set in
            listItem(set: set)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        modelContext.delete(set)
                        updateSortIndices()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .listRowBackground(Color.clear)
        }
        .onMove(perform: moveWarmUpSet)

        addWarmupSetButton()
    }

    /// The button view that includes the vertical line and button, for the warm up sets.
    /// - Returns: The view of the button.
    @ViewBuilder
    private func addWarmupSetButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                // Create new set with appropriate type
                let newSet = SetData(type: .warmUp, parentActivity: activity, sortIndex: activity.sets.count)

                // Find position to insert - right after the last warm-up set
                if let lastWarmUpIndex = activity.sets.lastIndex(where: { $0.type == .warmUp }) {
                    activity.sets.insert(newSet, at: lastWarmUpIndex + 1)
                } else if let firstWorkingIndex = activity.sets.firstIndex(where: { $0.type == .working }) {
                    // If no warm-up sets yet, insert before first working set
                    activity.sets.insert(newSet, at: firstWorkingIndex)
                } else {
                    // If no sets at all, just append
                    activity.sets.append(newSet)
                }

                updateSortIndices()
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(systemName: "plus")
                    .foregroundStyle(Color.accentColor)
                Text("Add set")
                    .font(.lato(type: .regular, size: .subtitle))
                    .foregroundStyle(Color.accentColor)
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: horizontalSpacing, bottom: 0, trailing: horizontalSpacing))
    }

    /// The working section of the list.
    /// - Returns: The working section view.
    @ViewBuilder
    private func workingSection() -> some View {
        Text("\(activity.workingSets.count) working set\(activity.workingSets.count == 1 ? ":" : "s:")")
            .font(.lato(type: .light, size: .subtitle))
            .foregroundStyle(.ld)
            .listRowSeparator(.hidden)

        ForEach(Array(activity.workingSets.enumerated()), id: \.1.persistentModelID) { _, set in
            listItem(set: set)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        modelContext.delete(set)
                        updateSortIndices()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .listRowBackground(Color.clear)
        }
        .onMove(perform: moveWorkingSet)

        addWorkingSetButton()
    }

    /// The button view that includes the vertical line and button, for the working sets.
    /// - Returns: The working section view.
    @ViewBuilder
    private func addWorkingSetButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                let newSet = SetData(type: .working, parentActivity: activity, sortIndex: activity.sets.count + 1)
                // Just add to end of list since we display working last
                activity.sets.append(newSet)
                updateSortIndices()
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(systemName: "plus")
                    .foregroundStyle(Color.accentColor)
                Text("Add set")
                    .font(.lato(type: .regular, size: .subtitle))
                    .foregroundStyle(Color.accentColor)
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: horizontalSpacing, bottom: 0, trailing: horizontalSpacing))
    }

    // MARK: - List Item
    /// The row in the List of sets.
    /// - Parameters:
    ///   - set: The set that will be in a row.
    /// - Returns: The list item view.
    @ViewBuilder
    private func listItem(set: SetData) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                set.isComplete.toggle()
                try? modelContext.save()
            } label: {
                listItemButtonView(set: set)
            }
            .buttonStyle(.plain)
            .padding(.trailing, horizontalSpacing)

            // This blank text needs to be here so the list divider goes all the way to
            // the button, and doesn't stop at inbetween the textfields.
            Text("").frame(maxWidth: 0)

            // Reps field
            listItemRepsField(set: set)

            // Divider
            Text("/")
                .font(.lato())
                .foregroundStyle(.gray)
                .padding(.horizontal, horizontalSpacing * 2)
                .padding(.vertical, 20)

            // Weight field
            listItemWeightField(set: set)
        }
        .font(.lato(type: .bold))
        .listRowInsets(.init(top: 0, leading: horizontalSpacing, bottom: 0, trailing: horizontalSpacing))
    }

    /// The button view of each list item.
    /// - Parameter set: The set that determines how the button and its line looks.
    /// - Returns: Returns the complete view of the button.
    @ViewBuilder
    private func listItemButtonView(set: SetData) -> some View {
        let topLineFillColor: Color = {
            if set.sortIndex == 0 || activity.sortedSets.first(where: { $0.type == .working }) == set {
                return .clear // No line for the first set in a section
            }
            let previousSet = activity.sortedSets[set.sortIndex - 1]
            // Show green line if both sets are complete
            return set.isComplete && previousSet.isComplete ? .green : .gray
        }()

        let bottomLineFillColor: Color = {
            if activity.sortedSets.last == set || activity.sortedSets.last(where: { $0.type == .warmUp }) == set {
                return .clear // No line for the last set in a section
            }

            let nextSet = activity.sortedSets[set.sortIndex + 1]
            // Show green line if both sets are complete
            return set.isComplete && nextSet.isComplete ? .green : .gray
        }()

        VStack {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: lineCornerRadius,
                bottomTrailingRadius: lineCornerRadius,
                topTrailingRadius: 0
            )
            .fill(topLineFillColor)
            .frame(width: lineWidth)

            Image(systemName: set.isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(set.isComplete ? .green : .gray)
                .font(.lato(type: .regular, size: .subtitle))

            UnevenRoundedRectangle(
                topLeadingRadius: lineCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: lineCornerRadius
            )
            .fill(bottomLineFillColor)
            .frame(width: lineWidth)
        }
    }

    @ViewBuilder
    private func listItemRepsField(set: SetData) -> some View {
        let setId = set.persistentModelID

        HStack {
            TextField(
                "reps",
                text: Binding(
                    get: {
                        // Use the temporary value if we're editing, otherwise convert from model
                        return editingReps[setId] ?? "\(set.reps)"
                    },
                    set: { newValue in
                        // Store in temporary state only
                        editingReps[setId] = newValue.filter { $0.isNumber }
                    }
                )
            )
            .keyboardType(.numberPad)
            .focused($focusedField, equals: .reps(setId))
            .onChange(of: focusedField) { _, newFocus in
                if newFocus == .reps(setId) && editingReps[setId] == nil {
                    // Initialize editing value when field gets focus
                    editingReps[setId] = "\(set.reps)"
                }
            }
            // Listen for submit action to save
            // Not exactly sure when this is fired
            .onSubmit {
                print("Submit action fired")
                saveCurrentEdits()
            }
        }
        .padding(5)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    @ViewBuilder
    private func listItemWeightField(set: SetData) -> some View {
        let setId = set.persistentModelID

        HStack {
            TextField(
                "weight",
                text: Binding(
                    get: {
                        // Use the temporary value if we're editing, otherwise convert from model
                        return editingWeight[setId] ?? formatWeight(set.weight)
                    },
                    set: { newValue in
                        // Only allow numbers and decimal separator
                        let filtered = newValue.filter { $0.isNumber || String($0) == decimalSeparator }
                        editingWeight[setId] = filtered
                    }
                )
            )
            .keyboardType(.decimalPad)
            .focused($focusedField, equals: .weight(setId))
            .onChange(of: focusedField) { _, newFocus in
                if newFocus == .weight(setId) && editingWeight[setId] == nil {
                    // Initialize editing value when field gets focus
                    editingWeight[setId] = formatWeight(set.weight)
                }
            }
            // Listen for submit action to save
            // Not exactly sure when this is fired
            .onSubmit {
                print("Submit action fired")
                saveCurrentEdits()
            }
        }
        .padding(5)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - Helpers
extension ActivityView {
    /// Performs the move operation when the user drags an activity from one position to another in the list.
    /// This function maintains the proper sort order of sets by updating all sortIndex values.
    /// This works only for the warm up sets.
    /// Had a hard time understand this so Claude helped.
    /// - Parameters:
    ///   - source: The original `IndexSet` containing the indices of items to be moved.
    ///   - destination: The destination index where the items should be moved to.
    private func moveWarmUpSet(from source: IndexSet, to destination: Int) {
        // Create a mutable copy of the already sorted sets array
        // Even though this creates a new array, it contains references to the same SwiftData-managed
        // SetData objects, so modifying them here will update the actual objects in the database
        var sets = activity.sortedSets

        // Rearrange the items in our temporary array according to the drag operation
        sets.move(fromOffsets: source, toOffset: destination)

        // Update ALL sortIndex values to match the new order
        // Since SetData objects are reference types and tracked by SwiftData,
        // changing properties here directly updates the objects in the SwiftData store,
        // regardless of how we accessed them (through sortedSets or directly)
        for (index, set) in sets.enumerated() {
            set.sortIndex = index
        }

        // Save changes to ensure the updates are persisted
        try? modelContext.save()
        print("Move saved!")
    }

    /// Performs the move operation when the user drags an activity from one position to another in the list.
    /// This function maintains the proper sort order of sets by updating all sortIndex values.
    /// This works only for the working sets.
    /// Had a hard time understand this so Claude helped.
    /// - Parameters:
    ///   - source: The original `IndexSet` containing the indices of items to be moved.
    ///   - destination: The destination index where the items should be moved to.
    private func moveWorkingSet(from source: IndexSet, to destination: Int) {
        // Get all sets sorted by sortIndex
        var sets = activity.sortedSets

        // Calculate the offset (number of warm-up sets)
        let warmUpCount = activity.warmUpSets.count

        // Adjust the source indices and destination by adding the offset
        let adjustedSource = IndexSet(source.map { $0 + warmUpCount })
        let adjustedDestination = destination + warmUpCount

        // Perform the move on the full collection
        sets.move(fromOffsets: adjustedSource, toOffset: adjustedDestination)

        // Update ALL sortIndex values to match the new order
        for (index, set) in sets.enumerated() {
            set.sortIndex = index
        }

        // Save changes
        try? modelContext.save()
        print("Move saved!")
    }

    /// Rearrange the ``Activity`` indices.
    private func updateSortIndices() {
        // First, separate sets by type
        let warmUpSets = activity.warmUpSets
        let workingSets = activity.workingSets

        // Then update sort indices for all sets
        var index = 0

        // Update warm-up sets first
        for set in warmUpSets {
            set.sortIndex = index
            index += 1
        }

        // Then update working sets
        for set in workingSets {
            set.sortIndex = index
            index += 1
        }

        // Force a refresh of the activity sets by reassigning
        let updatedSets = activity.sets
        activity.sets = updatedSets

        try? modelContext.save()
    }

    /// Duplicate the set. Adds the new set right after the orginal one.
    /// - Parameter set: ``SetData`` object to be duplicated.
    private func duplicateSet(set: SetData) {
        let newSet = SetData(
            type: set.type,
            reps: set.reps,
            weight: set.weight,
            isComplete: false,
            parentActivity: activity,
            sortIndex: set.sortIndex + 1
        )

        // Insert the new set right after the current one
        if let index = activity.sets.firstIndex(where: { $0.persistentModelID == set.persistentModelID }) {
            activity.sets.insert(newSet, at: index + 1)
            updateSortIndices()
            try? modelContext.save()
        }
    }

    // Helper function to format weight for display
    /// Format the weight to a String representation
    /// - Parameter weight: A double that represents the weight.
    /// - Returns: The ``String`` representation of the weight.
    private func formatWeight(_ weight: Double) -> String {
        // Don't show decimal places if it's a whole number
        return weight.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(weight))" : "\(weight)"
    }

    /// Save the edits from the ``TextField``s to persistant storage.
    private func saveCurrentEdits() {
        guard let set = currentlyEditingSet else { return }
        let setId = set.persistentModelID

        // Save reps if we were editing them
        if let repsText = editingReps[setId], let reps = Int(repsText) {
            set.reps = reps
            editingReps.removeValue(forKey: setId)
        }

        // Save weight if we were editing it
        if let weightText = editingWeight[setId] {
            // Replace the decimal separator with a period for Double parsing
            let normalizedText = weightText.replacingOccurrences(of: decimalSeparator, with: ".")
            if let weight = Double(normalizedText) {
                set.weight = weight
            }
            editingWeight.removeValue(forKey: setId)
        }

        // Save changes to SwiftData
        try? modelContext.save()
        print("[\(Date.now)] Changes saved for set: \(setId.id)")
    }

    /// Moves the focus to the next set, respecting the selection of either reps or weight focus.
    /// If there is no next set, it will clear the focus.
    private func moveToNextSet() {
        guard let currentSet = currentlyEditingSet else { return }

        let currentIndex = activity.sortedSets.firstIndex { $0.persistentModelID == currentSet.persistentModelID } ?? -1
        if currentIndex == -1 || currentIndex >= activity.sortedSets.count - 1 {
            // If we're at the last set or can't determine current position, just clear focus
            focusedField = nil
            return
        }

        // Get the next set
        let nextSet = activity.sortedSets[currentIndex + 1]

        // Determine what field type we're currently on and focus the same field type in the next set
        if let focus = focusedField {
            switch focus {
            case .reps:
                // Currently on a reps field, focus next set's reps
                focusedField = .reps(nextSet.persistentModelID)
            case .weight:
                // Currently on a weight field, focus next set's weight
                focusedField = .weight(nextSet.persistentModelID)
            }
        }
    }
}

#Preview {
    ActivityView(
        activity: .constant(
            Activity(
                sets: [
                    SetData(type: .warmUp, reps: 10, weight: 20.0, isComplete: true, sortIndex: 0),
                    SetData(type: .warmUp, reps: 15, weight: 30.0, isComplete: false, sortIndex: 1),
                    SetData(type: .working, reps: 8, weight: 50.5, isComplete: false, sortIndex: 2),
                    SetData(type: .working, reps: 8, weight: 50.0, isComplete: false, sortIndex: 3),
                    SetData(type: .working, reps: 12, weight: 30.0, isComplete: false, sortIndex: 4)
                ],
                parentExercise: Exercise(name: "Bench Press"),
                parentWorkout: Workout(gym: "tester"), sortIndex: 0
            )
        ))
    .environment(\.font, .lato(type: .regular))
}
