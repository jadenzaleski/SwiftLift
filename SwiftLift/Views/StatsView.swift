//
//  StatsView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI

struct StatsView: View {
    enum DateYValue: String, CaseIterable, Identifiable {
        case volume, reps, duration
        var id: Self { self }
        var text: String {
            get {
                switch self {
                case .duration: return "duration"
                case .reps: return "reps"
                case .volume: return "volume"
                }
            }
            nonmutating set {
                // do nothing when set becuase we only read this value
            }
        }
    }
    @State private var selectedYDateValue: DateYValue = .volume

    @State private var selectedPastLength: Int = 7
    
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
                    
                }
                .padding()
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack {
                    Picker("Y Value", selection: $selectedYDateValue) {
                        Text("Volume").tag(DateYValue.volume)
                        Text("Reps").tag(DateYValue.reps)
                        Text("Duration").tag(DateYValue.duration)
                    }
                    .pickerStyle(.segmented)
                    Picker("Y Value", selection: $selectedPastLength) {
                        Text("7").tag(7)
                        Text("30").tag(30)
                        Text("90").tag(90)
                        Text("180").tag(180)
                        Text("365").tag(365)
                        Text("All").tag(-1)
                    }
                    .padding(.top, 8.0)
                    .pickerStyle(.segmented)
                    
                    HStack {
                        Text("\(selectedYDateValue.text.capitalized) vs. Date")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 20.0)
                    HStack {
                        if (selectedPastLength == -1) {
                            Text("All workouts")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Past \(selectedPastLength) workouts")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    VolumeVsDate(pastDays: $selectedPastLength, yAxis: $selectedYDateValue.text)
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
