import Foundation
import RevenueCat
import SwiftUI

// MARK: - RevenueCat Configuration
enum RevenueCatConfig {
    /// RevenueCat public API key
    static let apiKey = "test_OYvCMyHpZVqfoXPTZmkQjgUEmLi"

    /// Entitlement identifier configured in RevenueCat dashboard
    static let entitlementID = "Signer Pro"

    /// Product identifiers
    static let yearlyProductID = "yearly"
    static let lifetimeProductID = "lifetime"
}

// MARK: - RevenueCat Manager
@Observable
@MainActor
final class RevenueCatManager {
    static let shared = RevenueCatManager()

    // MARK: - Published State
    var customerInfo: CustomerInfo?
    var currentOffering: Offering?
    var isLoading = false
    var errorMessage: String?

    /// Whether the user has an active "Signer Pro" entitlement
    var isPremium: Bool {
        customerInfo?.entitlements[RevenueCatConfig.entitlementID]?.isActive == true
    }

    /// The active entitlement, if any
    var activeEntitlement: EntitlementInfo? {
        customerInfo?.entitlements[RevenueCatConfig.entitlementID]
    }

    /// Yearly package from the current offering
    var yearlyPackage: Package? {
        currentOffering?.annual
    }

    /// Lifetime package from the current offering
    var lifetimePackage: Package? {
        currentOffering?.lifetime
    }

    /// All available packages
    var availablePackages: [Package] {
        currentOffering?.availablePackages ?? []
    }

    /// Yearly price formatted per month
    var yearlyPricePerMonth: String {
        guard let pkg = yearlyPackage else { return "" }
        let monthlyPrice = pkg.storeProduct.price / 12
        return monthlyPrice.formatted(.currency(code: pkg.storeProduct.currencyCode ?? "USD"))
    }

    /// User's app user ID in RevenueCat
    var appUserID: String {
        Purchases.shared.appUserID
    }

    /// Whether the user is anonymous
    var isAnonymous: Bool {
        Purchases.shared.isAnonymous
    }

    private init() {}

    // MARK: - SDK Configuration
    /// Call this once at app launch (e.g. in App.init or AppDelegate)
    static func configure() {
        Purchases.logLevel = .debug

        Purchases.configure(
            with: .builder(withAPIKey: RevenueCatConfig.apiKey)
                .with(usesStoreKit2IfAvailable: true)
                .build()
        )

        // Set up the delegate for real-time customer info updates
        Purchases.shared.delegate = RevenueCatDelegateHandler.shared
    }

    // MARK: - Fetch Customer Info
    func fetchCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            self.customerInfo = info
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to fetch customer info: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Offerings
    func fetchOfferings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            self.currentOffering = offerings.current
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to fetch offerings: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase a Package
    func purchase(package: Package) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if !result.userCancelled {
                self.customerInfo = result.customerInfo

                if isPremium {
                    HapticManager.notification(.success)
                    return true
                }
            }
            return false
        } catch let error as RevenueCat.ErrorCode {
            handlePurchaseError(error)
            return false
        } catch {
            self.errorMessage = "Purchase failed: \(error.localizedDescription)"
            HapticManager.notification(.error)
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.restorePurchases()
            self.customerInfo = info
            self.errorMessage = nil

            if isPremium {
                HapticManager.notification(.success)
                return true
            } else {
                self.errorMessage = "No previous purchases found."
                return false
            }
        } catch {
            self.errorMessage = "Restore failed: \(error.localizedDescription)"
            HapticManager.notification(.error)
            return false
        }
    }

    // MARK: - User Identity
    func logIn(appUserID: String) async {
        do {
            let (info, _) = try await Purchases.shared.logIn(appUserID)
            self.customerInfo = info
        } catch {
            self.errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }

    func logOut() async {
        do {
            let info = try await Purchases.shared.logOut()
            self.customerInfo = info
        } catch {
            self.errorMessage = "Logout failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Subscription Management
    func showManageSubscriptions() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        try? await AppStore.showManageSubscriptions(in: windowScene)
    }

    // MARK: - Error Handling
    private func handlePurchaseError(_ error: RevenueCat.ErrorCode) {
        switch error {
        case .purchaseCancelledError:
            // User cancelled, no error message needed
            break
        case .purchaseNotAllowedError:
            self.errorMessage = "Purchases are not allowed on this device."
        case .purchaseInvalidError:
            self.errorMessage = "The purchase was invalid. Please try again."
        case .productNotAvailableForPurchaseError:
            self.errorMessage = "This product is not available for purchase."
        case .productAlreadyPurchasedError:
            self.errorMessage = "You've already purchased this product."
        case .networkError:
            self.errorMessage = "Network error. Please check your connection."
        case .receiptAlreadyInUseError:
            self.errorMessage = "This receipt is already in use by another account."
        case .storeProblemError:
            self.errorMessage = "There was a problem with the App Store. Please try again later."
        default:
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }

        if error != .purchaseCancelledError {
            HapticManager.notification(.error)
        }
    }

    // MARK: - Convenience Helpers
    func checkEntitlement() async -> Bool {
        await fetchCustomerInfo()
        return isPremium
    }

    /// Check if the user has reached the free tier limit
    var shouldShowPaywall: Bool {
        !isPremium
    }
}

// MARK: - RevenueCat Delegate
final class RevenueCatDelegateHandler: NSObject, PurchasesDelegate, Sendable {
    static let shared = RevenueCatDelegateHandler()

    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            RevenueCatManager.shared.customerInfo = customerInfo
        }
    }
}
