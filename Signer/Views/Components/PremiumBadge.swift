import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: 8))
            Text("PRO")
                .font(.system(size: 9, weight: .heavy))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            SignerColors.premiumGradient
        )
        .clipShape(Capsule())
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    let colors: [Color]

    init(colors: [Color] = [SignerColors.primary, SignerColors.secondary, Color(hex: "7C3AED")]) {
        self.colors = colors
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct CheckmarkCircle: View {
    let isChecked: Bool

    var body: some View {
        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 22))
            .foregroundColor(isChecked ? SignerColors.primary : SignerColors.neutral300)
    }
}

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.3)

                Text(message)
                    .font(SignerTypography.subheadline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.lg)
                    .fill(Color(hex: "1C1C1E"))
            )
        }
    }
}
