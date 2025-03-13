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
    @Query(
        filter: #Predicate<Workout> { $0.completionDate != nil },
        sort: \Workout.completionDate,
        order: .reverse
    )
    private var workouts: [Workout]

    @AppStorage("name") private var name = ""

    var totalWorkoutDuration: String {
        let totalSeconds = workouts.compactMap { $0.duration }.reduce(0, +)

        let days = Int(totalSeconds / 86400)
        let hours = Int((totalSeconds.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)

        var formatted = ""
        if days > 0 { formatted += "\(days)d " }
        if hours > 0 { formatted += "\(hours)h " }
        if minutes > 0 { formatted += "\(minutes)m" }

        return formatted.isEmpty ? "0m" : formatted.trimmingCharacters(in: .whitespaces)
    }

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
                Text("\(workouts.first?.completionDate?.formatted(date: .abbreviated, time: .shortened) ?? "No workouts yet")")
//                Text("\(history[0].joinDate.formatted(date: .long, time: .omitted))")
            }
            .padding(.vertical, 5)

            VStack {
                HStack {
                    Image(systemName: "number")
                    Text("\(workouts.count)")
                    Spacer()
                    Text("\(totalWorkoutDuration)")
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
