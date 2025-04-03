//
//  BackupManager.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/1/25.
//

import Foundation

class BackupManager {
    private let backupDirectory: URL

    init(directory: URL? = nil) {
        // Default to Documents/Backups/ if no custom directory is provided
        if let customDirectory = directory {
            self.backupDirectory = customDirectory
        } else {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.backupDirectory = documentsURL.appendingPathComponent("Backups")
        }

        createBackupDirectory()
    }

    /// Creates a simple test backup file
    func createBackup() {
        DispatchQueue.global(qos: .background).async {
            let filename = "TestBackup-\(self.formattedTimestamp()).txt"
            let fileURL = self.backupDirectory.appendingPathComponent(filename)
            let content = "This is a test backup file.\nCreated on \(Date())."

            do {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅ Backup saved at \(fileURL.path)")
            } catch {
                print("❌ Failed to save backup: \(error.localizedDescription)")
            }
        }
    }

    /// Retrieves all backups with date and size
    func getBackups() -> [(date: Date, size: Int64, filename: String)] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey], options: .skipsHiddenFiles)

            var backups: [(date: Date, size: Int64, filename: String)] = []

            for fileURL in fileURLs {
                let attributes = try fileURL.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])

                if let creationDate = attributes.creationDate, let fileSize = attributes.fileSize {
                    backups.append((date: creationDate, size: Int64(fileSize), filename: fileURL.lastPathComponent))
                }
            }

            return backups.sorted(by: { $0.date > $1.date }) // Sort by newest first
        } catch {
            print("Failed to get backups: \(error.localizedDescription)")
            return []
        }
    }

    /// Ensures the backup directory exists
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

    /// Formats the current timestamp for filenames
    private func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
}
