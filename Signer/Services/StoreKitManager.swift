import Foundation
import RevenueCat
import StoreKit
import SwiftUI

/// StoreKitManager now delegates all purchase logic to RevenueCatManager.
/// This file remains for backward compatibility with views that reference it.
@Observable
@MainActor
final class StoreKitManager {
    static let shared = StoreKitManager()

    private var revenueCat: RevenueCatManager { RevenueCatManager.shared }

    var isLoading: Bool { revenueCat.isLoading }
    var errorMessage: String? { revenueCat.errorMessage }

    var isPremium: Bool { revenueCat.isPremium }

    var yearlyPricePerMonth: String { revenueCat.yearlyPricePerMonth }

    var yearlyProduct: Package? { revenueCat.yearlyPackage }
    var lifetimeProduct: Package? { revenueCat.lifetimePackage }

    private init() {}

    func loadProducts() async {
        await revenueCat.fetchOfferings()
    }

    func restorePurchases() async {
        _ = await revenueCat.restorePurchases()
    }

    func showManageSubscription() async {
        await revenueCat.showManageSubscriptions()
    }
}
