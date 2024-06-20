//
//  CustomBackButton.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 6/19/24.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left.circle")
                .font(.lato(type: .regular, size: .subtitle))
        }
    }
}

struct BackButtonModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton {
                        dismiss()
                    }
                }
            }
    }
}

extension View {
    func withCustomBackButton() -> some View {
        modifier(BackButtonModifier())
    }
}
