//
//  Receipts.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/25/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

class Reciepts {
    
    let uid: String
    var amount: Int
    var price: Double
    var userPhone: String
    var isNomination: Bool
    //var appleReciept:
    
    init(userUID: String, amount: Int, price: Double, userPhone: String, isNomination: Bool) {
        self.amount = amount
        self.price = price
        self.userPhone = userPhone
        self.isNomination = isNomination
        if isNomination {
            self.uid = DBRef.userNomReciepts(uid: userUID).reference().childByAutoId().key as? String ?? "N/A"
        } else {
            self.uid = DBRef.userVotesReciepts(uid: userUID).reference().childByAutoId().key as? String ?? "N/A"
        }
    }
    
    init(dict: [String : Any]) {
        self.price = dict["price"] as? Double ?? 0.0
        self.amount = dict["amount"] as? Int ?? 0
        self.userPhone = dict["phone"] as? String ?? "N/A"
        self.isNomination = dict["isNomination"] as? Bool ?? true
        self.uid = dict["uid"] as? String ?? "none"
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "price": self.price,
            "amount": self.amount,
            "phone": self.userPhone,
            "isNomination": self.isNomination,
            "uid": self.uid
        ]
    }
    
    
    
    func formatToPdf() {
        //let page: PDFPage = PDFPage.whitePage(CGSize(200,400))
        
    }
}
