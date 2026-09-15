//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension String {
    /// Looks for a localized value using this value as the key.
    /// If no localization is found in the current app's bundle,
    /// it defaults to the one provided by Liveness
    func localized(comment: String = "") -> String {
        let defaultValue = NSLocalizedString(self, bundle: .module, comment: "")
        // KTalk fork: follow the app's own language setting when it sets one.
        // Upstream resolves through the OS locale, so an app whose language differs
        // from the device renders a mixed-language screen.
        if let bundle = FaceLivenessLanguage.preferredBundle {
            let value = NSLocalizedString(self, bundle: bundle, value: "\u{0}", comment: "")
            if value != "\u{0}" { return value }
        }
        return NSLocalizedString(
            self,
            bundle: .main,
            value: defaultValue,
            comment: ""
        )
    }

    func localized(using arguments: CVarArg...) -> String {
        return String(format: localized(), arguments)
    }
}
