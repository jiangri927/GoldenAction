//
//  Coupon.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/27/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import PDFKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class Coupon {
    
    var uid: String
    var dealDescription: String
    var isNomination: Bool
    var discount: Int
    var isUsed: Bool
    
    init(uid: String, dealDescription: String, isNomination: Bool, discount: Int, isUsed: Bool) {
        self.uid = uid
        self.dealDescription = dealDescription
        self.isNomination = isNomination
        self.discount = discount
        self.isUsed = isUsed
    }
    
    init(dict: [String : Any]) {
        self.uid = dict["uid"] as? String ?? "N/A"
        self.dealDescription = dict["dealDescription"] as? String ?? "N/A"
        self.isNomination = dict["isNomination"] as? Bool ?? false
        self.discount = dict["discount"] as? Int ?? 0
        self.isUsed = dict["isUsed"] as? Bool ?? true
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "uid": self.uid,
            "dealDescription": self.dealDescription,
            "isNomination": self.isNomination,
            "discount": self.discount,
            "isUsed": self.isUsed
            
        ]
    }
    
    
    
   class func loadCoupons(isVote: Bool, completion: @escaping ([Coupon]) -> Void) {
        let ref: DatabaseReference
        if isVote {
            ref = DBRef.votes_coupons.reference()
        } else {
            ref = DBRef.nomination_coupons.reference()
        }
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var coupons = [Coupon]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let cu = Coupon(dict: dict)
                        if !coupons.contains(cu) {
                            coupons.append(cu)
                        }
                    }
                }
                completion(coupons)
            } else {
                completion([])
            }
        }
    }
    
    
    
    
}
extension Coupon: Equatable { }

func ==(lhs: Coupon, rhs: Coupon) -> Bool {
    return lhs.uid == rhs.uid
}
