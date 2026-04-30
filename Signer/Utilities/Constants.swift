import Foundation

enum AppConstants {
    static let appName = "Signer"
    static let appTagline = "Sign Documents. Anytime. Anywhere."
    static let supportEmail = "developer.nasar416@gmail.com"
    static let privacyPolicyURL = "https://signer-app.com/privacy"
    static let termsURL = "https://signer-app.com/terms"

    // StoreKit Product IDs
    static let yearlySubscriptionID = "com.signer.app.yearly"
    static let lifetimeSubscriptionID = "com.signer.app.lifetime"

    // Free trial duration
    static let freeTrialDays = 3

    // App Flow Keys
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasSeenLanguageSelection = "hasSeenLanguageSelection"
    static let selectedLanguageCode = "selectedLanguageCode"
    static let isPremiumUser = "isPremiumUser"

    // Document limits for free tier
    static let freeDocumentSignLimit = 3
    static let freeSignatureLimit = 1
}

enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case portuguese = "pt"
    case arabic = "ar"
    case hindi = "hi"
    case bengali = "bn"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case turkish = "tr"
    case russian = "ru"
    case italian = "it"
    case dutch = "nl"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"
    case malay = "ms"
    case polish = "pl"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Espa\u{00F1}ol"
        case .french: return "Fran\u{00E7}ais"
        case .german: return "Deutsch"
        case .portuguese: return "Portugu\u{00EA}s"
        case .arabic: return "\u{0627}\u{0644}\u{0639}\u{0631}\u{0628}\u{064A}\u{0629}"
        case .hindi: return "\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}"
        case .bengali: return "\u{09AC}\u{09BE}\u{0982}\u{09B2}\u{09BE}"
        case .chinese: return "\u{4E2D}\u{6587}"
        case .japanese: return "\u{65E5}\u{672C}\u{8A9E}"
        case .korean: return "\u{D55C}\u{AD6D}\u{C5B4}"
        case .turkish: return "T\u{00FC}rk\u{00E7}e"
        case .russian: return "\u{0420}\u{0443}\u{0441}\u{0441}\u{043A}\u{0438}\u{0439}"
        case .italian: return "Italiano"
        case .dutch: return "Nederlands"
        case .thai: return "\u{0E44}\u{0E17}\u{0E22}"
        case .vietnamese: return "Ti\u{1EBF}ng Vi\u{1EC7}t"
        case .indonesian: return "Bahasa Indonesia"
        case .malay: return "Bahasa Melayu"
        case .polish: return "Polski"
        }
    }

    var nativeName: String { displayName }

    var flag: String {
        switch self {
        case .english: return "\u{1F1FA}\u{1F1F8}"
        case .spanish: return "\u{1F1EA}\u{1F1F8}"
        case .french: return "\u{1F1EB}\u{1F1F7}"
        case .german: return "\u{1F1E9}\u{1F1EA}"
        case .portuguese: return "\u{1F1E7}\u{1F1F7}"
        case .arabic: return "\u{1F1F8}\u{1F1E6}"
        case .hindi: return "\u{1F1EE}\u{1F1F3}"
        case .bengali: return "\u{1F1E7}\u{1F1E9}"
        case .chinese: return "\u{1F1E8}\u{1F1F3}"
        case .japanese: return "\u{1F1EF}\u{1F1F5}"
        case .korean: return "\u{1F1F0}\u{1F1F7}"
        case .turkish: return "\u{1F1F9}\u{1F1F7}"
        case .russian: return "\u{1F1F7}\u{1F1FA}"
        case .italian: return "\u{1F1EE}\u{1F1F9}"
        case .dutch: return "\u{1F1F3}\u{1F1F1}"
        case .thai: return "\u{1F1F9}\u{1F1ED}"
        case .vietnamese: return "\u{1F1FB}\u{1F1F3}"
        case .indonesian: return "\u{1F1EE}\u{1F1E9}"
        case .malay: return "\u{1F1F2}\u{1F1FE}"
        case .polish: return "\u{1F1F5}\u{1F1F1}"
        }
    }
}
