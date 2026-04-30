import RevenueCat
import RevenueCatUI
import SwiftUI

// MARK: - Signer Paywall Screen
/// Main paywall entry point used throughout the app.
/// Attempts to display RevenueCat's remote-configured paywall first,
/// falling back to a custom-built paywall when no remote paywall is configured.
struct SignerPaywallView: View {
    @Environment(AppFlowViewModel.self) private var flowViewModel
    @Environment(\.dismiss) private var dismiss

    let isFromOnboarding: Bool

    var body: some View {
        RevenueCatPaywallContainer(
            isFromOnboarding: isFromOnboarding,
            onDismiss: {
                if isFromOnboarding {
                    flowViewModel.completePaywall()
                } else {
                    dismiss()
                }
            },
            onPurchaseCompleted: {
                HapticManager.notification(.success)
                if isFromOnboarding {
                    flowViewModel.completePaywall()
                } else {
                    dismiss()
                }
            }
        )
    }
}

// MARK: - RevenueCat Paywall Container
/// Loads the current offering and decides whether to use RevenueCat's
/// remote paywall template or the custom fallback paywall.
struct RevenueCatPaywallContainer: View {
    let isFromOnboarding: Bool
    let onDismiss: () -> Void
    let onPurchaseCompleted: () -> Void

    @State private var offering: Offering?
    @State private var isLoading = true
    @State private var hasRemotePaywall = false

    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    ProgressView().scaleEffect(1.3)
                }
            } else if hasRemotePaywall, let offering {
                RevenueCatUI.PaywallView(offering: offering, displayCloseButton: false)
                    .onPurchaseCompleted { _ in
                        onPurchaseCompleted()
                    }
                    .onRestoreCompleted { _ in
                        Task { @MainActor in
                            await RevenueCatManager.shared.fetchCustomerInfo()
                            if RevenueCatManager.shared.isPremium {
                                onPurchaseCompleted()
                            }
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        Button(action: { onDismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(SignerColors.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 12)
                    }
            } else {
                // Custom fallback paywall
                CustomPaywallView(
                    isFromOnboarding: isFromOnboarding,
                    onDismiss: onDismiss,
                    onPurchaseCompleted: onPurchaseCompleted
                )
            }
        }
        .task {
            await loadOffering()
        }
    }

    private func loadOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offering = offerings.current
            self.hasRemotePaywall = offerings.current?.paywall != nil
        } catch {
            self.hasRemotePaywall = false
        }
        self.isLoading = false
    }
}

// MARK: - Custom Paywall (Fallback)
struct CustomPaywallView: View {
    @Environment(LocalizationManager.self) private var localization

    let isFromOnboarding: Bool
    let onDismiss: () -> Void
    let onPurchaseCompleted: () -> Void

    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    @State private var revenueCat = RevenueCatManager.shared

    enum PlanType {
        case yearly
        case lifetime
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.impact(.light)
                            onDismiss()
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

                    premiumHeader
                        .fadeSlideIn(delay: 0.1)

                    premiumFeatures
                        .fadeSlideIn(delay: 0.2)

                    planSelection
                        .fadeSlideIn(delay: 0.3)

                    ctaButton
                        .fadeSlideIn(delay: 0.4)

                    legalSection
                        .fadeSlideIn(delay: 0.5)
                }
                .padding(.bottom, 32)
            }

            if isPurchasing {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white).scaleEffect(1.5)
            }
        }
        .background(Color(.systemBackground))
        .task {
            await revenueCat.fetchOfferings()
        }
    }

    // MARK: - Premium Header
    private var premiumHeader: some View {
        VStack(spacing: 16) {
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
            if let yearlyPkg = revenueCat.yearlyPackage {
                PlanCard(
                    isSelected: selectedPlan == .yearly,
                    badge: localization.localized(.freeTrial),
                    title: localization.localized(.yearlyPlan),
                    price: yearlyPkg.storeProduct.localizedPriceString,
                    subtitle: "\(localization.localized(.freeTrialDescription)) \(yearlyPkg.storeProduct.localizedPriceString)/yr",
                    perMonth: revenueCat.yearlyPricePerMonth,
                    action: {
                        HapticManager.selection()
                        withAnimation(.spring(response: 0.3)) { selectedPlan = .yearly }
                    }
                )
            }

            if let lifetimePkg = revenueCat.lifetimePackage {
                PlanCard(
                    isSelected: selectedPlan == .lifetime,
                    badge: localization.localized(.bestValue),
                    title: localization.localized(.lifetimePlan),
                    price: lifetimePkg.storeProduct.localizedPriceString,
                    subtitle: localization.localized(.oneTimePurchase),
                    perMonth: nil,
                    action: {
                        HapticManager.selection()
                        withAnimation(.spring(response: 0.3)) { selectedPlan = .lifetime }
                    }
                )
            }
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
            Button(action: {
                Task {
                    let restored = await revenueCat.restorePurchases()
                    if restored { onPurchaseCompleted() }
                }
            }) {
                Text(localization.localized(.restorePurchase))
                    .font(SignerTypography.footnote)
                    .foregroundColor(SignerColors.primary)
            }

            HStack(spacing: 16) {
                Link(localization.localized(.termsOfUse),
                     destination: URL(string: AppConstants.termsURL)!)
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.textTertiary)

                Text("\u{2022}").foregroundColor(SignerColors.textTertiary)

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

        let package: Package?
        switch selectedPlan {
        case .yearly:
            package = revenueCat.yearlyPackage
        case .lifetime:
            package = revenueCat.lifetimePackage
        }

        guard let package else { return }

        let success = await revenueCat.purchase(package: package)
        if success {
            onPurchaseCompleted()
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

// MARK: - Conditional Paywall Modifier
/// Use on any view to automatically show the paywall when the user is not premium.
/// Example: `.presentSignerPaywallIfNeeded()`
extension View {
    func presentSignerPaywallIfNeeded() -> some View {
        self.presentPaywallIfNeeded(
            requiredEntitlementIdentifier: RevenueCatConfig.entitlementID
        )
    }
}
