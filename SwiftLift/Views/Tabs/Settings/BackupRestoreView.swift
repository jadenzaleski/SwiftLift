//
//  BackupRestoreView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 3/25/25.
//

import SwiftUI

struct BackupRestoreView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 30) {
            Button {
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(Color.offset)
                        .frame(width: 120)
                    VStack {
                        Image(systemName: "arrow.circlepath")
                        Text("Backup")
                    }
                }
                .shadow(radius: 10)

            }

            Button {
                
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(Color.offset)
                        .frame(width: 120)
                        .shadow(color: colorScheme == .dark ? Color(uiColor: .systemGray6) : .secondary, radius: 8, x: 0, y: 8)
                    VStack {
                        Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                            .font(.lato(type: .regular, size: .heading))
                        Text("Restore")
                            .font(.lato(type: .bold, size: .medium))

                    }
                }
            }
        }
        .font(.lato(type: .regular, size: .body))
    }
}

#Preview {
    BackupRestoreView()
}
