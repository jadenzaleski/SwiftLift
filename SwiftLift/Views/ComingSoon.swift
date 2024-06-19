//
//  ComingSoon.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 11/6/23.
//

import SwiftUI

struct ComingSoon: View {
    var body: some View {
        Text("Feature coming soon!")
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .thin, isItalic: false, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .thin, isItalic: true, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .light, isItalic: false, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .light, isItalic: true, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .regular, isItalic: false, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .regular, isItalic: true, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .bold, isItalic: false, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .bold, isItalic: true, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .black, isItalic: false, size: 24))
        Text("Lorem ipsum dolor sit amet.")
            .font(.lato(type: .black, isItalic: true, size: 24))
    }
}

#Preview {
    ComingSoon()
}
