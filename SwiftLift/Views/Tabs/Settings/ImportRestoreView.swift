//
//  ImportRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/27/25.
//

import SwiftUI
import SwiftData

/// View model for handling the import and restore process from a CSV file.
///
/// Manages parsing, restoring, progress tracking, and cleanup for the import/restore workflow.
class ImportRestoreViewModel: ObservableObject {
    private var backupManager: BackupManager?
    private var tasks: [Task<Void, Never>] = []
    private var parseTask: Task<Void, Never>?
    private var restoreTask: Task<Void, Never>?

    @Published var progressBarValue: Double = 0.0
    @Published var parsedExerciseCount: Int = 0
    @Published var parsedWorkoutCount: Int = 0
    @Published var parsedActivityCount: Int = 0
    @Published var parsedSetCount: Int = 0
    @Published var isParsingCancelled: Bool = false

    /// Initializes the view model with a model context and sets up observers.
    /// - Parameter context: The SwiftData model context to use for restore operations.
    init(context: ModelContext) {
        self.backupManager = BackupManager(context: context)
        // Set up observation of backupManager's published values for UI updates.
        setupObservers()
    }

    /// Sets up observation tasks for published properties in the backup manager.
    /// Each property is observed in a separate task, and updates are dispatched to the main actor.
    private func setupObservers() {
        // Observe progress bar value changes.
        tasks.append(Task {
            for await progress in backupManager!.$progressBarValue.values where !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        self.progressBarValue = progress
                    }
                }
            }
        })
        // Observe parsed exercise count.
        tasks.append(Task {
            for await count in backupManager!.$parsedExerciseCount.values where !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        self.parsedExerciseCount = count
                    }
                }
            }
        })
        // Observe parsed workout count.
        tasks.append(Task {
            for await count in backupManager!.$parsedWorkoutCount.values where !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        self.parsedWorkoutCount = count
                    }
                }
            }
        })
        // Observe parsed activity count.
        tasks.append(Task {
            for await count in backupManager!.$parsedActivityCount.values where !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        self.parsedActivityCount = count
                    }
                }
            }
        })
        // Observe parsed set count.
        tasks.append(Task {
            for await count in backupManager!.$parsedSetCount.values where !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        self.parsedSetCount = count
                    }
                }
            }
        })
    }

    /// Begins parsing the provided CSV file asynchronously.
    /// Cancels any existing parse operation before starting a new one.
    /// - Parameter file: The URL to the CSV file to parse.
    func parseCSV(from file: URL) {
        print("Parsing CSV file...")

        // Cancel any existing parse task before starting a new one.
        parseTask?.cancel()

        // Launch a new parse operation in a Task.
        parseTask = Task {
            // If the task was cancelled before starting, exit early.
            guard !Task.isCancelled else {
                print("Task cancelled before starting")
                return
            }

            // Start the parsing operation using the backup manager.
            await backupManager?.parseCSV(fileURL: file)

            // Handle cancellation during parsing.
            if Task.isCancelled {
                print("CSV parsing was cancelled")
                await MainActor.run {
                    self.isParsingCancelled = true
                }
            } else {
                print("CSV parsing completed normally")
            }
        }

        // Add the new parse task to the tasks array for lifecycle management.
        if let parseTask = parseTask {
            tasks.append(parseTask)
        }
    }

    /// Performs the restore operation from the provided CSV file.
    /// - Parameter file: The URL to the CSV file to restore from.
    func restore(from file: URL) {
        print("Restoring from CSV file...")
        backupManager?.restore(fileURL: file)
    }

    /// Cleans up all observation and parsing tasks and releases resources.
    ///
    /// Should be called when the view is disappearing or the view model is deinitialized.
    func cleanup() {
        print("Cleaning up ImportRestoreViewModel")

        // Cancel each observation task individually, including parse and restore tasks.
        tasks.forEach { task in
            task.cancel()
            print("Cancelled a task")
        }
        parseTask?.cancel()
        restoreTask?.cancel()
        // Clear the arrays and release the backup manager.
        tasks.removeAll()
        parseTask = nil
        restoreTask = nil
        backupManager = nil

        print("Cleanup complete")
    }

    /// The current status message provided by the backup manager.
    var status: String {
        backupManager?.status ?? " "
    }
}

/// View for importing and restoring data from a CSV backup file.
///
/// Displays file info, import/restore stats, and allows the user to trigger a restore.
struct ImportRestoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]
    @Query private var activities: [Activity]
    @Query private var sets: [SetData]

    @StateObject private var viewModel: ImportRestoreViewModel

    /// The URL of the imported CSV file.
    let importedFile: URL

    /// Gradient used for statistics highlighting.
    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    /// Initializes the import/restore view.
    /// - Parameters:
    ///   - importedFile: The URL of the file to import.
    ///   - context: The SwiftData model context to use.
    init(importedFile: URL, context: ModelContext) {
        self.importedFile = importedFile
        _viewModel = StateObject(wrappedValue: ImportRestoreViewModel(context: context))
    }

    var body: some View {
        header()
            .padding()

        VStack {
            grid()
                .padding()

            ProgressView(value: viewModel.progressBarValue) {
                Text(viewModel.status)
                    .font(.lato(size: .caption))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            .padding([.leading, .bottom, .trailing])
            .tint(viewModel.progressBarValue == 1.0 ? .green : .accentColor)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("offset"))
                .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) :
                            Color(uiColor: .lightGray).opacity(0.5), radius: 5, x: 0, y: 5)
        )
        .padding(.horizontal)

        restoreButton()
            .padding()
        // Start parsing the CSV file when the view appears.
            .onAppear {
                print("View has appeared - parsing csv")
                viewModel.parseCSV(from: importedFile)
            }
        // Clean up all tasks and resources when the view disappears.
            .onDisappear {
                print("View is disappearing - cleaning up resources")
                viewModel.cleanup()
            }

        Spacer()
    }

    /// Displays the file metadata header (name, date, size).
    @ViewBuilder
    private func header() -> some View {
        VStack(spacing: 5) {
            HStack {
                Text("Name")
                    .font(.lato(type: .bold))

                Spacer()
                Text(importedFile.lastPathComponent)
                    .foregroundStyle(.gray)
            }

            HStack {
                Text("Date")
                    .font(.lato(type: .bold))

                Spacer()
                Text(formattedFileDate)
                    .foregroundStyle(.gray)
            }

            HStack {
                Text("Size")
                    .font(.lato(type: .bold))

                Spacer()
                Text(formattedFileSize)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .lineLimit(1)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("offset"))
                .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) :
                            Color(uiColor: .lightGray).opacity(0.5), radius: 5, x: 0, y: 5)
        )
    }

    /// Displays a grid comparing imported and current entity counts.
    @ViewBuilder
    private func grid() -> some View {
        Grid(horizontalSpacing: 30) {
            GridRow {
                Text("")
                    .gridColumnAlignment(.leading)
                Text("Imported")
                    .font(.lato(type: .bold))
                Text("Current")
                    .foregroundStyle(.gray)
            }
            Divider()
            GridRow {
                Text("Exercises")
                    .font(.lato(type: .bold))
                Text("\(viewModel.parsedExerciseCount)")
                    .font(.lato(type: .bold))
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Text("\(exercises.count)")
                    .foregroundStyle(.gray)
                    .contentTransition(.numericText())
            }
            Divider()
            GridRow {
                Text("Workouts")
                    .font(.lato(type: .bold))
                Text("\(viewModel.parsedWorkoutCount)")
                    .font(.lato(type: .bold))
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Text("\(workouts.count)")
                    .foregroundStyle(.gray)
                    .contentTransition(.numericText())
            }
            Divider()
            GridRow {
                Text("Activities")
                    .font(.lato(type: .bold))
                Text("\(viewModel.parsedActivityCount)")
                    .font(.lato(type: .bold))
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Text("\(activities.count)")
                    .foregroundStyle(.gray)
                    .contentTransition(.numericText())
            }
            Divider()
            GridRow {
                Text("Sets")
                    .font(.lato(type: .bold))
                Text("\(viewModel.parsedSetCount)")
                    .font(.lato(type: .bold))
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Text("\(sets.count)")
                    .foregroundStyle(.gray)
                    .contentTransition(.numericText())
            }
        }
    }

    /// Builds the restore button.
    ///
    /// The button is only enabled when the progress bar has reached 100% (i.e., parsing is complete).
    @ViewBuilder
    private func restoreButton() -> some View {
        Button {
            viewModel.progressBarValue = 0.0
            viewModel.restore(from: importedFile)
        } label: {
            Label("Restore", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity)
                .padding(15)
            // Dim the button if parsing is not complete.
                .foregroundStyle(viewModel.progressBarValue != 1.0 ? .mainSystem.opacity(0.45) : .mainSystem)
        }
        // Only enable the button if parsing is complete.
        .disabled(viewModel.progressBarValue != 1.0)
        .font(.lato(type: .bold))
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.accentColor)
            .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) :
                    .secondary, radius: 5, x: 0, y: 5)
        )
    }
}

// MARK: Utils
extension ImportRestoreView {
    /// Returns file attributes for the imported file, if available.
    private var fileAttributes: [FileAttributeKey: Any]? {
        try? FileManager.default.attributesOfItem(atPath: importedFile.path)
    }

    /// Returns a formatted file size string for the imported file.
    private var formattedFileSize: String {
        if let size = fileAttributes?[.size] as? NSNumber {
            return ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
        } else {
            return "Unknown"
        }
    }

    /// Returns a formatted creation date string for the imported file.
    private var formattedFileDate: String {
        if let date = fileAttributes?[.creationDate] as? Date {
            return date.formatted(date: .abbreviated, time: .shortened)
        } else {
            return "Unknown"
        }
    }
}

#Preview {
    ImportRestoreView(importedFile: URL(filePath: "/path/to/file.swift"), context: ModelContext(previewContainer))
        .environment(\.font, .lato())

}
