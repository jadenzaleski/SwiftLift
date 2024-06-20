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
    private let leftGradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    private let rightGradient = LinearGradient(gradient: Gradient(colors: [
        Color("customGreen"), Color("customPurple")]), startPoint: .bottomTrailing, endPoint: .topLeading)
    var body: some View {

        ScrollView {
            VStack {
                VStack {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(workout.gym)
                    }
                    .padding(.bottom, 5.0)
                    .font(.lato(type: .regular, size: .subtitle))
                    VStack {
                        HStack {
                            // time
                            Image(systemName: "clock")
                                .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)
                            Text("\(formatTimeInterval(workout.time))")
                                .foregroundStyle(leftGradient)
                                .padding(.trailing, 5.0)
                            Spacer()
                            // sets
                            Text("\(workout.totalSets)")
                                .foregroundStyle(rightGradient)
                            Image(systemName: "checklist.checked")
                                .padding(/*@START_MENU_TOKEN@*/.trailing, -5.0/*@END_MENU_TOKEN@*/)

                        }

                        HStack {
                            // volume
                            Image(systemName: "scalemass")
                                .padding(.trailing, -5.0)
                            Text("\(Int(workout.totalWeight))")
                                .foregroundStyle(leftGradient)
                            Spacer()
                            // reps
                            Text("\(workout.totalReps)")
                                .foregroundStyle(rightGradient)
                            Image(systemName: "repeat")
                                .padding(.trailing, -5.0)
                        }
                        // sets

                    }
                    .font(.lato(type: .regular, size: .body))
                }
                .padding(.all)
                .padding(.horizontal, 25.0)
                .background(Color("offset"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: colorScheme == .dark ? Color.clear : Color(UIColor.systemGray4), radius: 5)

                ForEach(workout.activities, id: \.id) { activity in
                    VStack {
                        HStack {
                            Text("\(activity.name)")
                                .font(.lato(type: .light, size: .subtitle))
                            Spacer()
                        }
                        if activity.warmUpSets.count > 0 {
                            HStack {
                                Text("Warm-up sets")
                                    .font(.lato(type: .regular, size: .small))
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
                                .font(.lato(type: .regular, size: .body))
                                .padding(.vertical, 0.0)
                                .padding(.horizontal)
                            }
                        }

                        if activity.workingSets.count > 0 {
                            HStack {
                                Text("Working sets")
                                    .font(.lato(type: .regular, size: .small))
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
                                .font(.lato(type: .regular, size: .body))
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
                .padding(7)
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(workout.startDate.formatted(.dateTime.month().day().year().hour().minute()))")
                    .font(.lato(type: .light, size: .subtitle))
            }
        }
        .withCustomBackButton()

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
