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

    static func randomSet() -> SetData {
        let randomReps = Int.random(in: 1...12)
        let randomWeight = Double.random(in: 10.0...315.0).rounded(.down)
        let randomIsChecked = Bool.random()

        return SetData(reps: randomReps, weight: randomWeight, isChecked: randomIsChecked)
    }

    static func randomSets(count: Int) -> [SetData] {
        return (0..<count).map { _ in randomSet() } // Adjust the number of sets as needed
    }

    mutating func setReps(string: String) {
        if Int(string) != nil {
            self.reps = Int(string)!
        }
    }

    mutating func setWeight(string: String) {
        if Double(string) != nil {
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
