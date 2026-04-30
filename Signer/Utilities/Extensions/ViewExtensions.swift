import SwiftUI

// MARK: - View Extensions
extension View {
    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonModifier())
    }

    func secondaryButtonStyle() -> some View {
        self.modifier(SecondaryButtonModifier())
    }

    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }

    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }

    func fadeSlideIn(delay: Double = 0) -> some View {
        self.modifier(FadeSlideInModifier(delay: delay))
    }
}

// MARK: - Button Modifiers
struct PrimaryButtonModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(SignerTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(SignerColors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: SignerRadius.lg))
            .shadow(color: SignerColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct SecondaryButtonModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(SignerTypography.headline)
            .foregroundColor(SignerColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.lg)
                    .stroke(SignerColors.primary, lineWidth: 2)
            )
    }
}

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(SignerSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.lg)
                    .fill(colorScheme == .dark
                          ? Color(hex: "1C1C1E")
                          : Color.white)
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: -geo.size.width * 0.3 + phase * (geo.size.width * 1.6))
                        .mask(content)
                    }
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Fade Slide In Animation
struct FadeSlideInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Haptic Feedback
enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
