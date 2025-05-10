//
//  BackupRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 3/25/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Foundation

/// A view model that manages the creation, retrieval, and deletion of backup files.
///
/// ``BackupRestoreViewModel`` interacts with ``BackupManager`` to perform backup operations and provides
/// backup data to the SwiftUI view. It ensures the UI stays updated after changes.
@MainActor
class BackupRestoreViewModel: ObservableObject {
    @Published var backups: [BackupMetadata] = []
    private(set) var backupManager: BackupManager

    /// Initializes the view model with a given ``ModelContext`` and loads existing backups.
    /// - Parameter context: The SwiftData ``ModelContext`` used by the `BackupManager`.
    init(context: ModelContext) {
        self.backupManager = BackupManager(context: context)
        loadBackups()
    }

    /// Loads the list of existing backups from the backup directory.
    /// Updates the published ``backups`` array.
    func loadBackups() {
        backups = backupManager.getBackups()
    }

    /// Creates a new backup asynchronously and refreshes the backup list.
    /// Prints an error message if backup creation fails.
    func createBackup() async {
        do {
            try await backupManager.createBackup()
            loadBackups()
        } catch {
            print("Failed to create backup: \(error)")
        }
    }

    /// Deletes a specified backup file and refreshes the backup list.
    /// - Parameter backup: The ``BackupMetadata`` representing the file to delete.
    func deleteBackup(_ backup: BackupMetadata) {
        backupManager.deleteBackup(filename: backup.filename)
        loadBackups()
    }

    /// Returns the full URL for a given backup filename.
    /// - Parameter filename: The name of the backup file.
    /// - Returns: A ``URL`` pointing to the backup file.
    func backupURL(for filename: String) -> URL {
        return backupManager.backupDirectory.appendingPathComponent(filename)
    }

    /// Deletes old backups to keep only the specified number of most recent backups.
    /// Refreshes the backup list after pruning.
    /// - Parameter keeping: The minimum number of backups to retain.
    func pruneBackups(keeping: Int) {
        backupManager.pruneBackups(keepingAtLeast: keeping)
        loadBackups()
    }
}

/// A ``FileDocument`` that wraps an existing file on disk for export.
///
/// ``BackupExportDocument`` enables the app to export backup files using SwiftUI's ``fileExporter``.
/// It reads the file from the provided ``fileURL`` and packages it into a ``FileWrapper`` for export.
struct BackupExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText, .data, .item, .zip] }
    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    init(configuration: ReadConfiguration) throws {
        fatalError("Not implemented")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: fileURL, options: .immediate)
    }
}

struct IdentifiableURL: Identifiable {
    let id: String
    let url: URL

    init(_ url: URL) {
        self.url = url
        self.id = url.absoluteString
    }
}

struct BackupRestoreView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage("doBackup") var doBackup: Bool = true
    @AppStorage("backupLength") var backupLength: Double = 7.0

    @StateObject private var viewModel: BackupRestoreViewModel
    /// This will be the selected file to export.
    @State private var fileToExport: URL?
    /// The boolean to indicate wether or not the export view is being shown.
    @State private var isExporting: Bool = false
    /// The boolean to indicate wether or not we show the delete alert.
    @State private var showDeleteAlert: Bool = false
    /// Boolean to indicate wether or not we show the import sheet.
    @State private var showImporter: Bool = false
    /// The file that will be used to restore from.
    @State private var importedFile: IdentifiableURL?
    /// The maximum amount of backups the user can have.
    private let maxBackupLength: Double = 30.0

    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: BackupRestoreViewModel(context: context))
    }

    var body: some View {
        List {
            Section {
                headerSection()
            }

            Section {
                settingsSection()
            } footer: {
                Text("Last successful backup: \(Date().formatted())")
                    .font(.lato(type: .regular, size: .caption))
            }

            Section {
                Button {
                    showImporter.toggle()
                } label: {
                    Text("Import")
                }
                .fileImporter(
                    isPresented: $showImporter,
                    allowedContentTypes: [.commaSeparatedText, .data],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let selectedURL = urls.first {
                            importedFile = IdentifiableURL(selectedURL)                        }
                    case .failure(let error):
                        print("Failed to import file: \(error)")
                    }
                }
            } footer: {
                (Text("You may import your data from a backup file," +
                      " or restore it from a previous backup by tapping the restore (") +
                 Text(Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")) +
                 Text(") icon.")
                )
                .font(.lato(type: .regular, size: .caption))
            }

            Section {
                if !viewModel.backups.isEmpty {
                    ForEach(viewModel.backups, id: \.filename) { backup in
                        backupItem(for: backup)
                    }
                    .onDelete(perform: deleteBackup)
                } else {
                    Text("No backups yet.")
                }
            } header: {
                Text("Backups")
                    .font(.lato(type: .regular, size: .small))
            } footer: {
                Text("You may either download or restore your data from a" +
                     " previous backup. Swipe left on a backup to delete it.")
                .font(.lato(type: .regular, size: .caption))
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: fileToExport.map { BackupExportDocument(fileURL: $0) },
            contentType: .commaSeparatedText,
            defaultFilename: fileToExport?.lastPathComponent
        ) { result in
            switch result {
            case .success:
                print("Exported successfully.")
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
        }
        .sheet(item: $importedFile) { identifiable in
            ImportRestoreView(importedFile: identifiable.url, context: modelContext)
                .presentationDragIndicator(.visible)
        }
    }

    /// The header for the backup.
    /// This shows the description and the toggle for doing backups.
    /// - Returns: The header view to be put in a ``Section``
    @ViewBuilder
    private func headerSection() -> some View {
        VStack(alignment: .center) {
            Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                .padding(10.0)
                .font(.lato(type: .regular, size: .title))
                .background(Color.accentColor)
                .foregroundStyle(Color.mainSystem)
                .clipShape(Circle())
                .padding(.top, 5.0)
            Text("Backup")
                .font(.lato(type: .bold, size: .subtitle))
                .padding(.bottom, 5.0)
            Text("Swiftlift will backup your workouts locally after every workout you complete." +
                 " Your workouts are saved for a specified amount of time, and then deleted.")
            .multilineTextAlignment(.center)
            .font(.lato(type: .light, size: .small))

        }
        HStack {
            Toggle(isOn: $doBackup) {
                Text("Backup Workouts")
            }
        }
    }

    /// The setting section within the main view.
    /// This also contains all of the logic and code fro the slider and alert that will show up conditionally.
    /// - Returns: The settings view to be put in a ``Section``.
    @ViewBuilder
    private func settingsSection() -> some View {
        // The slider
        VStack(alignment: .leading) {
            Text("Keep the latest\(backupLength != 1  ? " " + String(Int(backupLength)) : "")" +
                 " backup\(Int(backupLength) == 1 ? "" : "s")")
            Slider(
                value: $backupLength,
                in: 1...maxBackupLength,
                step: 1,
                onEditingChanged: { editing in
                    // When its done moving, see if we need to how the alert to delete.
                    if !editing && viewModel.backups.count > Int(backupLength) {
                        // This will trigger when the user releases the slider
                        print("Slider editing ended - value: \(backupLength)")
                        showDeleteAlert.toggle()
                    }
                }
            )
            // The alert will delete the oldest x number of backups
            .alert(isPresented: $showDeleteAlert) {
                let count = Int(viewModel.backups.count) - Int(backupLength)
                let singleText = "Are you sure you want to delete the oldest backup?"
                let multipleText = "Are you sure you want to delete the oldest \(count) backups?"
                return Alert(title: Text("Delete backups"),
                             message: Text(count > 1 ? multipleText : singleText),
                             primaryButton: .destructive(Text("Delete")) {
                    viewModel.pruneBackups(keeping: Int(backupLength))
                },
                             secondaryButton: .cancel(Text("Cancel")) {
                    // Just set it to the current count if the user cancels
                    backupLength = min(Double(viewModel.backups.count), maxBackupLength)
                    print("Canceled, set backup length to " + String(backupLength))

                }
                )
            }
        }
        .font(.lato(type: .regular, size: .body))
        // Back up right now button
        Button {
            print("backing up...")
            Task {
                await viewModel.createBackup()
            }
        } label: {
            Text("Back Up Now")
        }
    }

    /// The view for each of the backup items in the list
    /// - Parameter backup: the backup to display.
    /// - Returns: The backup item ``HStack`` for the list to display.
    private func backupItem(for backup: BackupMetadata) -> some View {
        HStack(spacing: 20) {
            Text(backup.date, format: .dateTime.day().month().hour().minute())
            // Display the size of the file
            Text("\(ByteCountFormatter.string(fromByteCount: backup.size, countStyle: .file))")
                .font(.lato(type: .light, size: .caption))
                .foregroundStyle(.gray)
            Spacer()
            // Export button
            Button {
                print("export \(backup.filename)")
                fileToExport = viewModel.backupURL(for: backup.filename)
                isExporting = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.down")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(Color.accentColor)
            // Restore button
            Button {
                let urlToRestore = viewModel.backupURL(for: backup.filename)
                // Now set the importedFile with the pre-fetched URL
                importedFile = IdentifiableURL(urlToRestore)
                print("restore \(backup.filename)")
            } label: {
                Label("Restore", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(Color.accentColor)
        }
        .font(.lato(type: .regular, size: .body))
    }
}

// MARK: - Helpers
extension BackupRestoreView {
    /// Delete a backup from the list.
    /// - Parameter offsets: The offest from the list to delete.
    private func deleteBackup(at offsets: IndexSet) {
        for index in offsets {
            let backup = viewModel.backups[index]
            viewModel.deleteBackup(backup)
        }
    }
}

#Preview {
    BackupRestoreView(context: ModelContext(previewContainer))
        .environment(\.font, .lato())
}
