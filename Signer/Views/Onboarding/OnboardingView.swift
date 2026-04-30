import SwiftUI

struct OnboardingView: View {
    @Environment(AppFlowViewModel.self) private var flowViewModel
    @Environment(LocalizationManager.self) private var localization
    @State private var currentPage = 0
    @State private var isAnimating = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "pencil.and.outline",
            iconColor: Color(hex: "2563EB"),
            backgroundGradient: [Color(hex: "EFF6FF"), Color(hex: "DBEAFE")],
            darkBackgroundGradient: [Color(hex: "1E293B"), Color(hex: "0F172A")],
            titleKey: .onboardingTitle1,
            subtitleKey: .onboardingSubtitle1,
            features: [
                OnboardingFeature(icon: "doc.text", text: "PDF, DOCX, PNG & more"),
                OnboardingFeature(icon: "bolt.fill", text: "Sign in seconds"),
                OnboardingFeature(icon: "iphone", text: "Works on all devices"),
            ]
        ),
        OnboardingPage(
            icon: "signature",
            iconColor: Color(hex: "7C3AED"),
            backgroundGradient: [Color(hex: "F5F3FF"), Color(hex: "EDE9FE")],
            darkBackgroundGradient: [Color(hex: "1E1B4B"), Color(hex: "0F0B2E")],
            titleKey: .onboardingTitle2,
            subtitleKey: .onboardingSubtitle2,
            features: [
                OnboardingFeature(icon: "hand.draw", text: "Draw your signature"),
                OnboardingFeature(icon: "textformat", text: "Type & customize"),
                OnboardingFeature(icon: "seal", text: "Professional stamps"),
            ]
        ),
        OnboardingPage(
            icon: "lock.shield",
            iconColor: Color(hex: "059669"),
            backgroundGradient: [Color(hex: "ECFDF5"), Color(hex: "D1FAE5")],
            darkBackgroundGradient: [Color(hex: "064E3B"), Color(hex: "022C22")],
            titleKey: .onboardingTitle3,
            subtitleKey: .onboardingSubtitle3,
            features: [
                OnboardingFeature(icon: "iphone.and.arrow.forward", text: "100% offline capable"),
                OnboardingFeature(icon: "lock.fill", text: "Bank-grade encryption"),
                OnboardingFeature(icon: "hand.raised.fill", text: "No data collection"),
            ]
        ),
        OnboardingPage(
            icon: "sparkles",
            iconColor: Color(hex: "F59E0B"),
            backgroundGradient: [Color(hex: "FFFBEB"), Color(hex: "FEF3C7")],
            darkBackgroundGradient: [Color(hex: "451A03"), Color(hex: "27150A")],
            titleKey: .onboardingTitle4,
            subtitleKey: .onboardingSubtitle4,
            features: [
                OnboardingFeature(icon: "star.fill", text: "4.9 star rating"),
                OnboardingFeature(icon: "person.3.fill", text: "Millions of users"),
                OnboardingFeature(icon: "leaf.fill", text: "Save paper & time"),
            ]
        ),
    ]

    var body: some View {
        ZStack {
            // Background
            backgroundView
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.impact(.light)
                        flowViewModel.completeOnboarding()
                    }) {
                        Text(localization.localized(.skip))
                            .font(SignerTypography.subheadline)
                            .foregroundColor(SignerColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, localization: localization)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section
                VStack(spacing: 20) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? SignerColors.primary : SignerColors.neutral300)
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Continue / Get Started button
                    Button(action: {
                        HapticManager.impact(.medium)
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            flowViewModel.completeOnboarding()
                        }
                    }) {
                        Text(currentPage == pages.count - 1
                             ? localization.localized(.getStarted)
                             : localization.localized(.continueButton))
                            .primaryButtonStyle()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        let page = pages[currentPage]
        LinearGradient(
            colors: page.backgroundGradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let backgroundGradient: [Color]
    let darkBackgroundGradient: [Color]
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    let features: [OnboardingFeature]
}

struct OnboardingFeature {
    let icon: String
    let text: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let localization: LocalizationManager
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.12))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(page.iconColor.opacity(0.08))
                    .frame(width: 180, height: 180)

                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(page.iconColor)
                    .symbolEffect(.bounce, value: isVisible)
            }
            .scaleEffect(isVisible ? 1 : 0.6)
            .opacity(isVisible ? 1 : 0)

            // Title
            Text(localization.localized(page.titleKey))
                .font(SignerTypography.title1)
                .multilineTextAlignment(.center)
                .foregroundColor(SignerColors.textPrimary)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)

            // Subtitle
            Text(localization.localized(page.subtitleKey))
                .font(SignerTypography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(SignerColors.textSecondary)
                .padding(.horizontal, 32)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)

            // Features
            VStack(spacing: 14) {
                ForEach(Array(page.features.enumerated()), id: \.offset) { index, feature in
                    HStack(spacing: 14) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(page.iconColor)
                            .frame(width: 36, height: 36)
                            .background(page.iconColor.opacity(0.1))
                            .clipShape(Circle())

                        Text(feature.text)
                            .font(SignerTypography.subheadline)
                            .foregroundColor(SignerColors.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .offset(x: isVisible ? 0 : -30)
                    .animation(.spring(response: 0.5).delay(Double(index) * 0.1 + 0.4), value: isVisible)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}
