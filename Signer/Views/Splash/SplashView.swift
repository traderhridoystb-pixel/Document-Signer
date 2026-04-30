import SwiftUI

struct SplashView: View {
    @Environment(AppFlowViewModel.self) private var flowViewModel
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    SignerColors.primary,
                    SignerColors.secondary,
                    Color(hex: "1E1B4B")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated background circles
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)
                .scaleEffect(ringScale)

            Circle()
                .fill(Color.white.opacity(0.03))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)
                .scaleEffect(ringScale)

            VStack(spacing: 24) {
                Spacer()

                // Logo Container
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Logo background
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "F0F4FF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)

                    // Logo icon
                    ZStack {
                        // Pen/signature icon
                        Image(systemName: "signature")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(SignerColors.primaryGradient)

                        // Small checkmark badge
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SignerColors.accent)
                            .offset(x: 30, y: -30)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App Name
                VStack(spacing: 8) {
                    Text("Signer")
                        .font(SignerTypography.displayLarge)
                        .foregroundColor(.white)
                        .fontWeight(.heavy)

                    Text("Document Signer")
                        .font(SignerTypography.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(4)
                        .textCase(.uppercase)
                }
                .opacity(textOpacity)

                Spacer()

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.6)))
                    .scaleEffect(1.2)
                    .opacity(textOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Ring animation
        withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        // Text fade in
        withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
            textOpacity = 1.0
        }

        // Navigate after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            flowViewModel.completeSplash()
        }
    }
}
