//
//  ImportRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 4/27/25.
//

import SwiftUI

struct ImportRestoreView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

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
                Text("20")
                    .foregroundStyle(gradient)

            }
            .font(.lato(type: .bold))

            HStack {
                Text("Workouts:")
                Text("100")
                    .foregroundStyle(gradient)
                Spacer()
            }
            .font(.lato(type: .bold))

            HStack {
                Text("Activites:")
                Text("200")
                    .foregroundStyle(gradient)
                Spacer()
            }
            .font(.lato(type: .bold))

            HStack {
                Text("Sets:")
                Text("300")
                    .foregroundStyle(gradient)
                Spacer()
            }
            .font(.lato(type: .bold))
        }
        .padding(.horizontal, 15)

        ProgressView(value: 0.75) { Text("75% progress") }
            .padding(.horizontal, 15)

        VStack {
            Button {
                print("Restoring...")
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
    ImportRestoreView(importedFile: URL(filePath: "/path/to/file.swift"))
}
