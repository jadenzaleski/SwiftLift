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
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
    @AppStorage("name") private var name = ""
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .font(Font.custom("", size: 75))
                .foregroundStyle(Color.accentColor)
            HStack {
                TextField("Name", text: $name)
                    .font(.title)
                    .multilineTextAlignment(.center)

            }
            HStack {
                Text("Joined:")
                    .font(.callout)
                Text("\(history[0].joinDate.formatted(date: .long, time: .omitted))")
                    .font(.callout)
            }
            VStack {
                HStack {
                    Image(systemName: "number")
                    Text("\(history[0].totalWorkouts)")
                    Spacer()
                    Text("\(history[0].getTimeFormatted(ifDays: true))")
                    Image(systemName: "clock")
                }
                .padding(.horizontal)
                .padding(.vertical, 3.0)
                HStack {
                    Image(systemName: "repeat")
                    Text("\(history[0].totalReps)")
                    Spacer()
                    Text("\(Int(history[0].totalWeight))")
                    Image(systemName: "scalemass")
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(previewContainer)
}
