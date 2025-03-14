//
//  AppStorageManager.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 3/12/25.
//

import SwiftUI
// Note: This class is exandable if I want to add more lists to UserDefaults.
/// Manages a list of gym names stored in `UserDefaults` using `@AppStorage`.
/// Automatically loads and saves the list when modified.
class AppStorageManager: ObservableObject {
    /// A private property storing the list of gyms as a JSON string in `UserDefaults`.
    @AppStorage("gyms") private var gymList: String = "[]"

    /// A published property holding the list of gyms, kept in sync with `UserDefaults`.
    @Published var gyms: [String] {
        didSet {
            saveGyms()
        }
    }

    /// Initializes `gyms` by loading the stored list from `UserDefaults`.
    init() {
        self.gyms = []

        var loadedGyms = Self.loadGymList(from: gymList)

        // Ensure "Default" is always present
        if loadedGyms.isEmpty {
            loadedGyms.append("Default")
        }

        self.gyms = loadedGyms
    }

    /// Encodes `gyms` into JSON and saves it to `UserDefaults`.
    private func saveGyms() {
        if let data = try? JSONEncoder().encode(gyms) {
            let jsonString = String(decoding: data, as: UTF8.self)
            gymList = jsonString
        }
    }

    /// Decodes a JSON string into an array of gym names.
    /// - Parameter storedString: The JSON string to decode.
    /// - Returns: An array of gym names, or an empty array if decoding fails.
    private static func loadGymList(from storedString: String) -> [String] {
        return (try? JSONDecoder().decode([String].self, from: Data(storedString.utf8))) ?? []
    }
}
