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
/// Usage:
/// - Call ``createBackup()`` to create a new backup.
/// - Use ``getBackups()`` to retrieve available backups.
/// - Use ``deleteBackup(filename:)`` to delete specific backups.
/// - Use ``pruneBackups(keepingAtLeast:)`` to limit the number of stored backups.
class BackupManager {
    let backupDirectory: URL
    private let modelContext: ModelContext

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
}
