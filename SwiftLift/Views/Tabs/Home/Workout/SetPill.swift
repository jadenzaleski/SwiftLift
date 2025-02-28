//
//  SetView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/27/23.
//

import SwiftUI
import Combine
import UIKit

struct SetPill: View {
    @Binding var set: SetData
    @Binding var isDeleting: Bool
    @State private var decString: String = "0.0"
    @State private var intString: String = "0"
    var body: some View {
        HStack {
            Button {
                set.isComplete.toggle()
                // haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: set.isComplete ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.custom("", size: 24))
            }
            .frame(width: 40, height: 30)
            .foregroundStyle(set.isComplete ? Color.green : Color.blue)
            Spacer()

            TextField("0", text: $intString)
                .numbersOnly($intString)
                .frame(width: 75)
                .onChange(of: intString) {
                    set.reps = Int(intString) ?? 0
                }
                .onReceive(NotificationCenter.default
                    .publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        if let textField = obj.object as? UITextField {
                            textField.selectedTextRange = textField.textRange(
                                from: textField.beginningOfDocument, to: textField.endOfDocument)
                        }
                    }
            Spacer()
            Text("/")
            Spacer()
            TextField("0.0", text: $decString)
                .numbersOnly($decString, includeDecimal: true)
                .frame(width: 100)
                .multilineTextAlignment(.trailing)
                .onChange(of: decString) {
                    set.weight = Double(decString) ?? 0.0
                }
                .padding(.trailing, 5.0)
                .onReceive(NotificationCenter.default.publisher(
                    for: UITextField.textDidBeginEditingNotification)) { obj in
                        if let textField = obj.object as? UITextField {
                            textField.selectedTextRange = textField.textRange(
                                from: textField.beginningOfDocument, to: textField.endOfDocument)
                        }
                    }

        }
        .font(.lato(type: .regular, size: .subtitle))
        .padding()
        .background(Color("offset"))
        .clipShape(Capsule())
        .overlay(set.isComplete ?
                 Capsule(style: .continuous).stroke(Color.green, lineWidth: 2).padding(.horizontal, 1.0) : nil)
        .onAppear {
            intString = String(set.reps)
            decString = String(set.weight)
        }
    }
}

#Preview {
    SetPill(set: .constant(SetData(reps: 10, weight: 20.0, isComplete: false)), isDeleting: .constant(false))
        .modelContainer(previewContainer)
}
