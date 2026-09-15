//
// KTalk fork: capture screen design values.
//
// Geometry comes from the design frame DSN-APP-IDT-0007-06 (390x844). Typography
// and colors come from the app's own tokens so the native screen reads like the
// Flutter screens around it.
//
// The oval keeps upstream's size, so the gaps above and below it follow the SDK
// rather than the frame.
//

import CoreText
import SwiftUI
import UIKit

enum KTalkCaptureStyle {
    // app: CommonColors.gray1E / gray73
    static let titleColor = Color(UIColor(red: 0x1E / 255, green: 0x1E / 255, blue: 0x1E / 255, alpha: 1))
    static let descriptionColor = Color(UIColor(red: 0x73 / 255, green: 0x73 / 255, blue: 0x73 / 255, alpha: 1))

    // frame values
    static let sideMargin: CGFloat = 20
    static let titleTopFromNavBar: CGFloat = 40
    static let titleToDescription: CGFloat = 4
    static let hintToButton: CGFloat = 75
    static let buttonHeight: CGFloat = 64
    static let buttonBottomMargin: CGFloat = 34
    static let buttonCorner: CGFloat = 8

    // app: DesignPageTitle
    static var title: Font { pretendard(size: 24, bold: true) }
    static var description: Font { pretendard(size: 14, bold: false) }
    static var hint: Font { description }
    static var buttonLabel: Font { pretendard(size: 16, bold: true) }

    /// Registers the packaged font once; falls back to the system font if that fails
    /// so a font problem never blocks the capture.
    private static let registered: Bool = {
        var ok = true
        for name in ["Pretendard-Regular", "Pretendard-Bold"] {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                ok = false
                continue
            }
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) { ok = false }
        }
        return ok
    }()

    private static func pretendard(size: CGFloat, bold: Bool) -> Font {
        _ = registered
        let name = bold ? "Pretendard-Bold" : "Pretendard-Regular"
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: bold ? .bold : .regular)
    }
}
