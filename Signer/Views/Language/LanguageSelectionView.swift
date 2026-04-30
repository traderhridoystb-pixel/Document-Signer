import SwiftUI

struct LanguageSelectionView: View {
    @Environment(AppFlowViewModel.self) private var flowViewModel
    @Environment(LocalizationManager.self) private var localization
    @State private var selectedLanguage: SupportedLanguage
    @State private var searchText = ""
    @State private var isAnimated = false

    init() {
        _selectedLanguage = State(initialValue: LocalizationManager.detectSystemLanguage())
    }

    var filteredLanguages: [SupportedLanguage] {
        if searchText.isEmpty {
            return SupportedLanguage.allCases
        }
        return SupportedLanguage.allCases.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.nativeName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(SignerColors.primaryGradient)
                    .padding(.top, 20)
                    .fadeSlideIn(delay: 0.1)

                Text(localization.localized(.selectLanguage))
                    .font(SignerTypography.title1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(SignerColors.textPrimary)
                    .fadeSlideIn(delay: 0.2)

                Text(localization.localized(.selectLanguageSubtitle))
                    .font(SignerTypography.subheadline)
                    .foregroundColor(SignerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fadeSlideIn(delay: 0.3)
            }
            .padding(.bottom, 20)

            // Auto-detected badge
            if selectedLanguage == LocalizationManager.detectSystemLanguage() {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text(localization.localized(.autoDetected))
                        .font(SignerTypography.caption1)
                }
                .foregroundColor(SignerColors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(SignerColors.primaryUltraLight)
                )
                .fadeSlideIn(delay: 0.4)
                .padding(.bottom, 12)
            }

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(SignerColors.textTertiary)
                TextField("Search languages...", text: $searchText)
                    .font(SignerTypography.body)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(SignerColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Language List
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredLanguages) { language in
                        LanguageRow(
                            language: language,
                            isSelected: selectedLanguage == language,
                            action: {
                                HapticManager.selection()
                                withAnimation(.spring(response: 0.3)) {
                                    selectedLanguage = language
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            // Continue Button
            Button(action: {
                HapticManager.impact(.medium)
                localization.currentLanguage = selectedLanguage
                flowViewModel.completeLanguageSelection()
            }) {
                Text(localization.localized(.continueButton))
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .fadeSlideIn(delay: 0.5)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Language Row
struct LanguageRow: View {
    let language: SupportedLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(language.flag)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(SignerTypography.bodyMedium)
                        .foregroundColor(SignerColors.textPrimary)

                    if language.nativeName != language.displayName {
                        Text(language.nativeName)
                            .font(SignerTypography.caption1)
                            .foregroundColor(SignerColors.textSecondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(SignerColors.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .fill(isSelected ? SignerColors.primaryUltraLight : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .stroke(isSelected ? SignerColors.primary.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
