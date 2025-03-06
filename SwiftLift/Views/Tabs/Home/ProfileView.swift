//
//  ProfileView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 9/30/23.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @Query private var workouts: [Workout]
    @AppStorage("name") private var name = ""
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .font(Font.custom("", size: 75))
                .foregroundStyle(Color.accentColor)
            HStack {
                TextField("Name", text: $name)
                    .font(.lato(type: .regular, size: .title))
                    .multilineTextAlignment(.center)

            }
            HStack {
                Text("Joined:")
                // TODO: update
//                Text("\(history[0].joinDate.formatted(date: .long, time: .omitted))")
            }
            .padding(.vertical, 5)

            VStack {
                HStack {
                    Image(systemName: "number")
                    Text("\(workouts.count)")
                    Spacer()
                    // FIXME: get sum of time worked out
                    Text("\(workouts.first?.completionDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
                    Image(systemName: "clock")
                }
                .padding(.horizontal)
                .padding(.vertical, 3.0)
                HStack {
                    Image(systemName: "repeat")
                    Text("\(workouts.reduce(0) { $0 + $1.totalReps })")
                    Spacer()
                    Text("\(Int(workouts.reduce(0) { $0 + $1.totalWeight }))")
                    Image(systemName: "scalemass")
                }
                .padding(.horizontal)
            }
        }
        .font(.lato(type: .regular, size: .body))
    }
}

#Preview {
    ProfileView()
        .modelContainer(previewContainer)
}
