//
//  Activity.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/5/23.
//

import Foundation

struct Activity: Identifiable, Codable, Hashable {
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
        Activity(name: "Bench Press", warmUpSets: SetData.randomSets(count: Int.random(in: 1...3)), workingSets: SetData.randomSets(count: Int.random(in: 2...6)), gym: "gym2"),
        Activity(name: "Back Squat", warmUpSets: SetData.randomSets(count: Int.random(in: 1...3)), workingSets: SetData.randomSets(count: Int.random(in: 2...6)), gym: "gym1"),
        Activity(name: "Bicep Curl", warmUpSets: SetData.randomSets(count: Int.random(in: 1...3)), workingSets: SetData.randomSets(count: Int.random(in: 2...6)), gym: "gym2")
    ]
    
    static func randomActivity() -> Activity {
        return Activity(name: "randomName\(Int.random(in: 0...100))",
                        warmUpSets: SetData.randomSets(count: Int.random(in: 1...3)),
                        workingSets: SetData.randomSets(count: Int.random(in: 2...6)),
                        gym: "randomGym\(Int.random(in: 0...100))")
    }
    
    static func randomActivities(count: Int) -> [Activity] {
        return (0..<count).map { _ in randomActivity() }
        
    }
}
