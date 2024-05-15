import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "customGreen" asset catalog color resource.
    static let customGreen = DeveloperToolsSupport.ColorResource(name: "customGreen", bundle: resourceBundle)

    /// The "customPurple" asset catalog color resource.
    static let customPurple = DeveloperToolsSupport.ColorResource(name: "customPurple", bundle: resourceBundle)

    /// The "ld" asset catalog color resource.
    static let ld = DeveloperToolsSupport.ColorResource(name: "ld", bundle: resourceBundle)

    /// The "mainSystemColor" asset catalog color resource.
    static let mainSystem = DeveloperToolsSupport.ColorResource(name: "mainSystemColor", bundle: resourceBundle)

    /// The "offset" asset catalog color resource.
    static let offset = DeveloperToolsSupport.ColorResource(name: "offset", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "LaunchScreen" asset catalog image resource.
    static let launchScreen = DeveloperToolsSupport.ImageResource(name: "LaunchScreen", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "customGreen" asset catalog color.
    static var customGreen: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .customGreen)
#else
        .init()
#endif
    }

    /// The "customPurple" asset catalog color.
    static var customPurple: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .customPurple)
#else
        .init()
#endif
    }

    /// The "ld" asset catalog color.
    static var ld: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ld)
#else
        .init()
#endif
    }

    /// The "mainSystemColor" asset catalog color.
    static var mainSystem: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainSystem)
#else
        .init()
#endif
    }

    /// The "offset" asset catalog color.
    static var offset: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .offset)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "customGreen" asset catalog color.
    static var customGreen: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .customGreen)
#else
        .init()
#endif
    }

    /// The "customPurple" asset catalog color.
    static var customPurple: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .customPurple)
#else
        .init()
#endif
    }

    /// The "ld" asset catalog color.
    static var ld: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .ld)
#else
        .init()
#endif
    }

    /// The "mainSystemColor" asset catalog color.
    static var mainSystem: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .mainSystem)
#else
        .init()
#endif
    }

    /// The "offset" asset catalog color.
    static var offset: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .offset)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "customGreen" asset catalog color.
    static var customGreen: SwiftUI.Color { .init(.customGreen) }

    /// The "customPurple" asset catalog color.
    static var customPurple: SwiftUI.Color { .init(.customPurple) }

    /// The "ld" asset catalog color.
    static var ld: SwiftUI.Color { .init(.ld) }

    /// The "mainSystemColor" asset catalog color.
    static var mainSystem: SwiftUI.Color { .init(.mainSystem) }

    /// The "offset" asset catalog color.
    static var offset: SwiftUI.Color { .init(.offset) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "customGreen" asset catalog color.
    static var customGreen: SwiftUI.Color { .init(.customGreen) }

    /// The "customPurple" asset catalog color.
    static var customPurple: SwiftUI.Color { .init(.customPurple) }

    /// The "ld" asset catalog color.
    static var ld: SwiftUI.Color { .init(.ld) }

    /// The "mainSystemColor" asset catalog color.
    static var mainSystem: SwiftUI.Color { .init(.mainSystem) }

    /// The "offset" asset catalog color.
    static var offset: SwiftUI.Color { .init(.offset) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "LaunchScreen" asset catalog image.
    static var launchScreen: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .launchScreen)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "LaunchScreen" asset catalog image.
    static var launchScreen: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .launchScreen)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

