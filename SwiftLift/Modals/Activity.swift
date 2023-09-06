//
//  Activity.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation

struct Activity: Identifiable {
    var id: UUID
    var name: String
    var warmUpSets: [SetData]
    var workingSets: [SetData]
    var completedDate: Date
    var gym: String
    
    init(id: UUID = UUID(), name: String, warmUpSets: [SetData] = [], workingSets: [SetData] = [], completedDate: Date = Date(), gym: String) {
        self.id = id
        self.name = name
        self.warmUpSets = warmUpSets
        self.workingSets = workingSets
        self.completedDate = completedDate
        self.gym = gym
    }
    
    static let sampleActivites: [Activity] =
    [
        Activity(name: "Bench Press", warmUpSets: SetData.sampleSets, workingSets: SetData.sampleSets, gym: "gym2"),
        Activity(name: "Back Squat", warmUpSets: SetData.sampleSets, workingSets: SetData.sampleSets, gym: "gym2"),
        Activity(name: "Bicep Curl", warmUpSets: SetData.sampleSets, workingSets: SetData.sampleSets, gym: "gym2")
    ]
}
