import Foundation
import SwiftUI

@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    var currentLanguage: SupportedLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: AppConstants.selectedLanguageCode)
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: AppConstants.selectedLanguageCode),
           let language = SupportedLanguage(rawValue: saved) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = LocalizationManager.detectSystemLanguage()
        }
    }

    static func detectSystemLanguage() -> SupportedLanguage {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = String(preferredLanguage.prefix(2))

        return SupportedLanguage(rawValue: languageCode) ?? .english
    }

    // MARK: - Localized Strings
    func localized(_ key: LocalizedStringKey) -> String {
        return localizedStrings[currentLanguage]?[key] ?? localizedStrings[.english]?[key] ?? ""
    }
}

// MARK: - String Keys
enum LocalizedStringKey: String {
    // General
    case appName
    case continueButton
    case skip
    case getStarted
    case close
    case done
    case cancel
    case save
    case delete
    case share
    case export

    // Language Selection
    case selectLanguage
    case selectLanguageSubtitle
    case autoDetected

    // Onboarding
    case onboardingTitle1
    case onboardingSubtitle1
    case onboardingTitle2
    case onboardingSubtitle2
    case onboardingTitle3
    case onboardingSubtitle3
    case onboardingTitle4
    case onboardingSubtitle4

    // Paywall
    case unlockPremium
    case paywallSubtitle
    case yearlyPlan
    case lifetimePlan
    case perMonth
    case freeTrial
    case freeTrialDescription
    case startFreeTrial
    case bestValue
    case oneTimePurchase
    case restorePurchase
    case termsOfUse
    case privacyPolicy

    // Home
    case myDocuments
    case noDocuments
    case noDocumentsSubtitle
    case importDocument
    case scanDocument
    case createBlank
    case recentDocuments
    case allDocuments
    case search

    // Document Actions
    case sign
    case addSignature
    case addText
    case addDate
    case addStamp
    case addInitials
    case addCheckbox
    case addImage
    case draw

    // Signature
    case createSignature
    case drawSignature
    case typeSignature
    case savedSignatures
    case clearCanvas
    case useSignature

    // Settings
    case settings
    case premium
    case manageSubscription
    case language
    case support
    case contactSupport
    case rateApp
    case shareApp
    case about
    case version
}

// MARK: - Localization Dictionary
private let localizedStrings: [SupportedLanguage: [LocalizedStringKey: String]] = [
    .english: [
        .appName: "Signer",
        .continueButton: "Continue",
        .skip: "Skip",
        .getStarted: "Get Started",
        .close: "Close",
        .done: "Done",
        .cancel: "Cancel",
        .save: "Save",
        .delete: "Delete",
        .share: "Share",
        .export: "Export",
        .selectLanguage: "Select Your Language",
        .selectLanguageSubtitle: "Choose your preferred language. You can change this later in Settings.",
        .autoDetected: "Auto-detected",
        .onboardingTitle1: "Sign Documents\nInstantly",
        .onboardingSubtitle1: "No more printing, signing, and scanning. Sign any PDF or document directly on your device in seconds.",
        .onboardingTitle2: "Professional\nSignatures",
        .onboardingSubtitle2: "Draw, type, or scan your signature. Add stamps, dates, and text fields to any document with precision.",
        .onboardingTitle3: "Secure &\nPrivate",
        .onboardingSubtitle3: "Your documents never leave your device. All processing happens locally with bank-grade encryption.",
        .onboardingTitle4: "Ready to Sign\nSmarter?",
        .onboardingSubtitle4: "Join millions of professionals who save time and paper with digital signatures every day.",
        .unlockPremium: "Unlock Premium",
        .paywallSubtitle: "Get unlimited access to all features",
        .yearlyPlan: "Yearly",
        .lifetimePlan: "Lifetime",
        .perMonth: "/month",
        .freeTrial: "Free Trial",
        .freeTrialDescription: "3-day free trial, then",
        .startFreeTrial: "Start Free Trial",
        .bestValue: "Best Value",
        .oneTimePurchase: "One-time purchase",
        .restorePurchase: "Restore Purchase",
        .termsOfUse: "Terms of Use",
        .privacyPolicy: "Privacy Policy",
        .myDocuments: "My Documents",
        .noDocuments: "No Documents Yet",
        .noDocumentsSubtitle: "Import a PDF, scan a document, or create a blank page to get started.",
        .importDocument: "Import PDF",
        .scanDocument: "Scan Document",
        .createBlank: "Blank Page",
        .recentDocuments: "Recent",
        .allDocuments: "All Documents",
        .search: "Search documents...",
        .sign: "Sign",
        .addSignature: "Add Signature",
        .addText: "Add Text",
        .addDate: "Add Date",
        .addStamp: "Add Stamp",
        .addInitials: "Add Initials",
        .addCheckbox: "Checkbox",
        .addImage: "Add Image",
        .draw: "Draw",
        .createSignature: "Create Signature",
        .drawSignature: "Draw Your Signature",
        .typeSignature: "Type Signature",
        .savedSignatures: "Saved Signatures",
        .clearCanvas: "Clear",
        .useSignature: "Use Signature",
        .settings: "Settings",
        .premium: "Premium",
        .manageSubscription: "Manage Subscription",
        .language: "Language",
        .support: "Support",
        .contactSupport: "Contact Support",
        .rateApp: "Rate App",
        .shareApp: "Share App",
        .about: "About",
        .version: "Version",
    ],
    .bengali: [
        .appName: "Signer",
        .continueButton: "\u{099A}\u{09B2}\u{09C1}\u{09A8}",
        .skip: "\u{098F}\u{09DC}\u{09BF}\u{09AF}\u{09BC}\u{09C7} \u{09AF}\u{09BE}\u{09A8}",
        .getStarted: "\u{09B6}\u{09C1}\u{09B0}\u{09C1} \u{0995}\u{09B0}\u{09C1}\u{09A8}",
        .close: "\u{09AC}\u{09A8}\u{09CD}\u{09A7}",
        .done: "\u{09B8}\u{09AE}\u{09CD}\u{09AA}\u{09A8}\u{09CD}\u{09A8}",
        .cancel: "\u{09AC}\u{09BE}\u{09A4}\u{09BF}\u{09B2}",
        .save: "\u{09B8}\u{09C7}\u{09AD}",
        .delete: "\u{09AE}\u{09C1}\u{099B}\u{09C1}\u{09A8}",
        .share: "\u{09B6}\u{09C7}\u{09AF}\u{09BC}\u{09BE}\u{09B0}",
        .export: "\u{098F}\u{0995}\u{09CD}\u{09B8}\u{09AA}\u{09CB}\u{09B0}\u{09CD}\u{099F}",
        .selectLanguage: "\u{0986}\u{09AA}\u{09A8}\u{09BE}\u{09B0} \u{09AD}\u{09BE}\u{09B7}\u{09BE} \u{09A8}\u{09BF}\u{09B0}\u{09CD}\u{09AC}\u{09BE}\u{099A}\u{09A8} \u{0995}\u{09B0}\u{09C1}\u{09A8}",
        .selectLanguageSubtitle: "\u{0986}\u{09AA}\u{09A8}\u{09BE}\u{09B0} \u{09AA}\u{099B}\u{09A8}\u{09CD}\u{09A6}\u{09C7}\u{09B0} \u{09AD}\u{09BE}\u{09B7}\u{09BE} \u{09AC}\u{09C7}\u{099B}\u{09C7} \u{09A8}\u{09BF}\u{09A8}\u{0964} \u{09AA}\u{09B0}\u{09C7} \u{09B8}\u{09C7}\u{099F}\u{09BF}\u{0982}\u{09B8}\u{09C7} \u{09AA}\u{09B0}\u{09BF}\u{09AC}\u{09B0}\u{09CD}\u{09A4}\u{09A8} \u{0995}\u{09B0}\u{09A4}\u{09C7} \u{09AA}\u{09BE}\u{09B0}\u{09AC}\u{09C7}\u{09A8}\u{0964}",
        .autoDetected: "\u{0985}\u{099F}\u{09CB}-\u{09A1}\u{09BF}\u{099F}\u{09C7}\u{0995}\u{09CD}\u{099F}\u{09C7}\u{09A1}",
        .onboardingTitle1: "\u{09A1}\u{0995}\u{09C1}\u{09AE}\u{09C7}\u{09A8}\u{09CD}\u{099F} \u{09B8}\u{09BE}\u{0987}\u{09A8} \u{0995}\u{09B0}\u{09C1}\u{09A8}\n\u{09A4}\u{09BE}\u{09CE}\u{0995}\u{09CD}\u{09B7}\u{09A3}\u{09BF}\u{0995}\u{09AD}\u{09BE}\u{09AC}\u{09C7}",
        .onboardingSubtitle1: "\u{0986}\u{09B0} \u{09AA}\u{09CD}\u{09B0}\u{09BF}\u{09A8}\u{09CD}\u{099F}, \u{09B8}\u{09BE}\u{0987}\u{09A8} \u{0993} \u{09B8}\u{09CD}\u{0995}\u{09CD}\u{09AF}\u{09BE}\u{09A8}\u{09C7}\u{09B0} \u{09AA}\u{09CD}\u{09B0}\u{09AF}\u{09BC}\u{09CB}\u{099C}\u{09A8} \u{09A8}\u{09C7}\u{0987}\u{0964}",
        .onboardingTitle2: "\u{09AA}\u{09CD}\u{09B0}\u{09AB}\u{09C7}\u{09B6}\u{09A8}\u{09BE}\u{09B2}\n\u{09B8}\u{09BF}\u{0997}\u{09A8}\u{09C7}\u{099A}\u{09BE}\u{09B0}",
        .onboardingSubtitle2: "\u{0986}\u{0981}\u{0995}\u{09C1}\u{09A8}, \u{099F}\u{09BE}\u{0987}\u{09AA} \u{0995}\u{09B0}\u{09C1}\u{09A8} \u{09AC}\u{09BE} \u{09B8}\u{09CD}\u{0995}\u{09CD}\u{09AF}\u{09BE}\u{09A8} \u{0995}\u{09B0}\u{09C1}\u{09A8}\u{0964}",
        .onboardingTitle3: "\u{09A8}\u{09BF}\u{09B0}\u{09BE}\u{09AA}\u{09A6} \u{0993}\n\u{0997}\u{09CB}\u{09AA}\u{09A8}\u{09C0}\u{09AF}\u{09BC}",
        .onboardingSubtitle3: "\u{0986}\u{09AA}\u{09A8}\u{09BE}\u{09B0} \u{09A1}\u{0995}\u{09C1}\u{09AE}\u{09C7}\u{09A8}\u{09CD}\u{099F} \u{0995}\u{0996}\u{09A8}\u{0993} \u{0986}\u{09AA}\u{09A8}\u{09BE}\u{09B0} \u{09A1}\u{09BF}\u{09AD}\u{09BE}\u{0987}\u{09B8} \u{099B}\u{09BE}\u{09DC}\u{09C7} \u{09A8}\u{09BE}\u{0964}",
        .onboardingTitle4: "\u{09B8}\u{09CD}\u{09AE}\u{09BE}\u{09B0}\u{09CD}\u{099F}\u{09B2}\u{09BF} \u{09B8}\u{09BE}\u{0987}\u{09A8}\n\u{0995}\u{09B0}\u{09A4}\u{09C7} \u{09AA}\u{09CD}\u{09B0}\u{09B8}\u{09CD}\u{09A4}\u{09C1}\u{09A4}?",
        .onboardingSubtitle4: "\u{09B2}\u{0995}\u{09CD}\u{09B7} \u{09B2}\u{0995}\u{09CD}\u{09B7} \u{09AA}\u{09C7}\u{09B6}\u{09BE}\u{09A6}\u{09BE}\u{09B0}\u{09A6}\u{09C7}\u{09B0} \u{09B8}\u{09BE}\u{09A5}\u{09C7} \u{09AF}\u{09C1}\u{0995}\u{09CD}\u{09A4} \u{09B9}\u{09A8}\u{0964}",
        .unlockPremium: "\u{09AA}\u{09CD}\u{09B0}\u{09BF}\u{09AE}\u{09BF}\u{09AF}\u{09BC}\u{09BE}\u{09AE} \u{0986}\u{09A8}\u{09B2}\u{0995} \u{0995}\u{09B0}\u{09C1}\u{09A8}",
        .paywallSubtitle: "\u{09B8}\u{09AE}\u{09B8}\u{09CD}\u{09A4} \u{09AB}\u{09BF}\u{099A}\u{09BE}\u{09B0}\u{09C7} \u{0985}\u{09B8}\u{09C0}\u{09AE} \u{0985}\u{09CD}\u{09AF}\u{09BE}\u{0995}\u{09CD}\u{09B8}\u{09C7}\u{09B8} \u{09AA}\u{09BE}\u{09A8}",
        .startFreeTrial: "\u{09AB}\u{09CD}\u{09B0}\u{09BF} \u{099F}\u{09CD}\u{09B0}\u{09BE}\u{09AF}\u{09BC}\u{09BE}\u{09B2} \u{09B6}\u{09C1}\u{09B0}\u{09C1} \u{0995}\u{09B0}\u{09C1}\u{09A8}",
        .myDocuments: "\u{0986}\u{09AE}\u{09BE}\u{09B0} \u{09A1}\u{0995}\u{09C1}\u{09AE}\u{09C7}\u{09A8}\u{09CD}\u{099F}",
        .settings: "\u{09B8}\u{09C7}\u{099F}\u{09BF}\u{0982}\u{09B8}",
    ],
    .spanish: [
        .appName: "Signer",
        .continueButton: "Continuar",
        .skip: "Omitir",
        .getStarted: "Comenzar",
        .selectLanguage: "Selecciona tu idioma",
        .onboardingTitle1: "Firma Documentos\nal Instante",
        .onboardingSubtitle1: "No m\u{00E1}s imprimir, firmar y escanear. Firma cualquier PDF directamente en tu dispositivo.",
        .unlockPremium: "Desbloquear Premium",
        .startFreeTrial: "Iniciar Prueba Gratuita",
        .myDocuments: "Mis Documentos",
        .settings: "Configuraci\u{00F3}n",
    ],
    .french: [
        .appName: "Signer",
        .continueButton: "Continuer",
        .skip: "Passer",
        .getStarted: "Commencer",
        .selectLanguage: "S\u{00E9}lectionnez votre langue",
        .onboardingTitle1: "Signez des Documents\nInstantan\u{00E9}ment",
        .unlockPremium: "D\u{00E9}bloquer Premium",
        .startFreeTrial: "D\u{00E9}marrer l'essai gratuit",
        .myDocuments: "Mes Documents",
        .settings: "Param\u{00E8}tres",
    ],
    .arabic: [
        .appName: "Signer",
        .continueButton: "\u{0627}\u{0633}\u{062A}\u{0645}\u{0631}",
        .skip: "\u{062A}\u{062E}\u{0637}\u{064A}",
        .getStarted: "\u{0627}\u{0628}\u{062F}\u{0623}",
        .selectLanguage: "\u{0627}\u{062E}\u{062A}\u{0631} \u{0644}\u{063A}\u{062A}\u{0643}",
        .onboardingTitle1: "\u{0648}\u{0642}\u{0639} \u{0627}\u{0644}\u{0645}\u{0633}\u{062A}\u{0646}\u{062F}\u{0627}\u{062A}\n\u{0641}\u{0648}\u{0631}\u{0627}\u{064B}",
        .unlockPremium: "\u{0641}\u{062A}\u{062D} \u{0627}\u{0644}\u{0645}\u{0645}\u{064A}\u{0632}",
        .startFreeTrial: "\u{0627}\u{0628}\u{062F}\u{0623} \u{0627}\u{0644}\u{062A}\u{062C}\u{0631}\u{0628}\u{0629} \u{0627}\u{0644}\u{0645}\u{062C}\u{0627}\u{0646}\u{064A}\u{0629}",
        .myDocuments: "\u{0645}\u{0633}\u{062A}\u{0646}\u{062F}\u{0627}\u{062A}\u{064A}",
        .settings: "\u{0627}\u{0644}\u{0625}\u{0639}\u{062F}\u{0627}\u{062F}\u{0627}\u{062A}",
    ],
    .hindi: [
        .appName: "Signer",
        .continueButton: "\u{091C}\u{093E}\u{0930}\u{0940} \u{0930}\u{0916}\u{0947}\u{0902}",
        .skip: "\u{091B}\u{094B}\u{0921}\u{093C}\u{0947}\u{0902}",
        .getStarted: "\u{0936}\u{0941}\u{0930}\u{0942} \u{0915}\u{0930}\u{0947}\u{0902}",
        .selectLanguage: "\u{0905}\u{092A}\u{0928}\u{0940} \u{092D}\u{093E}\u{0937}\u{093E} \u{091A}\u{0941}\u{0928}\u{0947}\u{0902}",
        .onboardingTitle1: "\u{0926}\u{0938}\u{094D}\u{0924}\u{093E}\u{0935}\u{0947}\u{091C}\u{093C} \u{0924}\u{0941}\u{0930}\u{0902}\u{0924}\n\u{0939}\u{0938}\u{094D}\u{0924}\u{093E}\u{0915}\u{094D}\u{0937}\u{0930} \u{0915}\u{0930}\u{0947}\u{0902}",
        .unlockPremium: "\u{092A}\u{094D}\u{0930}\u{0940}\u{092E}\u{093F}\u{092F}\u{092E} \u{0905}\u{0928}\u{0932}\u{0949}\u{0915} \u{0915}\u{0930}\u{0947}\u{0902}",
        .startFreeTrial: "\u{092E}\u{0941}\u{092B}\u{094D}\u{0924} \u{091F}\u{094D}\u{0930}\u{093E}\u{092F}\u{0932} \u{0936}\u{0941}\u{0930}\u{0942} \u{0915}\u{0930}\u{0947}\u{0902}",
        .myDocuments: "\u{092E}\u{0947}\u{0930}\u{0947} \u{0926}\u{0938}\u{094D}\u{0924}\u{093E}\u{0935}\u{0947}\u{091C}\u{093C}",
        .settings: "\u{0938}\u{0947}\u{091F}\u{093F}\u{0902}\u{0917}\u{094D}\u{0938}",
    ],
]
