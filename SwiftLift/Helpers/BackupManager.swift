//
//  BackupManager.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/1/25.
//

import Foundation
import SwiftData
import SwiftUI

/// This struct will represent a csv row of the exported data. Each item represents a column.
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

struct BackupMetadata {
    let date: Date
    let size: Int64
    let filename: String
}

class BackupManager {
    private let backupDirectory: URL
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
    func createBackup() {
        DispatchQueue.global(qos: .background).async {
            let filename = "swiftlift-backup-\(self.formattedTimestamp()).csv"
            let fileURL = self.backupDirectory.appendingPathComponent(filename)

            // Create the file
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)

            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)

                // Stream the content
                self.generateContent(to: fileHandle)

                try fileHandle.close()
                print("✅ Backup saved at \(fileURL.path)")
            } catch {
                print("❌ Failed to save backup: \(error.localizedDescription)")
            }
        }
    }

    /// Retrieves all backups with date and size
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
}
