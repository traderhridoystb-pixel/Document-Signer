import XCTest
@testable import Signer

final class SignerTests: XCTestCase {

    // MARK: - Document Model Tests
    func testDocumentCreation() {
        let url = URL(fileURLWithPath: "/tmp/test.pdf")
        let doc = SignerDocument(name: "Test Document", fileURL: url)

        XCTAssertEqual(doc.name, "Test Document")
        XCTAssertEqual(doc.fileURL, url)
        XCTAssertFalse(doc.isSigned)
        XCTAssertEqual(doc.pageCount, 1)
        XCTAssertTrue(doc.annotations.isEmpty)
    }

    func testDocumentAnnotation() {
        let annotation = DocumentAnnotation(
            type: .signature,
            position: CGPoint(x: 100, y: 200),
            size: CGSize(width: 200, height: 80),
            pageIndex: 0
        )

        XCTAssertEqual(annotation.type, .signature)
        XCTAssertEqual(annotation.position.x, 100)
        XCTAssertEqual(annotation.position.y, 200)
        XCTAssertEqual(annotation.pageIndex, 0)
    }

    // MARK: - Annotation Type Tests
    func testAnnotationTypeIcons() {
        XCTAssertEqual(AnnotationType.signature.icon, "signature")
        XCTAssertEqual(AnnotationType.text.icon, "textformat")
        XCTAssertEqual(AnnotationType.date.icon, "calendar")
        XCTAssertEqual(AnnotationType.stamp.icon, "seal")
        XCTAssertEqual(AnnotationType.checkbox.icon, "checkmark.square")
    }

    func testAnnotationTypeDisplayNames() {
        XCTAssertEqual(AnnotationType.signature.displayName, "Signature")
        XCTAssertEqual(AnnotationType.initials.displayName, "Initials")
        XCTAssertEqual(AnnotationType.text.displayName, "Text")
    }

    // MARK: - Signature Model Tests
    func testSavedSignatureCreation() {
        let data = Data([0x00, 0x01, 0x02])
        let sig = SavedSignature(name: "Test Sig", imageData: data, isDefault: true)

        XCTAssertEqual(sig.name, "Test Sig")
        XCTAssertTrue(sig.isDefault)
        XCTAssertEqual(sig.type, .signature)
    }

    // MARK: - Stamp Template Tests
    func testStampPresets() {
        let presets = StampTemplate.presets
        XCTAssertGreaterThanOrEqual(presets.count, 10)

        let approvedStamp = presets.first { $0.name == "Approved" }
        XCTAssertNotNil(approvedStamp)
        XCTAssertEqual(approvedStamp?.text, "APPROVED")
    }

    // MARK: - Language Tests
    func testSupportedLanguages() {
        XCTAssertGreaterThanOrEqual(SupportedLanguage.allCases.count, 20)

        XCTAssertEqual(SupportedLanguage.english.rawValue, "en")
        XCTAssertEqual(SupportedLanguage.bengali.rawValue, "bn")
        XCTAssertEqual(SupportedLanguage.spanish.rawValue, "es")
    }

    func testLanguageDisplayNames() {
        XCTAssertEqual(SupportedLanguage.english.displayName, "English")
        XCTAssertFalse(SupportedLanguage.english.flag.isEmpty)
    }

    // MARK: - App Constants Tests
    func testAppConstants() {
        XCTAssertEqual(AppConstants.appName, "Signer")
        XCTAssertEqual(AppConstants.supportEmail, "developer.nasar416@gmail.com")
        XCTAssertEqual(AppConstants.freeTrialDays, 3)
        XCTAssertEqual(AppConstants.freeDocumentSignLimit, 3)
    }

    // MARK: - Color Extension Tests
    func testHexColorInitialization() {
        let color = Color(hex: "2563EB")
        XCTAssertNotNil(color)

        let colorWithHash = Color(hex: "#FF0000")
        XCTAssertNotNil(colorWithHash)
    }

    // MARK: - App Flow Tests
    func testAppFlowInitialState() {
        let viewModel = AppFlowViewModel()
        XCTAssertEqual(viewModel.currentState, .splash)
    }

    // MARK: - Localization Tests
    func testLocalizationManagerInstance() {
        let manager = LocalizationManager.shared
        XCTAssertNotNil(manager)
        XCTAssertNotNil(manager.currentLanguage)
    }

    func testLocalizedString() {
        let manager = LocalizationManager.shared
        manager.currentLanguage = .english
        let appName = manager.localized(.appName)
        XCTAssertEqual(appName, "Signer")
    }
}
