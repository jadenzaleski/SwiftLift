//
//  Tester.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/28/23.
//

import SwiftUI
import UIKit

struct Tester: View {
    @State var index = 0
    @State var num = 0.0
    @FocusState private var focusedField: UUID?

    var body: some View {
        ScrollView {
            Button("Tap") {
                index += 1
                print("[+] Running Tester: \(index)")
                focusedField = nil

                switch index {
                case 1:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)

                case 2:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                case 3:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)

                case 4:
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()

                case 5:
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                case 6:
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()

                case 7:
                    let generator = UIImpactFeedbackGenerator(style: .rigid)
                    generator.impactOccurred()

                case 8:
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()

                default:
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    index = 0
                }
            }

            TextField("TesterField", value: $num, formatter: decimalFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: UUID())
                .padding()
            Text("My num: \(num)")
        }
    }

    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0   // Allow whole numbers without decimal places
        formatter.maximumFractionDigits = 2   // Allow up to two decimal places
        formatter.alwaysShowsDecimalSeparator = false // No forced decimal unless needed
        return formatter
    }()
}

struct Tester_Previews: PreviewProvider {
    static var previews: some View {
        Tester()
    }
}
