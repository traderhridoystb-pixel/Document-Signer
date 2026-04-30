import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppFlowViewModel.self) private var flowViewModel
    @Environment(LocalizationManager.self) private var localization
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    let isFromOnboarding: Bool
    @State private var selectedPlan: PlanType = .yearly
    @State private var isAnimated = false
    @State private var isPurchasing = false

    enum PlanType {
        case yearly
        case lifetime
    }

    var body: some View {
        ZStack {
            // Background
            ScrollView {
                VStack(spacing: 0) {
                    // Close / Skip button
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.impact(.light)
                            if isFromOnboarding {
                                flowViewModel.completePaywall()
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(SignerColors.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Premium Header
                    premiumHeader
                        .fadeSlideIn(delay: 0.1)

                    // Features list
                    premiumFeatures
                        .fadeSlideIn(delay: 0.2)

                    // Plan selection
                    planSelection
                        .fadeSlideIn(delay: 0.3)

                    // CTA Button
                    ctaButton
                        .fadeSlideIn(delay: 0.4)

                    // Legal links
                    legalSection
                        .fadeSlideIn(delay: 0.5)
                }
                .padding(.bottom, 32)
            }

            // Loading overlay
            if isPurchasing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Premium Header
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .shadow(color: Color(hex: "F59E0B").opacity(0.4), radius: 16, x: 0, y: 8)

            Text(localization.localized(.unlockPremium))
                .font(SignerTypography.title1)
                .foregroundColor(SignerColors.textPrimary)

            Text(localization.localized(.paywallSubtitle))
                .font(SignerTypography.subheadline)
                .foregroundColor(SignerColors.textSecondary)
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    // MARK: - Features
    private var premiumFeatures: some View {
        VStack(spacing: 12) {
            FeatureRow(icon: "signature", text: "Unlimited Signatures", color: SignerColors.primary)
            FeatureRow(icon: "doc.on.doc", text: "Unlimited Documents", color: Color(hex: "7C3AED"))
            FeatureRow(icon: "seal.fill", text: "All Stamp Templates", color: Color(hex: "059669"))
            FeatureRow(icon: "square.and.arrow.up", text: "Export & Share", color: Color(hex: "F59E0B"))
            FeatureRow(icon: "paintbrush", text: "Advanced Editing Tools", color: Color(hex: "EF4444"))
            FeatureRow(icon: "xmark.rectangle", text: "No Watermarks", color: Color(hex: "EC4899"))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

    // MARK: - Plan Selection
    private var planSelection: some View {
        VStack(spacing: 12) {
            // Yearly Plan
            PlanCard(
                isSelected: selectedPlan == .yearly,
                badge: localization.localized(.freeTrial),
                title: localization.localized(.yearlyPlan),
                price: storeKit.yearlyProduct?.displayPrice ?? "$29.99",
                subtitle: "\(localization.localized(.freeTrialDescription)) \(storeKit.yearlyProduct?.displayPrice ?? "$29.99")/yr",
                perMonth: storeKit.yearlyPricePerMonth.isEmpty ? "$2.50" : storeKit.yearlyPricePerMonth,
                action: {
                    HapticManager.selection()
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = .yearly
                    }
                }
            )

            // Lifetime Plan
            PlanCard(
                isSelected: selectedPlan == .lifetime,
                badge: localization.localized(.bestValue),
                title: localization.localized(.lifetimePlan),
                price: storeKit.lifetimeProduct?.displayPrice ?? "$49.99",
                subtitle: localization.localized(.oneTimePurchase),
                perMonth: nil,
                action: {
                    HapticManager.selection()
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = .lifetime
                    }
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task { await handlePurchase() }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: selectedPlan == .yearly ? "play.fill" : "crown.fill")
                        .font(.system(size: 14))
                    Text(selectedPlan == .yearly
                         ? localization.localized(.startFreeTrial)
                         : "Get Lifetime Access")
                        .font(SignerTypography.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [SignerColors.primary, SignerColors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: SignerRadius.lg))
                .shadow(color: SignerColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .disabled(isPurchasing)

            if selectedPlan == .yearly {
                Text("\(AppConstants.freeTrialDays)-day free trial \u{2022} Cancel anytime")
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.textTertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: 12) {
            // Restore Purchases
            Button(action: {
                Task {
                    await storeKit.restorePurchases()
                    if storeKit.isPremium {
                        HapticManager.notification(.success)
                        if isFromOnboarding {
                            flowViewModel.completePaywall()
                        } else {
                            dismiss()
                        }
                    }
                }
            }) {
                Text(localization.localized(.restorePurchase))
                    .font(SignerTypography.footnote)
                    .foregroundColor(SignerColors.primary)
            }

            // Terms & Privacy
            HStack(spacing: 16) {
                Link(localization.localized(.termsOfUse),
                     destination: URL(string: AppConstants.termsURL)!)
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.textTertiary)

                Text("\u{2022}")
                    .foregroundColor(SignerColors.textTertiary)

                Link(localization.localized(.privacyPolicy),
                     destination: URL(string: AppConstants.privacyPolicyURL)!)
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.textTertiary)
            }

            Text("Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                .font(SignerTypography.caption2)
                .foregroundColor(SignerColors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Purchase Handler
    private func handlePurchase() async {
        isPurchasing = true
        defer { isPurchasing = false }

        let product: Product?
        switch selectedPlan {
        case .yearly:
            product = storeKit.yearlyProduct
        case .lifetime:
            product = storeKit.lifetimeProduct
        }

        guard let product else { return }

        do {
            let transaction = try await storeKit.purchase(product)
            if transaction != nil {
                HapticManager.notification(.success)
                if isFromOnboarding {
                    flowViewModel.completePaywall()
                } else {
                    dismiss()
                }
            }
        } catch {
            HapticManager.notification(.error)
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(text)
                .font(SignerTypography.bodyMedium)
                .foregroundColor(SignerColors.textPrimary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(SignerColors.accent)
        }
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let isSelected: Bool
    let badge: String
    let title: String
    let price: String
    let subtitle: String
    let perMonth: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Badge
                if !badge.isEmpty {
                    Text(badge)
                        .font(SignerTypography.caption1)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            isSelected
                            ? SignerColors.primaryGradient
                            : LinearGradient(colors: [SignerColors.neutral400, SignerColors.neutral500],
                                             startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .offset(y: -8)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(SignerTypography.headline)
                            .foregroundColor(SignerColors.textPrimary)

                        Text(subtitle)
                            .font(SignerTypography.caption1)
                            .foregroundColor(SignerColors.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(price)
                            .font(SignerTypography.title3)
                            .foregroundColor(SignerColors.textPrimary)

                        if let perMonth {
                            Text("\(perMonth)/mo")
                                .font(SignerTypography.caption1)
                                .foregroundColor(SignerColors.primary)
                        }
                    }

                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? SignerColors.primary : SignerColors.neutral300)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, badge.isEmpty ? 16 : 12)
            }
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.lg)
                    .fill(Color(.systemBackground))
                    .shadow(color: isSelected ? SignerColors.primary.opacity(0.15) : Color.black.opacity(0.05),
                            radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SignerRadius.lg)
                    .stroke(isSelected ? SignerColors.primary : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
