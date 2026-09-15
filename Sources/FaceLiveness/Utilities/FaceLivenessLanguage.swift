//
// KTalk fork: let the host app pick the capture screen language.
//
// The app owns its own language setting, which can differ from the device locale.
// Setting `languageCode` makes the capture screen follow the app instead of the OS.
// Leaving it nil keeps the upstream behaviour.
//

import Foundation

public enum FaceLivenessLanguage {
    /// BCP-47 language code, e.g. "ko" or "en". Nil follows the device locale.
    public static var languageCode: String?

    /// Resolves the app-bundle lproj for `languageCode`, then the package's own.
    static var preferredBundle: Bundle? {
        guard let code = languageCode, !code.isEmpty else { return nil }
        for candidate in [Bundle.main, Bundle.module] {
            if let path = candidate.path(forResource: code, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return nil
    }
}
