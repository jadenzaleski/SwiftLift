//
//  SetData.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/30/23.
//

import Foundation

struct SetData: Identifiable, Codable, Hashable {
    var id = UUID()
    var reps: Int
    var weight: Double
    var isChecked: Bool = false
    
    init(id: UUID = UUID(), reps: Int, weight: Double, isChecked: Bool) {
        self.reps = reps
        self.weight = weight
        self.isChecked = isChecked
    }
    
    static var sampleSets: [SetData] = [
        SetData(reps: 8, weight: 45.0, isChecked: false),
        SetData(reps: 10, weight: 135.0, isChecked: true),
        SetData(reps: 8, weight: 225.0, isChecked: false)
    ]
    
    mutating func setReps(string: String) {
        if (Int(string) != nil) {
            self.reps = Int(string)!
        }
    }
    
    mutating func setWeight(string: String) {
        if (Double(string) != nil) {
            self.weight = Double(string)!
        }
    }
    
    func getReps() -> String {
        return String(self.reps)
    }
    
    func getWeight() -> String {
        return String(self.weight)
    }
}
