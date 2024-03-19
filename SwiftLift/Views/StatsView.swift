//
//  StatsView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/1/23.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var history: [History]
    @Query private var exercises: [Exercise]
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
    @State private var selectedGym = "All Gyms"
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        
        
        ScrollView {
            LazyVStack(alignment: .center, spacing: 20, pinnedViews: .sectionHeaders) {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Lifetime totals:")
                            .font(.title3)
                            .bold()
                        Divider()
                            .padding(.vertical, 3)
                        
                        HStack {
                            Image(systemName: "number")
                            Text("Workouts:")
                                .bold()
                            Text("\(history[0].totalWorkouts)")
                                .bold()
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "clock")
                            Text("Time:")
                                .bold()
                            Text("\(formatTimeInterval(history[0].totalTime))")
                                .bold()
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "scalemass")
                            Text("Weight:")
                                .bold()
                            Text("\(Int(history[0].totalWeight))")
                                .bold()
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "checklist.checked")
                            Text("Sets:")
                                .bold()
                            Text("\(history[0].totalSets)")
                                .bold()
                                .foregroundStyle(gradient)
                        }
                        HStack {
                            Image(systemName: "repeat")
                            Text("Reps:")
                                .bold()
                            Text("\(history[0].totalReps)")
                                .bold()
                                .foregroundStyle(gradient)
                        }
                        
                        
                        
                    }
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray5), radius: 5, x: 0, y: 0)
                    
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
                        LineChart(pastDays: $selectedPastLength, yAxis: $selectedYDateValue.text)
                    }
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray5), radius: 5, x: 0, y: 0)
                    .padding(.bottom, 100)
//                    VStack {
//                        Text("hey")
//                            .padding(100)
//                    }
//                    .padding()
//                    .background()
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//                    .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray5), radius: 5, x: 0, y: 0)
                    
                } header: { // TODO: implement gym filter
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Spacer()
                            HStack() {
                                Text("Stats")
                                    .font(.largeTitle)
                                Spacer()
                                
//                                Menu {
//                                    Picker("Select a gym", selection: $selectedGym) {
//                                        Text("All Gyms").tag("All Gyms")
//                                        ForEach(history[0].gyms, id: \.self) { gym in
//                                            Text(gym).tag(gym)
//                                        }
//                                        
//                                    }
//                                    .tint(.black)
//                                } label: {
//                                    Image(systemName: "mappin.and.ellipse")
//                                        .font(.title)
//                                        .tint(.black)
//                                    Text(selectedGym)
//                                        .font(.largeTitle)
//                                        .tint(.black)
//                                }
                                
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 5.0)
                            
                        }
                        .frame(height: 120)
                        .background(Color("offset"))
                        .ignoresSafeArea(.all)
                        .padding(.horizontal, -20.0)
                        
                        LinearGradient(colors: [Color(UIColor.systemGray5), .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: 10)
                            .padding(.horizontal, -20.0)
                    }
                }
                
                
            }
            .padding()
            
            
        }
        .background(Color("offset"))
        .ignoresSafeArea(.all)
        
    }
    
    // format the times into 0h 0m
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.day, .hour, .minute]
        
        guard let formattedDuration = durationFormatter.string(from: abs(timeInterval)) else {
            return "Invalid Duration"
        }
        
        return formattedDuration
    }
    
}

#Preview {
    StatsView()
        .modelContainer(previewContainer)
}
