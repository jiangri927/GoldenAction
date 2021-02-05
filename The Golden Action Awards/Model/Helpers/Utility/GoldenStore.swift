//
//  GoldenStore.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/22/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftyStoreKit

import StoreKit

enum GoldenStore {
    
    case nom_pack_one
    case nom_pack_ten
    case nom_pack_fifty
    case nom_pack_hundred
    
    case votes_pack_one
    case votes_pack_ten
    case votes_pack_fifty
    case votes_pack_hundred
    
    func reference() -> String {
        return "\(rootRef).\(purchasePath)"
    }
    var sharedSecretProduction: String {
       return "c2616e5d557d4c999532a15eac4823c3"
    }
    var sharedSecretDev: String {
        return "6a94b0619d03408ab70f4bb47188c34b"
    }
    private var rootRef: String {
        //return "com.stackonapp.The-Golden-Action-Awards-Beta"
        return "cyncarllc.The-Golden-Action-Awards"
    }
    private var purchasePath: String {
        switch self {
        case .nom_pack_one:
            return "NP1"
        case .nom_pack_ten:
            return "NP10"
        case .nom_pack_fifty:
            return "NP50"
        case .nom_pack_hundred:
            return "NP100"
        case .votes_pack_one:
            return "VP1"
        case .votes_pack_ten:
            return "VP10"
        case .votes_pack_fifty:
            return "VP50"
        case .votes_pack_hundred:
            return "VP100"
        }
    }
    
}
class NetworkActivity: NSObject {
    private static var loadingCount = 0
    
    class func operationsStarted() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    
    class func operationsEnded() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
class GoldenStoreKit {
    
    private static let instanceInner = GoldenStoreKit()
    
    static var instance: GoldenStoreKit {
        return instanceInner
    }
    
    var devicePurchases: Bool {
        if SwiftyStoreKit.canMakePayments {
            print("Makes purchases!!")
            return true
        } else {
            print("Can't make purchases!!")
            return false
        }
    }
//    var nominees: Set<String> = ["stackonapp.The-Golden-Action-Awards-Beta.NP1", "stackonapp.The-Golden-Action-Awards-Beta.NP10", "com.stackonapp.The-Golden-Action-Awards-Beta.NP50", "com.stackonapp.The-Golden-Action-Awards-Beta.NP100"]
//
//    var votes: Set<String> = ["com.stackonapp.The-Golden-Action-Awards-Beta.VP1", "com.stackonapp.The-Golden-Action-Awards-Beta.VP10", "com.stackonapp.The-Golden-Action-Awards-Beta.VP50", "com.stackonapp.The-Golden-Action-Awards-Beta.VP100"]
//
    
    var nominees: Set<String> = ["Nom-Pack-One","NP1"]
    
    var votes: Set<String> = ["VP1","VP5"]

    func makePurchase(productId: Set<String>) {
        guard self.devicePurchases else {
            print("Can't make purchases!!")
            return
        }
        
        SwiftyStoreKit.retrieveProductsInfo(productId) { (result) in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, completion: { (result) in
                    switch result {
                    case .success(let product):
                        // fetch content from your server, then:
                        
                        if product.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(product.transaction)
                        }
                        print("Purchase Success: \(product.productId)")
                    case .error(let error):
                        switch error.code {
                        case .unknown: print("Unknown error. Please contact support") // MARK: - Alert Here!!
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            default: break
                        }
                    }
                })
            }
        }
    }
    func retrievePrices(prods: Set<String>, completion: @escaping (Set<SKProduct>, Error?) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(["NP1"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
//        SwiftyStoreKit.retrieveProductsInfo(prods) { (result) in
//            guard result.error == nil else {
//                print(result.error?.localizedDescription)
//                completion([], result.error)
//                return
//            }
//            for resul in result.retrievedProducts {
//                print(resul.localizedPrice)
//                print(resul.localizedTitle)
//                print("Product: \(resul.localizedDescription), price: \(resul.localizedPrice)")
//            }
//            completion(result.retrievedProducts, nil)
//
//        }
    }
    
    
}

