import Foundation
import StoreKit
import SwiftUI

@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()

    var yearlyProduct: Product?
    var lifetimeProduct: Product?
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty || UserDefaults.standard.bool(forKey: AppConstants.isPremiumUser)
    }

    var yearlyPricePerMonth: String {
        guard let product = yearlyProduct else { return "" }
        let monthlyPrice = product.price / 12
        return monthlyPrice.formatted(.currency(code: product.priceFormatStyle.currencyCode ?? "USD"))
    }

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateCurrentEntitlements()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let products = try await Product.products(for: [
                AppConstants.yearlySubscriptionID,
                AppConstants.lifetimeSubscriptionID
            ])

            for product in products {
                switch product.id {
                case AppConstants.yearlySubscriptionID:
                    yearlyProduct = product
                case AppConstants.lifetimeSubscriptionID:
                    lifetimeProduct = product
                default:
                    break
                }
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Purchase
    @MainActor
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCurrentEntitlements()
            await transaction.finish()
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases
    @MainActor
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        try? await AppStore.sync()
        await updateCurrentEntitlements()
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCurrentEntitlements()
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }

    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Update Entitlements
    @MainActor
    func updateCurrentEntitlements() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                // Skip unverified transactions
            }
        }

        purchasedProductIDs = purchased
        UserDefaults.standard.set(!purchased.isEmpty, forKey: AppConstants.isPremiumUser)
    }

    // MARK: - Manage Subscription
    func showManageSubscription() async {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        try? await AppStore.showManageSubscriptions(in: windowScene)
    }
}

// MARK: - Store Errors
enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        }
    }
}
