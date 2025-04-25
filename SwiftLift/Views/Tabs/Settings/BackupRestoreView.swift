//
//  BackupRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 3/25/25.
//

import SwiftUI
import SwiftData

class BackupRestoreViewModel: ObservableObject {
    @Published var backups: [BackupMetadata] = []
    private(set) var backupManager: BackupManager

    init(context: ModelContext) {
        self.backupManager = BackupManager(context: context)
        loadBackups()
    }

    func loadBackups() {
        backups = backupManager.getBackups()
    }

    func createBackup() {
        backupManager.createBackup()
        loadBackups()
    }

    func deleteBackup(_ backup: BackupMetadata) {
        backupManager.deleteBackup(filename: backup.filename)
        loadBackups()
    }
}

struct BackupRestoreView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("doBackup") var doBackup: Bool = true
    @AppStorage("backupLength") var backupLength: Double = 7.0

    @StateObject private var viewModel: BackupRestoreViewModel

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
                if !viewModel.backups.isEmpty {
                    ForEach(viewModel.backups, id: \.filename) { backup in
                        backupItem(for: backup)
                    }
                    .onDelete(perform: deleteBackup)
                } else {
                    Text("No backups yet.")
                        .font(.lato(type: .regular, size: .body))
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
        .task {
            viewModel.createBackup()
        }
    }

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
                    .font(.lato(type: .regular, size: .body))
            }
        }
    }

    @ViewBuilder
    private func settingsSection() -> some View {
        VStack(alignment: .leading) {
            Text("Keep the latest \(Int(backupLength))" +
                 " backup\(Int(backupLength) == 1 ? "" : "s")")
            Slider(
                value: $backupLength,
                in: 1...30,
                step: 1
            )
        }
        .font(.lato(type: .regular, size: .body))

        Button {
            print("backing up...")
            DispatchQueue.main.async {
                viewModel.createBackup()
            }
        } label: {
            Text("Back Up Now")
        }
        .font(.lato(type: .regular, size: .body))
    }

    private func backupItem(for backup: BackupMetadata) -> some View {
        HStack(spacing: 15) {
            Text(backup.date, format: .dateTime.day().month(.wide).hour().minute())
            Text("\(ByteCountFormatter.string(fromByteCount: backup.size, countStyle: .file))")
                .font(.lato(type: .light, size: .caption))
                .foregroundStyle(.gray)

            Spacer()
            Button {
                print("export \(backup.filename)")
            } label: {
                Label("Export", systemImage: "square.and.arrow.down")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)

            Button {
                print("restore \(backup.filename)")
            } label: {
                Label("Restore", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.gray)
        }
        .font(.lato(type: .regular, size: .body))
    }
}

// MARK: - Helpers
extension BackupRestoreView {

    private func deleteBackup(at offsets: IndexSet) {
        for index in offsets {
            let backup = viewModel.backups[index]
            viewModel.deleteBackup(backup)
        }
    }
}

#Preview {
    BackupRestoreView(context: ModelContext(previewContainer))
}
