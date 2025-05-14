//
//  BackupManager.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/1/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Represents a row of workout backup data for CSV export.
///
/// Each property corresponds to a column in the exported CSV file.
/// Provides a ``description`` that generates a comma-separated line.
struct Row: CustomStringConvertible {
    let name: String?
    // Workout things
    let workoutStartDate: String?
    let workoutEndDate: String?
    let gym: String?
    // Activity things
    let activitySortIndex: Int?
    // Set things
    let type: String?
    let reps: Int?
    let weight: Double?
    let setSortIndex: Int?
    // Exercise things
    let exerciseNotes: String?
    // IDs
    let setID: String?
    let activityID: String?
    let workoutID: String?
    let exerciseID: String?
    /// Returns a CSV-formatted string representing this row.
    var description: String {
        var components: [String] = []

        components.append(name ?? "")
        components.append(workoutStartDate ?? "")
        components.append(workoutEndDate ?? "")
        components.append(gym ?? "")
        components.append(activitySortIndex.map(String.init) ?? "")
        components.append(type ?? "")
        components.append(reps.map(String.init) ?? "")
        components.append(weight.map { String($0) } ?? "")
        components.append(setSortIndex.map(String.init) ?? "")
        components.append(exerciseNotes ?? "")
        components.append(setID ?? "")
        components.append(activityID ?? "")
        components.append(workoutID ?? "")
        components.append(exerciseID ?? "")

        return components.joined(separator: ",") + "\n"
    }
}

/// Metadata describing a backup file.
///
/// Includes the creation date, file size, and filename.
struct BackupMetadata {
    let date: Date
    let size: Int64
    let filename: String
}

/// A manager responsible for creating, retrieving, deleting, and pruning SwiftData backups.
///
/// `BackupManager` writes backup data into CSV files, stored under the app's Documents/Backups directory by default.
/// It handles formatting, file creation, directory management, and cleanup of old backups.
///
/// - Warning: The restoration needs to be improved so it can run in the background and not freeze the UI.
/// The current implementation works, it just is not efficent at all. I need to learn more about concurrancy before I feel comfortable tackling this again.
class BackupManager {
    let backupDirectory: URL
    private let modelContext: ModelContext
    @Published var progressBarValue: Double = 0.0
    @Published var parsedExerciseCount: Int = 0
    @Published var parsedWorkoutCount: Int = 0
    @Published var parsedActivityCount: Int = 0
    @Published var parsedSetCount: Int = 0
    @Published var status: String = " "

    public final let header: [String] = ["Name", "WorkoutStartDate", "WorkoutEndDate",
                                         "Gym", "ActivitySortIndex", "Type", "Reps",
                                         "Weight", "SetSortIndex", "ExerciseNotes",
                                         "SetID", "ActivityID", "WorkoutID", "ExerciseID"]

    init(context: ModelContext, directory: URL? = nil) {
        self.modelContext = context
        // Default to Documents/Backups/ if no custom directory is provided
        if let customDirectory = directory {
            self.backupDirectory = customDirectory
        } else {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.backupDirectory = documentsURL.appendingPathComponent("Backups")
        }

        createBackupDirectory()
    }

    /// Creates a backup of all the custom SwiftData models.
    func createBackup() async throws {
        let filename = "swiftlift-backup-\(self.formattedTimestamp()).csv"
        let fileURL = self.backupDirectory.appendingPathComponent(filename)

        @AppStorage("backupLength") var backupLength: Double = 7.0
        if self.getBackups().count >= Int(backupLength) {
            self.pruneBackups(keepingAtLeast: Int(backupLength) - 1)
        }

        FileManager.default.createFile(atPath: fileURL.path, contents: nil)

        let fileHandle = try FileHandle(forWritingTo: fileURL)

        // Now write the content
        generateContent(to: fileHandle)

        try fileHandle.close()

        print("✅ Backup saved at \(fileURL.path)")
    }

    /// Deletes a backup file by its filename.
    /// - Parameter filename: The name of the backup file to delete.
    func deleteBackup(filename: String) {
        try? FileManager.default.removeItem(at: backupDirectory.appendingPathComponent(filename))
    }

    /// Retrieves all backups with date and size
    /// - Returns: Returns a list of ``BackupMetadata`` which are the backups.
    func getBackups() -> [BackupMetadata] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: backupDirectory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles)

            var backups: [BackupMetadata] = []

            for fileURL in fileURLs {
                let attributes = try fileURL.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])

                if let creationDate = attributes.creationDate, let fileSize = attributes.fileSize {
                    backups.append(BackupMetadata(date: creationDate, size: Int64(fileSize), filename: fileURL.lastPathComponent))
                }
            }

            return backups.sorted(by: { $0.date > $1.date }) // Sort by newest first
        } catch {
            print("Failed to get backups: \(error.localizedDescription)")
            return []
        }
    }

    /// Create the backup directory if needed.
    private func createBackupDirectory() {
        if !FileManager.default.fileExists(atPath: backupDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
                print("Created backup directory at \(backupDirectory.path)")
            } catch {
                print("Failed to create backup directory: \(error.localizedDescription)")
            }
        }
    }

    /// Formats the current timestamp for filenames.
    private func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: Date())
    }

    /// Writes the CSV content to the provided file handle.
    /// Fetches all ``SetData`` objects and serializes them into CSV rows.
    /// - Parameter fileHandle: The file handle to write to.
    private func generateContent(to fileHandle: FileHandle) {
        do {
            let sets = try modelContext.fetch(FetchDescriptor<SetData>())

            // Write header
            let headerLine = header.joined(separator: ",") + "\n"
            let headerData = Data(headerLine.utf8)
            fileHandle.write(headerData)

            // Now go through all the sets, populate a struct, and write.
            for set in sets {
                let parentActivity = set.parentActivity
                let parentWorkout = parentActivity?.parentWorkout
                let parentExercise = parentActivity?.parentExercise

                // we don't want to include workouts that are not done yet.
                if parentWorkout?.endDate == nil { continue }

                let row = Row(name: set.parentActivity?.name,
                              workoutStartDate: parentWorkout?.startDate?.ISO8601Format(),
                              workoutEndDate: parentWorkout?.startDate?.ISO8601Format(),
                              gym: parentWorkout?.gym,
                              activitySortIndex: parentActivity?.sortIndex,
                              type: set.type.rawValue,
                              reps: set.reps,
                              weight: set.weight,
                              setSortIndex: set.sortIndex,
                              exerciseNotes: parentExercise?.notes,
                              setID: "\(set.id.id)",
                              activityID: parentActivity != nil ? "\(parentActivity!.id.id)" : "",
                              workoutID: parentWorkout != nil ? "\(parentWorkout!.id.id)" : "",
                              exerciseID: parentExercise != nil ? "\(parentExercise!.id.id)" : "")

                let lineData = Data(row.description.utf8)
                fileHandle.write(lineData)
            }
        } catch {
            print("❌ Failed to fetch sets: \(error)")
        }
    }

    /// Deletes older backups, keeping only the most recent specified number.
    /// - Parameter count: The number of most recent backups to retain.
    func pruneBackups(keepingAtLeast count: Int) {
        let backups = getBackups()
        if backups.count > count {
            print("There are \(backups.count - count) backups to delete.")
            // Slice the array to only get backups after the specified count
            let backupsToDelete = backups.dropFirst(count)
            // Iterate over the backups to delete
            for backup in backupsToDelete {
                deleteBackup(filename: backup.filename)
                print("Deleted backup: \(backup.filename)")
            }
        }
    }

    /// Validate each line in the CSV file, making sure all the proper things are there and the correct type.
    /// This function is long but it is the simpliest way to write and understand it later.
    /// - Parameter line: The line to be validated
    /// - Returns: Returns a tuple of a ``Bool`` that indicates wether or not it is valid,
    /// and a ``String`` that will be the error message, if any.
    func validateCSVLine(_ line: String) -> (valid: Bool, error: String?) { // swiftlint:disable:this cyclomatic_complexity
        let columns = line.components(separatedBy: ",")
        // Make sure we have the correct number of columns
        if columns.count != header.count {
            return (false, "Invalid number of columns in line. Expected \(header.count), got \(columns.count).")
        }
        // Name
        if columns[0].isEmpty {
            return (false, "Name column is empty.")
        }
        // WorkoutStartDate
        if columns[1].isEmpty {
            return (false, "WorkoutStartDate column is empty.")
        } else {
            // If it's not empty, is it a valid date format
            if ISO8601DateFormatter().date(from: columns[1]) == nil {
                return (false, "WorkoutStartDate is not a valid ISO8601 date.")
            }
        }
        // WorkoutEndDate
        if columns[2].isEmpty {
            return (false, "WorkoutEndDate column is empty.")
        } else {
            // If it's not empty, is it a valid date formate
            if ISO8601DateFormatter().date(from: columns[2]) == nil {
                return (false, "WorkoutEndDate is not a valid ISO8601 date.")
            }
        }
        // Gym
        if columns[3].isEmpty {
            return (false, "Gym column is empty.")
        }
        // ActivitySortIndex
        if columns[4].isEmpty {
            return (false, "ActivitySortIndex column is empty.")
        } else {
            // Is it an Int
            if Int(columns[4]) == nil {
                return (false, "ActivitySortIndex is not a valid Int.")
            }
        }
        // Type
        if columns[5].isEmpty {
            return (false, "Type column is empty.")
        } else {
            // Is it a a string of "warmUp" or "working", case insensitive
            let lowercasedType = columns[5].lowercased()
            if lowercasedType != "warmup" && lowercasedType != "working" {
                return (false, "Type must be either 'warmUp' or 'working'.")
            }
        }
        // Reps
        if columns[6].isEmpty {
            return (false, "Reps column is empty.")
        } else {
            // Is it an Int
            if Int(columns[6]) == nil {
                return (false, "Reps is not a valid Int.")
            }
        }
        // Weight
        if columns[7].isEmpty {
            return (false, "Weight column is empty.")
        } else {
            // Is it a Double
            if Double(columns[7]) == nil {
                return (false, "Weight is not a valid Double.")
            }
        }
        // SetSortIndex
        if columns[8].isEmpty {
            return (false, "SetSortIndex column is empty.")
        } else {
            // Is it an Int
            if Int(columns[8]) == nil {
                return (false, "SetSortIndex is not a valid Int.")
            }
        }
        // ExerciseNotes, currently columns[9], can be empty.
        // SetID
        if columns[10].isEmpty {
            return (false, "SetID column is empty.")
        }
        // ActivityID
        if columns[11].isEmpty {
            return (false, "ActivityID column is empty.")
        }
        // WorkoutID
        if columns[12].isEmpty {
            return (false, "WorkoutID column is empty.")
        }
        // ExerciseID
        if columns[13].isEmpty {
            return (false, "ExerciseID column is empty.")
        }

        // All good, return true!
        return (true, nil)
    }
    
    /// This function parses the CSV file, checking it for errors, It also updates the the counts.
    /// - Parameter fileURL: The files to be parsed.
    func parseCSV(fileURL: URL) async {
        status = "Parsing CSV..."
        var didHeader = false
        var parsedWorkouts: Set<String> = []
        var parsedActivities: Set<String> = []
        var parsedExercises: Set<String> = []
        var parsedSets: Set<String> = []
        let time: Date = .now

        do {
            guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
                print("❌ Failed to open file")
                return
            }

            defer { try? fileHandle.close() }

            let totalSize = (
                try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? NSNumber
            )?.doubleValue ?? 0
            var totalRead: Double = 0
            var buffer = Data()

            while let chunk = try? fileHandle.read(upToCount: 4096), !chunk.isEmpty {
                // Check for task cancellation frequently
                if Task.isCancelled {
                    print("CSV parsing task was cancelled")
                    return
                }

                buffer.append(chunk)
                totalRead += Double(chunk.count)
                let progress = min(totalRead / totalSize, 1.0)

                // Update progress
                self.progressBarValue = progress

                // Process the buffer line by line
                while let range = buffer.range(of: Data([0x0A])) { // Newline character "\n"
                    // Check for cancellation during line processing too
                    if Task.isCancelled {
                        print("CSV parsing task was cancelled during line processing")
                        return
                    }

                    let lineData = buffer.subdata(in: 0..<range.lowerBound)
                    buffer.removeSubrange(0...range.lowerBound)

                    if let line = String(data: lineData, encoding: .utf8) {
                        // Skip header line
                        if !didHeader {
                            if line != header.joined(separator: ",") {
                                print("Invaild header.\nExpected: \(header.joined(separator: ","))\nFound: \(line)")
                                return
                            }
                            didHeader = true
                            continue
                        }
                        let validationResult = validateCSVLine(line)
                        if !validationResult.valid {
                            print("❌ Validation error: \(validationResult.error ?? "Unknown error")")
                            status = "Error: \(validationResult.error ?? "Unknown error")"
                            return
                        }
                        let columns = line.components(separatedBy: ",")
                        parsedSets.insert(columns[10])
                        parsedActivities.insert(columns[11])
                        parsedWorkouts.insert(columns[12])
                        parsedExercises.insert(columns[13])

                        // Only update the UI every so often to improve performance
                        if abs(time.timeIntervalSinceNow) > 0.25 {
                            parsedWorkoutCount = parsedWorkouts.count
                            parsedActivityCount = parsedActivities.count
                            parsedExerciseCount = parsedExercises.count
                            parsedSetCount = parsedSets.count
                        }
                    }
                }
            }

            // Final check for cancellation before updating the UI
            if Task.isCancelled {
                print("CSV parsing task was cancelled before final UI update")
                return
            }

            // We set these variables here to avoid swift concurrency issues
            let workoutCount = parsedWorkouts.count
            let activityCount = parsedActivities.count
            let exerciseCount = parsedExercises.count
            let setCount = parsedSets.count
            // Final UI update
            await MainActor.run {
                self.progressBarValue = 1.0
                self.parsedWorkoutCount = workoutCount
                self.parsedActivityCount = activityCount
                self.parsedExerciseCount = exerciseCount
                self.parsedSetCount = setCount
                self.status = "Parsing complete!"
                print("PARSING COMPLETE")
            }

            print("✅ Finished parsing CSV.")
        }
    }

    /// Struct that represents a single row of parsed data from the CSV file.
    /// This struct conforms to `Sendable` to ensure safe use across threads.
    struct ParsedLineData: Sendable {
        let exerciseID: String
        let workoutID: String
        let activityID: String
        let setID: String
        let name: String
        let workoutStartDate: Date?
        let workoutEndDate: Date?
        let gym: String
        let activitySortIndex: Int
        let setType: SetData.SetType
        let reps: Int
        let weight: Double
        let setSortIndex: Int
        let exerciseNotes: String?
    }

    /// Restores workout data from a CSV file located at `fileURL`.
    /// The CSV must follow a strict header and field format.
    ///
    /// This function:
    /// - Validates header and lines
    /// - Wipes existing database data
    /// - Parses and inserts new objects
    /// - Updates progress UI
    ///
    /// - Warning: This function needs to be rewritten to run on a background thread.
    /// Currently, everything runs on the main thread and is very klunky.
    /// I do not have a good enough understanding of Swift concurrancy and threads to feel comfortable rewriting this yet.
    /// This current implementation works but needs to be imporved.
    ///
    /// - Parameter fileURL: URL of the CSV file to restore.
    func restore(fileURL: URL) {
        status = "Restoring..."
        progressBarValue = 0.0

        let totalLines = parsedSetCount
        var processedLines = 0
        var time: Date = .now

        // Attempt to open file
        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
            print("❌ Failed to open file")
            status = "Failed to open file"
            return
        }

        defer { try? fileHandle.close() }

        // Wipe database before import
        wipeDatabase(modelContext: modelContext)

        var buffer = Data()
        var didHeader = false

        // Maps to prevent duplication and allow reuse
        var exercisesMap = [String: Exercise]()
        var workoutsMap = [String: Workout]()
        var activitiesMap = [String: Activity]()
        var setsMap = [String: SetData]()

        // Read file in chunks to handle large files efficiently
        while let chunk = try? fileHandle.read(upToCount: 4096), !chunk.isEmpty {
            buffer.append(chunk)

            // Process each line
            while let range = buffer.range(of: Data([0x0A])) { // Newline = 0x0A
                let lineData = buffer.subdata(in: 0..<range.lowerBound)
                buffer.removeSubrange(0...range.lowerBound)

                guard let line = String(data: lineData, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                      !line.isEmpty else {
                    continue
                }

                // Handle CSV header
                if !didHeader {
                    if line != header.joined(separator: ",") {
                        status = "Invalid header format"
                        return
                    }
                    didHeader = true
                    continue
                }

                // Validate line before parsing
                let validation = validateCSVLine(line)
                guard validation.valid else {
                    status = "Error: \(validation.error ?? "Unknown error")"
                    return
                }

                // Parse line into a structured object
                guard let parsedData = parseLine(line) else { continue }

                // === Begin Object Creation ===

                // Exercise
                let exercise = exercisesMap[parsedData.exerciseID] ?? {
                    let newExercise = Exercise(name: parsedData.name,
                                               notes: parsedData.exerciseNotes,
                                               activities: [])
                    exercisesMap[parsedData.exerciseID] = newExercise
                    modelContext.insert(newExercise)
                    return newExercise
                }()

                // Workout
                let workout = workoutsMap[parsedData.workoutID] ?? {
                    let newWorkout = Workout(startDate: parsedData.workoutStartDate,
                                             endDate: parsedData.workoutEndDate,
                                             gym: parsedData.gym,
                                             activities: [])
                    workoutsMap[parsedData.workoutID] = newWorkout
                    modelContext.insert(newWorkout)
                    return newWorkout
                }()

                // Activity
                let activity = activitiesMap[parsedData.activityID] ?? {
                    let newActivity = Activity(sets: [],
                                               parentExercise: exercise,
                                               parentWorkout: workout,
                                               sortIndex: parsedData.activitySortIndex)
                    activitiesMap[parsedData.activityID] = newActivity
                    exercise.activities.append(newActivity)
                    workout.activities.append(newActivity)
                    return newActivity
                }()

                // Set
                if setsMap[parsedData.setID] == nil {
                    let set = SetData(type: parsedData.setType,
                                      reps: parsedData.reps,
                                      weight: parsedData.weight,
                                      isComplete: true,
                                      parentActivity: activity,
                                      sortIndex: parsedData.setSortIndex)
                    setsMap[parsedData.setID] = set
                    activity.sets.append(set)
                }

                // === End Object Creation ===

                // Progress tracking
                processedLines += 1
                if abs(time.timeIntervalSinceNow) > 0.25 {
                    progressBarValue = Double(processedLines) / Double(totalLines)
                    status = "Processing: \(processedLines)/\(totalLines) items"
                    time = .now
                }
            }
        }

        // Final save
        do {
            try modelContext.save()
            progressBarValue = 1.0
            status = "Restoration complete!"
            print("✅ Finished restoring data from CSV.")
        } catch {
            status = "Error saving data: \(error.localizedDescription)"
            print("❌ Failed to save context: \(error)")
        }
    }

    /// Parses a single line of CSV into a structured `ParsedLineData` object.
    /// The order of CSV columns must be consistent.
    ///
    /// - Parameter line: The CSV line string.
    /// - Returns: ParsedLineData or nil if invalid.
    private func parseLine(_ line: String) -> ParsedLineData? {
        let columns = line.components(separatedBy: ",")

        guard columns.count >= 14 else { return nil }

        let exerciseID = columns[13]
        let workoutID = columns[12]
        let activityID = columns[11]
        let setID = columns[10]

        let name = columns[0]
        let workoutStartDate = ISO8601DateFormatter().date(from: columns[1])
        let workoutEndDate = ISO8601DateFormatter().date(from: columns[2])
        let gym = columns[3]
        let activitySortIndex = Int(columns[4]) ?? 0
        let setType = columns[5].lowercased() == "warmup" ? SetData.SetType.warmUp : SetData.SetType.working
        let reps = Int(columns[6]) ?? 0
        let weight = Double(columns[7]) ?? 0.0
        let setSortIndex = Int(columns[8]) ?? 0
        let exerciseNotes = columns[9].isEmpty ? nil : columns[9]

        return ParsedLineData(
            exerciseID: exerciseID,
            workoutID: workoutID,
            activityID: activityID,
            setID: setID,
            name: name,
            workoutStartDate: workoutStartDate,
            workoutEndDate: workoutEndDate,
            gym: gym,
            activitySortIndex: activitySortIndex,
            setType: setType,
            reps: reps,
            weight: weight,
            setSortIndex: setSortIndex,
            exerciseNotes: exerciseNotes
        )
    }

    /// Deletes all existing model data from the database.
    /// This function should be called before importing new data.
    ///
    /// - Parameter modelContext: The model context to operate on.
    func wipeDatabase(modelContext: ModelContext) {
        do {
            // Delete all Activity objects first (cascade expected)
            let activities = try modelContext.fetch(FetchDescriptor<Activity>())
            for activity in activities {
                modelContext.delete(activity)
            }

            try modelContext.save()

            // Batch delete all entities
            try modelContext.delete(model: SetData.self)
            try modelContext.delete(model: Activity.self)
            try modelContext.delete(model: Workout.self)
            try modelContext.delete(model: Exercise.self)

            try modelContext.save()

            print("🧹 Database successfully wiped")
        } catch {
            status = "Error"
            print("❌ Error wiping database: \(error)")
        }
    }
}
