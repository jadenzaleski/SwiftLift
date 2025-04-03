//
//  BackupRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 3/25/25.
//

import SwiftUI

struct BackupRestoreView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("doBackup") var doBackup: Bool = true
    @AppStorage("backupLength") var backupLength: Double = 7.0


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
                backupItem()
                backupItem()
            } header: {
                Text("Backups")
                    .font(.lato(type: .regular, size: .small))
            } footer: {
                Text("You may either download or restore your data from a" +
                     " previous backup. Swipe left on a backup to delete it.")
                    .font(.lato(type: .regular, size: .caption))
            }
        }
        .onAppear {
            let backupManager = BackupManager()
            backupManager.createBackup()

            let backups = backupManager.getBackups()
            for backup in backups {
                print("Backup: \(backup.filename), Date: \(backup.date), Size: \(backup.size) bytes")
            }
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
        } label: {
            Text("Back Up Now")
        }
        .font(.lato(type: .regular, size: .body))
    }

    @ViewBuilder
    private func backupItem() -> some View {
        HStack(spacing: 15) {
            Text(Date.now, format: .dateTime.day().month(.wide))
            Text("27.5MB")
                .font(.lato(type: .light, size: .caption))

            Spacer()
            Button {
                print("export")
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
            .buttonStyle(.plain)

            Button {
                print("restore")
            } label: {
                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
        }
        .font(.lato(type: .regular, size: .body))
    }
}


// MARK: - Helpers
extension BackupRestoreView {

}

#Preview {
    BackupRestoreView()
}
