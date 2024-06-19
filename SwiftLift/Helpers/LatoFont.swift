//
//  LatoFont.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 6/18/24.
//

import SwiftUI

enum LatoFontType {
    case regular, bold, light, thin, black
}

struct LatoFont {
    var type: LatoFontType
    var isItalic: Bool
    var size: CGFloat

    func font() -> Font {
        let baseName: String

        switch type {
        case .regular:
            baseName = "Lato-Regular"
        case .bold:
            baseName = "Lato-Bold"
        case .light:
            baseName = "Lato-Light"
        case .thin:
            baseName = "Lato-Hairline"
        case .black:
            baseName = "Lato-Black"
        }

        var fontName = isItalic ? "\(baseName)Italic" : baseName

        if type == .regular && isItalic {
            fontName = "Lato-Italic"
        }
        return Font.custom(fontName, size: size)
    }
}

extension Font {
    static func lato(type: LatoFontType, isItalic: Bool = false, size: CGFloat) -> Font {
        return LatoFont(type: type, isItalic: isItalic, size: size).font()
    }
}
