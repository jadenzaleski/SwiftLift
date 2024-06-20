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

enum LatoFontSize {
    case caption, body, small, medium, subtitle, large, heading, toolbarTitle, title, custom(CGFloat)

    var size: CGFloat {
        switch self {
        case .caption:
            return 13
        case .body:
            return 16
        case .small:
            return 14
        case .medium:
            return 18
        case .subtitle:
            return 20
        case .large:
            return 22
        case .heading:
            return 24
        case .toolbarTitle:
            return 26
        case .title:
            return 32
        case .custom(let size):
            return size
        }
    }
}

struct LatoFont {
    var type: LatoFontType
    var isItalic: Bool
    var size: LatoFontSize

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

        let fontSize = size.size
        return Font.custom(fontName, size: fontSize)
    }
}

extension Font {
    static func lato(type: LatoFontType, isItalic: Bool = false, size: LatoFontSize = .medium) -> Font {
        return LatoFont(type: type, isItalic: isItalic, size: size).font()
    }
}
