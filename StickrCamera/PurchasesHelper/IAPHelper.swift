//
//  IAPHelper.swift
//  App Purchases
//
//  Created by Michael A on 2017-10-22.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import Foundation
import StoreKit

public class IAPHelper: NSObject {
    
    private override init() { }
    
    static let sharedInstance = IAPHelper()
    
    fileprivate var productRequest:SKProductsRequest!
    
    var products = [SKProduct]()
    
    fileprivate var productIdentifier = ""
    
    var removeAdsPurchaseMade = UserDefaults.standard.bool(forKey: "removeAdsPurchaseMade")
    
    var unlockPremiumPurchaseMade = UserDefaults.standard.bool(forKey: "unlockPremiumPurchaseMade")
    
    fileprivate let paymentQueue = SKPaymentQueue.default()
    
    func getIapProducts() {
        let productIdentifiers:Set = [IAPProducts.removeAdsProduct.rawValue, IAPProducts.unlockPremiumProduct.rawValue]
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
        paymentQueue.add(self)

    }
    
    private func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseProduct(product:IAPProducts) {
        
        if canMakePurchases() {
            let product = products.filter {
                return $0.productIdentifier == product.rawValue
                }.first
            guard let productToPurchase = product else {
                fatalError("Could not located product to purchase")
            }
            let payment = SKPayment(product:productToPurchase)
            paymentQueue.add(payment)
            productIdentifier = productToPurchase.productIdentifier
        }
    }
    func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

extension IAPHelper:SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if (queue.transactions.count == 0) {
            print("No ads to restore")
            NotificationCenter.default.post(name: NSNotification.Name.init("HandleFailedRestorePurchasesNotification"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name.init("CompletedRestorePurchasesNotification"), object: nil)

            for t in queue.transactions {
                guard let originalProductId = t.original?.payment.productIdentifier else {
                    print("could not retreive orignal product")
                    return
                }

                if originalProductId == IAPProducts.unlockPremiumProduct.rawValue {
                    print("should only restore preimium account")
                    unlockPremiumPurchaseMade = true
                    UserDefaults.standard.set(unlockPremiumPurchaseMade, forKey: "unlockPremiumPurchaseMade")
                    UserDefaults.standard.synchronize()
                   
                }

                if originalProductId == IAPProducts.removeAdsProduct.rawValue {
                    print("should only restore ads")
                    removeAdsPurchaseMade = true
                    UserDefaults.standard.set(removeAdsPurchaseMade, forKey: "removeAdsPurchaseMade")
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(name: NSNotification.Name.init("RemoveAdsPurchaseMade"), object: nil)
                }
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased: print("purchasing...")
            SKPaymentQueue.default().finishTransaction(transaction)
            if productIdentifier == IAPProducts.removeAdsProduct.rawValue {
                removeAdsPurchaseMade = true
                UserDefaults.standard.set(removeAdsPurchaseMade, forKey: "removeAdsPurchaseMade")
                UserDefaults.standard.synchronize()
                print("ads unlocked")
                NotificationCenter.default.post(name: NSNotification.Name.init("RemoveAdsPurchaseMade"), object: nil)
            } else if productIdentifier ==
                IAPProducts.unlockPremiumProduct.rawValue {
                unlockPremiumPurchaseMade = true
                UserDefaults.standard.set(unlockPremiumPurchaseMade, forKey: "unlockPremiumPurchaseMade")
                removeAdsPurchaseMade = true
                UserDefaults.standard.set(removeAdsPurchaseMade, forKey: "removeAdsPurchaseMade")
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: NSNotification.Name.init("UnlockPremiumPurchaseMade"), object: nil)
            }
                break
            case .purchasing:
                print("purchasing...")
                break
            case .deferred:
                print("deferred...")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored: print("the purchases have been restored")
            SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed: print("failed...")
            SKPaymentQueue.default().finishTransaction(transaction)
                break
            }
        }
    }
}

