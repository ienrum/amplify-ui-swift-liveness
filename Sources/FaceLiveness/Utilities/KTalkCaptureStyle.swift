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
    // app: CommonColors.redC8, readable against the white instruction surface.
    static let errorColor = Color(UIColor(red: 0xC8 / 255, green: 0x46 / 255, blue: 0x46 / 255, alpha: 1))

    // app: the back chevron stroke in assets/icons/arrow/24-chevron-left.svg
    static let backIconColor = Color(UIColor(red: 0x4E / 255, green: 0x4E / 255, blue: 0x4E / 255, alpha: 1))

    // frame values
    static let sideMargin: CGFloat = 20
    static let navBarHeight: CGFloat = 44
    static let backButtonWidth: CGFloat = 52
    static let backIconSize: CGFloat = 24
    static let backIconLineWidth: CGFloat = 2
    static let titleTopFromNavBar: CGFloat = 40
    // Compact displays have no frame of their own; keep the title clear of the SDK oval.
    static let compactHeight: CGFloat = 700
    static let titleTopCompact: CGFloat = 8
    static let titleToDescription: CGFloat = 4
    static let hintToButton: CGFloat = 75
    static let buttonHeight: CGFloat = 64
    static let buttonBottomMargin: CGFloat = 34
    static let buttonCorner: CGFloat = 8

    // ── 촬영 중 화면(DSN-APP-IDT-0007-06). 도면 좌표는 390x844 프레임이고 그 안에
    // 상태 표시줄 54 가 들어 있다. 여기 값은 안전 영역 기준의 여백이다.
    static let captureBackground = UIColor(red: 0x12 / 255, green: 0x0F / 255, blue: 0x0E / 255, alpha: 1)
    static let captureScrim = UIColor(red: 0x09 / 255, green: 0x07 / 255, blue: 0x06 / 255, alpha: 0.84)
    static let capturePill = Color(UIColor(red: 0x12 / 255, green: 0x0E / 255, blue: 0x0C / 255, alpha: 0.55))
    static let captureBubble = Color(UIColor(red: 0x12 / 255, green: 0x0E / 255, blue: 0x0C / 255, alpha: 0.74))
    static let recordingDotColor = Color(UIColor(red: 0xFF / 255, green: 0x4B / 255, blue: 0x3E / 255, alpha: 1))
    static let captureHintColor = Color(UIColor.white.withAlphaComponent(0.78))
    static let captureOvalStroke = UIColor.white.withAlphaComponent(0.88)

    static let captureTopMargin: CGFloat = 6 // 도면 y=60 - 상태 표시줄 54
    static let captureBubbleTop: CGFloat = 64 // 도면 y=118 - 상태 표시줄 54
    static let captureHintBottom: CGFloat = 55 // 도면 y=734 아래 여백에서 홈 인디케이터 34 를 뺀 값
    static let recordingDotSize: CGFloat = 8
    static let recordingGap: CGFloat = 7
    static let recordingPadLeading: CGFloat = 11
    static let recordingPadTrailing: CGFloat = 13
    static let recordingPadVertical: CGFloat = 7
    static let closeButtonSize: CGFloat = 38
    static let closeIconSize: CGFloat = 13
    static let closeIconLineWidth: CGFloat = 2
    static let bubblePadHorizontal: CGFloat = 20
    static let bubblePadVertical: CGFloat = 12
    static let captureOvalStrokeWidth: CGFloat = 3

    // 진행 표시는 타원 바깥으로 4pt 만큼 나간다(도면의 252x334 대 244x326).
    // 타원 좌표 자체는 SDK 값 그대로 쓴다.
    static let progressStrokeWidth: CGFloat = 4
    static let progressInset: CGFloat = 2

    static var recordingLabel: Font { pretendard(size: 13, bold: false) }
    static var bubbleLabel: Font { pretendard(size: 16, bold: true) }
    static var captureHint: Font { pretendard(size: 14, bold: false) }

    // app: DesignPageTitle
    static var title: Font { pretendard(size: 24, bold: true) }
    static var description: Font { pretendard(size: 14, bold: false) }
    static var hint: Font { description }
    static var buttonLabel: Font { pretendard(size: 16, bold: true) }
    static var instruction: Font { pretendard(size: 16, bold: true) }

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
