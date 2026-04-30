import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(StoreKitManager.self) private var storeKit
    @Binding var showingPaywall: Bool
    @State private var showingLanguagePicker = false
    @State private var showingRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // Premium Section
                if !storeKit.isPremium {
                    Section {
                        Button(action: { showingPaywall = true }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)

                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Upgrade to Premium")
                                        .font(SignerTypography.bodyMedium)
                                        .foregroundColor(SignerColors.textPrimary)

                                    Text("Unlock all features")
                                        .font(SignerTypography.caption1)
                                        .foregroundColor(SignerColors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(SignerColors.textTertiary)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                } else {
                    Section {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(SignerColors.accent)
                                    .frame(width: 40, height: 40)

                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Premium Active")
                                    .font(SignerTypography.bodyMedium)
                                    .foregroundColor(SignerColors.textPrimary)

                                Text("All features unlocked")
                                    .font(SignerTypography.caption1)
                                    .foregroundColor(SignerColors.accent)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                }

                // Subscription
                Section(header: Text("Subscription")) {
                    Button(action: {
                        Task { await storeKit.restorePurchases() }
                        restoreMessage = storeKit.isPremium
                            ? "Purchase restored successfully!"
                            : "No previous purchase found."
                        showingRestoreAlert = true
                    }) {
                        SettingsRow(
                            icon: "arrow.clockwise",
                            iconColor: SignerColors.primary,
                            title: localization.localized(.restorePurchase)
                        )
                    }

                    Button(action: {
                        Task { await storeKit.showManageSubscription() }
                    }) {
                        SettingsRow(
                            icon: "creditcard",
                            iconColor: Color(hex: "7C3AED"),
                            title: localization.localized(.manageSubscription)
                        )
                    }
                }

                // Preferences
                Section(header: Text("Preferences")) {
                    Button(action: { showingLanguagePicker = true }) {
                        HStack {
                            SettingsRow(
                                icon: "globe",
                                iconColor: Color(hex: "3B82F6"),
                                title: localization.localized(.language)
                            )
                            Spacer()
                            Text(localization.currentLanguage.displayName)
                                .font(SignerTypography.subheadline)
                                .foregroundColor(SignerColors.textSecondary)
                        }
                    }
                }

                // Legal
                Section(header: Text("Legal")) {
                    Link(destination: URL(string: AppConstants.privacyPolicyURL)!) {
                        SettingsRow(
                            icon: "hand.raised",
                            iconColor: Color(hex: "059669"),
                            title: localization.localized(.privacyPolicy)
                        )
                    }

                    Link(destination: URL(string: AppConstants.termsURL)!) {
                        SettingsRow(
                            icon: "doc.text",
                            iconColor: Color(hex: "F59E0B"),
                            title: localization.localized(.termsOfUse)
                        )
                    }
                }

                // Support
                Section(header: Text("Support")) {
                    Link(destination: URL(string: "mailto:\(AppConstants.supportEmail)")!) {
                        SettingsRow(
                            icon: "envelope",
                            iconColor: Color(hex: "EF4444"),
                            title: localization.localized(.contactSupport),
                            subtitle: AppConstants.supportEmail
                        )
                    }

                    Button(action: requestAppReview) {
                        SettingsRow(
                            icon: "star",
                            iconColor: Color(hex: "F59E0B"),
                            title: localization.localized(.rateApp)
                        )
                    }

                    Button(action: shareApp) {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: SignerColors.primary,
                            title: localization.localized(.shareApp)
                        )
                    }
                }

                // About
                Section(header: Text("About")) {
                    HStack {
                        SettingsRow(
                            icon: "info.circle",
                            iconColor: SignerColors.neutral500,
                            title: localization.localized(.version)
                        )
                        Spacer()
                        Text(appVersion)
                            .font(SignerTypography.subheadline)
                            .foregroundColor(SignerColors.textSecondary)
                    }
                }
            }
            .navigationTitle(localization.localized(.settings))
            .sheet(isPresented: $showingLanguagePicker) {
                LanguagePickerSheet()
            }
            .alert("Restore Purchase", isPresented: $showingRestoreAlert) {
                Button("OK") {}
            } message: {
                Text(restoreMessage)
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func requestAppReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func shareApp() {
        let text = "Check out Signer - the best document signing app!"
        let url = URL(string: "https://apps.apple.com/app/signer")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(iconColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SignerTypography.body)
                    .foregroundColor(SignerColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(SignerTypography.caption1)
                        .foregroundColor(SignerColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Language Picker Sheet
struct LanguagePickerSheet: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(SupportedLanguage.allCases) { language in
                Button(action: {
                    localization.currentLanguage = language
                    HapticManager.selection()
                    dismiss()
                }) {
                    HStack(spacing: 14) {
                        Text(language.flag)
                            .font(.system(size: 24))

                        Text(language.displayName)
                            .font(SignerTypography.body)
                            .foregroundColor(SignerColors.textPrimary)

                        Spacer()

                        if localization.currentLanguage == language {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(SignerColors.primary)
                        }
                    }
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - SKStoreReviewController import
import StoreKit
