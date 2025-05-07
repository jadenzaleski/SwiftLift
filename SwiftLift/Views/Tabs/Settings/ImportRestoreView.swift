//
//  ImportRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/27/25.
//

import SwiftUI
import SwiftData

class ImportRestoreViewModel: ObservableObject {
    private let backupManager: BackupManager

    @Published var parsingProgress: Double = 0.0
    @Published var parsedExerciseCount: Int = 0
    @Published var parsedWorkoutCount: Int = 0
    @Published var parsedActivityCount: Int = 0
    @Published var parsedSetCount: Int = 0

    init(context: ModelContext) {
        self.backupManager = BackupManager(context: context)

        // Set up observation
        setupObservers()
    }

    private func setupObservers() {
        // Observe progress
        Task {
            for await progress in backupManager.$parsingProgress.values {
                await MainActor.run {
                    self.parsingProgress = progress
                }
            }
        }

        // Observe exercise count
        Task {
            for await count in backupManager.$parsedExerciseCount.values {
                await MainActor.run {
                    withAnimation {
                        self.parsedExerciseCount = count
                    }
                }
            }
        }

        // Observe workout count
        Task {
            for await count in backupManager.$parsedWorkoutCount.values {
                await MainActor.run {
                    withAnimation {
                        self.parsedWorkoutCount = count
                    }
                }
            }
        }

        // Observe activity count
        Task {
            for await count in backupManager.$parsedActivityCount.values {
                await MainActor.run {
                    withAnimation {
                        self.parsedActivityCount = count
                    }
                }
            }
        }

        // Observe set count
        Task {
            for await count in backupManager.$parsedSetCount.values {
                await MainActor.run {
                    withAnimation {
                        self.parsedSetCount = count
                    }
                }
            }
        }
    }

    func parseCSV(from file: URL) {
        print("Parsing CSV file...")
        backupManager.parseCSV(fileURL: file)
    }
}

struct ImportRestoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @StateObject private var viewModel: ImportRestoreViewModel

    init(importedFile: URL, context: ModelContext) {
        self.importedFile = importedFile
        _viewModel = StateObject(wrappedValue: ImportRestoreViewModel(context: context))
    }

    let importedFile: URL

    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        VStack {
            HStack {
                Text("Name")
                Spacer()
                Text(importedFile.lastPathComponent)
                    .foregroundStyle(.gray)
            }

            HStack {
                Text("Date")
                Spacer()
                Text(formattedFileDate)
                    .foregroundStyle(.gray)
            }

            HStack {
                Text("Size")
                Spacer()
                Text(formattedFileSize)
                    .foregroundStyle(.gray)
            }
        }
        .lineLimit(1)

        VStack {
            Text("Data Preview")

            HStack {
                Text("Exercises:")
                Spacer()
                Text("\(viewModel.parsedExerciseCount)")
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())

            }
            .font(.lato(type: .bold))

            HStack {
                Text("Workouts:")
                Spacer()
                Text("\(viewModel.parsedWorkoutCount)")
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Spacer()
            }
            .font(.lato(type: .bold))

            HStack {
                Text("Activites:")
                Spacer()
                Text("\(viewModel.parsedActivityCount)")
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Spacer()
            }
            .font(.lato(type: .bold))

            HStack {
                Text("Sets:")
                Spacer()
                Text("\(viewModel.parsedSetCount)")
                    .foregroundStyle(gradient)
                    .contentTransition(.numericText())
                Spacer()
            }
            .font(.lato(type: .bold))
        }
        .padding(.horizontal, 15)

        ProgressView(value: viewModel.parsingProgress) {
            Text("\(Int(viewModel.parsingProgress * 100))%")
        }
        .padding(.horizontal, 15)

        VStack {
            Button {
                print("Restoring...")
                viewModel.parseCSV(from: importedFile)
            } label: {
                Label("Restore", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
                    .padding(10)
            }
            .buttonStyle(.borderedProminent)
            .font(.lato(type: .bold))
        }
        .padding(.horizontal, 15)
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
}
