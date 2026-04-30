import RevenueCat
import RevenueCatUI
import SwiftUI

@main
struct SignerApp: App {
    @State private var flowViewModel = AppFlowViewModel()
    @State private var localizationManager = LocalizationManager.shared
    @State private var storeKitManager = StoreKitManager.shared
    @State private var documentManager = DocumentManager.shared
    @State private var revenueCatManager = RevenueCatManager.shared

    init() {
        // Configure RevenueCat SDK at launch
        RevenueCatManager.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(flowViewModel)
                .environment(localizationManager)
                .environment(storeKitManager)
                .environment(documentManager)
                .environment(revenueCatManager)
                .preferredColorScheme(nil)
                .task {
                    // Fetch customer info and offerings on launch
                    await revenueCatManager.fetchCustomerInfo()
                    await revenueCatManager.fetchOfferings()
                }
        }
    }
}

struct RootView: View {
    @Environment(AppFlowViewModel.self) private var flowViewModel

    var body: some View {
        ZStack {
            switch flowViewModel.currentState {
            case .splash:
                SplashView()
                    .transition(.opacity)

            case .languageSelection:
                LanguageSelectionView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .onboarding:
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .paywall:
                SignerPaywallView(isFromOnboarding: true)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .home:
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: flowViewModel.currentState)
    }
}
