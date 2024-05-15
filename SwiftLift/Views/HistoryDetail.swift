//
//  HistoryDetail.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 12/22/23.
//

import SwiftUI

struct HistoryDetail: View {
    @Environment(\.colorScheme) var colorScheme
    var workout: Workout
    private let gradient = LinearGradient(gradient: Gradient(colors: [Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "calendar")
                    .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                Text("\(workout.startDate.formatted(.dateTime.month().day().year().hour().minute()))")
                Spacer()
            }
            .padding(.bottom, 0.0)
            .padding(.horizontal)
            .font(.title2)
            .foregroundStyle(gradient)

            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(workout.gym)
//                Spacer()
            }
            .padding(.horizontal)
            .font(.title2)

            VStack {
                HStack {
                    // time
                    Image(systemName: "clock")
                        .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                    Text("\(formatTimeInterval(workout.time))")
                        .padding(.trailing, 5.0)
                    Spacer()
                    // sets
                    Text("\(workout.totalSets)")
                    Image(systemName: "checklist.checked")
                        .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)

                }

                HStack {
                    // volume
                    Image(systemName: "scalemass")
                        .padding(.trailing, -5.0)
                    Text("\(Int(workout.totalWeight))")
                    Spacer()
                    // reps
                    Text("\(workout.totalReps)")
                    Image(systemName: "repeat")
                        .padding(.trailing, -5.0)
                }
                // sets

            }
            .padding(.horizontal)
            Divider()
                .padding(.horizontal)
        }
        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
        .background(.mainSystem)

        ScrollView {
            VStack {
                ForEach(workout.activities, id: \.id) { activity in
                    VStack {
                        HStack {
                            Text("\(activity.name)")
                                .font(.title2)
                            Spacer()
                        }
                        if activity.warmUpSets.count > 0 {
                            HStack {
                                Text("Warm-up sets")
                                    .font(.caption)
                                VStack {
                                    Divider()
                                }
                            }
                            ForEach(activity.warmUpSets, id: \.id) { warmUpSet in
                                HStack(alignment: .firstTextBaseline) {
                                    Text("\(warmUpSet.getReps())")
                                        .frame(width: 100, height: 20, alignment: .leading)
                                    Spacer()
                                    Text("/")
                                        .frame(width: 10, height: 20, alignment: .center)
                                    Spacer()
                                    Text("\(warmUpSet.getWeight())")
                                        .frame(width: 100, height: 20, alignment: .trailing)
                                }
                                .padding(.vertical, 0.0)
                                .padding(.horizontal)
                            }
                        }

                        if activity.workingSets.count > 0 {
                            HStack {
                                Text("Working sets")
                                    .font(.caption)
                                VStack {
                                    Divider()
                                }
                            }
                            .padding(.top, 10)
                            ForEach(activity.workingSets, id: \.id) { workingSet in
                                HStack(alignment: .firstTextBaseline) {
                                    Text("\(workingSet.getReps())")
                                        .frame(width: 100, height: 20, alignment: .leading)
                                    Spacer()
                                    Text("/")
                                        .frame(width: 10, height: 20, alignment: .center)
                                    Spacer()
                                    Text("\(workingSet.getWeight())")
                                        .frame(width: 100, height: 20, alignment: .trailing)
                                }
                                .padding(.vertical, 0.0)
                                .padding(.horizontal)
                            }
                        }

                    }
                    .padding(.all)
                    .padding(.horizontal, 25.0)
                    .background(Color("offset"))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)
                }
            }
        }
        .padding(.horizontal)

    }

    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute, .second]

        guard let formattedDuration = durationFormatter.string(from: abs(timeInterval)) else {
            return "Invalid Duration"
        }

        return formattedDuration
    }
}

#Preview {
    HistoryDetail(workout: Workout.randomWorkout())
}
