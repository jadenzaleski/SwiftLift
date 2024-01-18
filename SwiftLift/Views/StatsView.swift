//
//  StatsView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI

struct StatsView: View {
    var body: some View {
        /*
         - total workouts
         - total weight - volume
         - total reps
         - total time
         - gyms
         - weight of day x date
         - reps of day x date
         - length of workouts x date
         - select a workout
            - weight x set
            - reps x set
            - more data about workout
         -
         */
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Stats View")
                        .font(.largeTitle)
                    Spacer()
                }
                VStack {
                    Text("VolumeVsDate")
                    VolumeVsDate()
                }
                .padding()
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack {
                    
                }
                .padding()
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()
        }
        .background(Color("offset"))

    }
}

#Preview {
    StatsView()
        .modelContainer(previewContainer)
}
