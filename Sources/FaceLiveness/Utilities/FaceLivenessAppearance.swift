//
// KTalk fork: the capture screen accent follows the mode the user is in.
//
// Signup has no mode yet and stays with the local orange. Changing a profile photo
// happens inside a mode, so the capture screen wears that mode's color like the
// screens around it.
//

import SwiftUI
import UIKit

public enum FaceLivenessAppearance {
    /// ARGB value the host sets before presenting. Nil keeps the default accent.
    public static var accentARGB: UInt32?

    static var accent: Color {
        guard let argb = accentARGB else { return Color(UIColor.ktalkAccent) }
        let a = CGFloat((argb >> 24) & 0xFF) / 255
        let r = CGFloat((argb >> 16) & 0xFF) / 255
        let g = CGFloat((argb >> 8) & 0xFF) / 255
        let b = CGFloat(argb & 0xFF) / 255
        return Color(UIColor(red: r, green: g, blue: b, alpha: a == 0 ? 1 : a))
    }

    static var accentUIColor: UIColor {
        UIColor(accent)
    }
}
