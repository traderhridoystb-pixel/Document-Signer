import Foundation
import SwiftUI

enum AppFlowState {
    case splash
    case languageSelection
    case onboarding
    case paywall
    case home
}

@Observable
final class AppFlowViewModel {
    var currentState: AppFlowState = .splash
    var hasCompletedOnboarding: Bool
    var hasSeenLanguageSelection: Bool

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppConstants.hasCompletedOnboarding)
        self.hasSeenLanguageSelection = UserDefaults.standard.bool(forKey: AppConstants.hasSeenLanguageSelection)
    }

    func completeSplash() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if !hasSeenLanguageSelection {
                currentState = .languageSelection
            } else if !hasCompletedOnboarding {
                currentState = .onboarding
            } else {
                currentState = .home
            }
        }
    }

    func completeLanguageSelection() {
        hasSeenLanguageSelection = true
        UserDefaults.standard.set(true, forKey: AppConstants.hasSeenLanguageSelection)
        withAnimation(.easeInOut(duration: 0.5)) {
            currentState = .onboarding
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: AppConstants.hasCompletedOnboarding)
        withAnimation(.easeInOut(duration: 0.5)) {
            currentState = .paywall
        }
    }

    func completePaywall() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentState = .home
        }
    }

    func showPaywall() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentState = .paywall
        }
    }

    func dismissPaywall() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentState = .home
        }
    }
}
