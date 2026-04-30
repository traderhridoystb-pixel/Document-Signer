import RevenueCat
import RevenueCatUI
import SwiftUI

// MARK: - Signer Paywall Screen
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

// MARK: - Custom Paywall (Dark Theme, Side-by-Side Cards)
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

    private let darkBg = Color(hex: "0A0E1A")
    private let cardBg = Color(hex: "141A2E")
    private let cardBorder = Color(hex: "1E2642")
    private let accentOrange = Color(hex: "FF8C00")
    private let accentCyan = Color(hex: "00D4FF")
    private let ctaYellow = Color(hex: "FFD60A")

    var body: some View {
        GeometryReader { geo in
            ZStack {
                darkBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    closeButton
                    Spacer(minLength: 0)
                    headerSection(geo: geo)
                    Spacer(minLength: 6)
                    featuresCard(geo: geo)
                    Spacer(minLength: 8)
                    planCards(geo: geo)
                    Spacer(minLength: 8)
                    ctaSection(geo: geo)
                    Spacer(minLength: 4)
                    legalSection(geo: geo)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)

                if isPurchasing {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView().tint(.white).scaleEffect(1.5)
                }
            }
        }
        .task {
            await revenueCat.fetchOfferings()
        }
    }

    // MARK: - Close Button
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: {
                HapticManager.impact(.light)
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Header
    private func headerSection(geo: GeometryProxy) -> some View {
        let isCompact = geo.size.height < 700

        return VStack(spacing: isCompact ? 4 : 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 50 : 64, height: isCompact ? 50 : 64)
                    .shadow(color: Color(hex: "F59E0B").opacity(0.5), radius: 12, x: 0, y: 6)

                Image(systemName: "crown.fill")
                    .font(.system(size: isCompact ? 22 : 28))
                    .foregroundColor(.white)
            }

            Text(localization.localized(.appName))
                .font(.system(size: isCompact ? 22 : 28, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(localization.localized(.paywallSubtitle))
                .font(.system(size: isCompact ? 12 : 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Features Card
    private func featuresCard(geo: GeometryProxy) -> some View {
        let isCompact = geo.size.height < 700
        let iconSize: CGFloat = isCompact ? 28 : 32
        let fontSize: CGFloat = isCompact ? 13 : 14
        let spacing: CGFloat = isCompact ? 8 : 10

        return VStack(spacing: spacing) {
            PaywallFeatureRow(icon: "signature", text: "Unlimited Signatures", color: SignerColors.primary, iconSize: iconSize, fontSize: fontSize)
            PaywallFeatureRow(icon: "doc.on.doc", text: "Unlimited Documents", color: Color(hex: "7C3AED"), iconSize: iconSize, fontSize: fontSize)
            PaywallFeatureRow(icon: "seal.fill", text: "All Stamp Templates", color: Color(hex: "059669"), iconSize: iconSize, fontSize: fontSize)
            PaywallFeatureRow(icon: "square.and.arrow.up", text: "Export & Share", color: Color(hex: "F59E0B"), iconSize: iconSize, fontSize: fontSize)
            PaywallFeatureRow(icon: "paintbrush", text: "Advanced Editing Tools", color: Color(hex: "EF4444"), iconSize: iconSize, fontSize: fontSize)
            PaywallFeatureRow(icon: "xmark.rectangle", text: "No Watermarks", color: Color(hex: "EC4899"), iconSize: iconSize, fontSize: fontSize)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isCompact ? 10 : 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(cardBorder, lineWidth: 1)
                )
        )
    }

    // MARK: - Plan Cards (Side-by-Side)
    private func planCards(geo: GeometryProxy) -> some View {
        let isCompact = geo.size.height < 700
        let cardWidth = (geo.size.width - 52) / 2

        return HStack(spacing: 12) {
            // Yearly Card
            yearlyCard(width: cardWidth, isCompact: isCompact)
            // Lifetime Card
            lifetimeCard(width: cardWidth, isCompact: isCompact)
        }
    }

    private func yearlyCard(width: CGFloat, isCompact: Bool) -> some View {
        Button(action: {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3)) { selectedPlan = .yearly }
        }) {
            VStack(spacing: isCompact ? 6 : 8) {
                // Badge
                Text(localization.localized(.freeTrial))
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(accentOrange)
                    )

                // Radio + Label
                HStack(spacing: 6) {
                    Image(systemName: selectedPlan == .yearly ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundColor(selectedPlan == .yearly ? accentCyan : .white.opacity(0.3))
                    Text(localization.localized(.bestValue).uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(localization.localized(.yearlyPlan))
                    .font(.system(size: isCompact ? 14 : 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Monthly price highlighted
                if let yearlyPkg = revenueCat.yearlyPackage {
                    let monthlyPrice = yearlyPkg.storeProduct.price / 12
                    let monthlyStr = monthlyPrice.formatted(.currency(code: yearlyPkg.storeProduct.currencyCode ?? "USD"))

                    Text(monthlyStr)
                        .font(.system(size: isCompact ? 24 : 28, weight: .black, design: .rounded))
                        .foregroundColor(accentOrange)
                    + Text("/monthly")
                        .font(.system(size: isCompact ? 11 : 12, weight: .bold))
                        .foregroundColor(accentOrange.opacity(0.8))

                    Text("\(monthlyStr)/monthly \u{2022} \(yearlyPkg.storeProduct.localizedPriceString)/yearly")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                        Text("Start \(AppConstants.freeTrialDays)-Day Free Trial")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(accentOrange)
                } else {
                    Text("--")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(accentOrange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isCompact ? 10 : 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedPlan == .yearly ? accentCyan : cardBorder, lineWidth: selectedPlan == .yearly ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func lifetimeCard(width: CGFloat, isCompact: Bool) -> some View {
        Button(action: {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3)) { selectedPlan = .lifetime }
        }) {
            VStack(spacing: isCompact ? 6 : 8) {
                // Badge
                Text(localization.localized(.popular).uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )

                // Radio + Label
                HStack(spacing: 6) {
                    Image(systemName: selectedPlan == .lifetime ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundColor(selectedPlan == .lifetime ? accentCyan : .white.opacity(0.3))
                    Text(localization.localized(.lifetimePlan).uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(localization.localized(.lifetimePlan))
                    .font(.system(size: isCompact ? 14 : 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if let lifetimePkg = revenueCat.lifetimePackage {
                    Text(lifetimePkg.storeProduct.localizedPriceString)
                        .font(.system(size: isCompact ? 24 : 28, weight: .black, design: .rounded))
                        .foregroundColor(accentOrange)

                    Text(localization.localized(.oneTimePurchase))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))

                    Text(localization.localized(.unlockLifetimeAccess))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(accentOrange)
                } else {
                    Text("--")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(accentOrange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isCompact ? 10 : 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedPlan == .lifetime ? accentCyan : cardBorder, lineWidth: selectedPlan == .lifetime ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA Button
    private func ctaSection(geo: GeometryProxy) -> some View {
        let isCompact = geo.size.height < 700

        return VStack(spacing: isCompact ? 4 : 6) {
            Button(action: {
                Task { await handlePurchase() }
            }) {
                HStack(spacing: 8) {
                    Text(selectedPlan == .yearly
                         ? localization.localized(.startFreeTrial).uppercased()
                         : localization.localized(.unlockLifetimeAccess).uppercased())
                        .font(.system(size: isCompact ? 15 : 16, weight: .heavy))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .heavy))
                }
                .foregroundColor(darkBg)
                .frame(maxWidth: .infinity)
                .frame(height: isCompact ? 50 : 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ctaYellow)
                        .shadow(color: ctaYellow.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .disabled(isPurchasing)

            if selectedPlan == .yearly {
                Text("\(AppConstants.freeTrialDays)-day free trial, then \(revenueCat.yearlyPackage?.storeProduct.localizedPriceString ?? "") yearly \u{2022} Cancel anytime")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            } else {
                Text("One-time purchase. Lifetime access on this Apple ID.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Legal Section
    private func legalSection(geo: GeometryProxy) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                Button(action: {
                    Task {
                        let restored = await revenueCat.restorePurchases()
                        if restored { onPurchaseCompleted() }
                    }
                }) {
                    Text(localization.localized(.restorePurchase))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }

                Text("  |  ").foregroundColor(.white.opacity(0.25))
                    .font(.system(size: 11))

                Link(localization.localized(.privacyPolicy),
                     destination: URL(string: AppConstants.privacyPolicyURL)!)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                Text("  |  ").foregroundColor(.white.opacity(0.25))
                    .font(.system(size: 11))

                Link(localization.localized(.termsOfUse),
                     destination: URL(string: AppConstants.termsURL)!)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            if selectedPlan == .yearly {
                Text("Auto-renews unless cancelled at least 24 hours before period ends. Cancel in Settings.")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
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

// MARK: - Paywall Feature Row
struct PaywallFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    var iconSize: CGFloat = 32
    var fontSize: CGFloat = 14

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: iconSize, height: iconSize)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(text)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "00D4FF"))
        }
    }
}

// MARK: - Conditional Paywall Modifier
extension View {
    func presentSignerPaywallIfNeeded() -> some View {
        self.presentPaywallIfNeeded(
            requiredEntitlementIdentifier: RevenueCatConfig.entitlementID
        )
    }
}
