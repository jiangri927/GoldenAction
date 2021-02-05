//
//  FireRef.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/1/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase


enum FireRef {
    // Users
    // Sponsor
    case spec_nomination(uid: String)
    // Not Accepted
    case admin_nominations(uid: String) // UserNomination
    func reference() -> DocumentReference {
        switch self {
        case .spec_nomination(let uid):
            return Firestore.firestore().collection("nominations").document(uid)
        case .admin_nominations(let uid):
            return Firestore.firestore().collection("adminNominations").document(uid)
        }
    }
}
enum CollectionFireRef {
    // Users
    // Sponsor
    case nominations
    // Not Accepted // UserNomination
    case admin_nomination
    case charity
    case nominationPeriod
    
    func reference() -> CollectionReference {
        switch self {
        case .nominations:
            return Firestore.firestore().collection("nominations")
        case .admin_nomination:
            return Firestore.firestore().collection("adminNominations")
        case .charity:
            return Firestore.firestore().collection("charity")
            
        case .nominationPeriod:
            return Firestore.firestore().collection("nominationPeriod")

        }
    }
    
}
