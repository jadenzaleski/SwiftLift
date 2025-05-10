//
//  ImportRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/27/25.
//

import SwiftUI
import SwiftData

class ImportRestoreViewModel: ObservableObject {
    private var backupManager: BackupManager?
    private var tasks: [Task<Void, Never>] = []
    private var parseTask: Task<Void, Never>?

    @Published var progressBarValue: Double = 0.0
    @Published var parsedExerciseCount: Int = 0
    @Published var parsedWorkoutCount: Int = 0
    @Published var parsedActivityCount: Int = 0
    @Published var parsedSetCount: Int = 0
    @Published var isParsingCancelled: Bool = false

    init(context: ModelContext) {
        self.backupManager = BackupManager(context: context)

        // Set up observation
        setupObservers()
    }

    private func setupObservers() {
        tasks.append(Task {
            for await progress in backupManager!.$progressBarValue.values {
                if !Task.isCancelled {
                    await MainActor.run {
                        withAnimation {
                            self.progressBarValue = progress
                        }
                    }
                }
            }
        })

        tasks.append(Task {
            for await count in backupManager!.$parsedExerciseCount.values {
                if !Task.isCancelled {
                    await MainActor.run {
                        withAnimation {
                            self.parsedExerciseCount = count
                        }
                    }
                }
            }
        })

        tasks.append(Task {
            for await count in backupManager!.$parsedWorkoutCount.values {
                if !Task.isCancelled {
                    await MainActor.run {
                        withAnimation {
                            self.parsedWorkoutCount = count
                        }
                    }
                }
            }
        })

        tasks.append(Task {
            for await count in backupManager!.$parsedActivityCount.values {
                if !Task.isCancelled {
                    await MainActor.run {
                        withAnimation {
                            self.parsedActivityCount = count
                        }
                    }
                }
            }
        })

        tasks.append(Task {
            for await count in backupManager!.$parsedSetCount.values {
                if !Task.isCancelled {
                    await MainActor.run {
                        withAnimation {
                            self.parsedSetCount = count
                        }
                    }
                }
            }
        })
    }

    func parseCSV(from file: URL) {
        print("Parsing CSV file...")

        // Cancel any existing parse task
        parseTask?.cancel()

        // Create a new parse task
        parseTask = Task {
            // Check if the task is cancelled before starting
            guard !Task.isCancelled else {
                print("Task cancelled before starting")
                return
            }

            // Start the parsing operation
            await backupManager?.parseCSV(fileURL: file)

            // Check if we were cancelled during parsing
            if Task.isCancelled {
                print("CSV parsing was cancelled")
                await MainActor.run {
                    self.isParsingCancelled = true
                }
            } else {
                print("CSV parsing completed normally")
            }
        }

        // Add the task to our task list
        if let parseTask = parseTask {
            tasks.append(parseTask)
        }
    }

    func cleanup() {
        print("Cleaning up ImportRestoreViewModel")

        // Cancel each task individually
        tasks.forEach { task in
            task.cancel()
            print("Cancelled a task")
        }

        // Also cancel the parse task specifically
        parseTask?.cancel()

        // Clear the arrays
        tasks.removeAll()
        parseTask = nil

        // Release the backup manager
        backupManager = nil

        print("Cleanup complete")
    }

    var status: String {
        backupManager?.status ?? ""
    }
}

struct ImportRestoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]
    @Query private var activities: [Activity]
    @Query private var sets: [SetData]

    @StateObject private var viewModel: ImportRestoreViewModel

    init(importedFile: URL, context: ModelContext) {
        self.importedFile = importedFile
        _viewModel = StateObject(wrappedValue: ImportRestoreViewModel(context: context))
    }

    let importedFile: URL

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
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
                .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .lightGray).opacity(0.5), radius: 5, x: 0, y: 5)
        )
        .padding()

        VStack {
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
            .padding()

            ProgressView(value: viewModel.progressBarValue) {
                Text(viewModel.status)
                    .font(.lato(size: .caption))
                    .foregroundStyle(.gray)
            }
            .padding([.leading, .bottom, .trailing])
            .tint(viewModel.progressBarValue == 1.0 ? .green : .accentColor)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("offset"))
                .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .lightGray).opacity(0.5), radius: 5, x: 0, y: 5)
        )
        .padding(.horizontal)

        VStack {
            Button {
                print("Restoring...")
                //                viewModel.parseCSV(from: importedFile)
            } label: {
                Label("Restore", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .foregroundStyle(.mainSystem)
            }
            //            .disabled(viewModel.parsingProgress != 1.0)
            .font(.lato(type: .bold))
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor)
                .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : .secondary, radius: 5, x: 0, y: 5)
            )
        }
        .padding()
        .onAppear {
            print("View has appeared - parsing csv")
            viewModel.parseCSV(from: importedFile)
        }
        .onDisappear {
            print("View is disappearing - cleaning up resources")
            viewModel.cleanup()
        }

        Spacer()
    }
}

// MARK: Utils
extension ImportRestoreView {
    private var fileAttributes: [FileAttributeKey: Any]? {
        try? FileManager.default.attributesOfItem(atPath: importedFile.path)
    }

    private var formattedFileSize: String {
        if let size = fileAttributes?[.size] as? NSNumber {
            return ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
        } else {
            return "Unknown"
        }
    }

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
