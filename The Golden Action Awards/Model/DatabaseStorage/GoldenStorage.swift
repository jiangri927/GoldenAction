//
//  GoldenStorage.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

enum GoldenStorage {
    case clusters_temp
    case profile_pics
    case nomination_pics
    
    
    func reference() -> StorageReference {
        return baseRef.child(path)
    }
    
    private var baseRef: StorageReference {
        return Storage.storage().reference()
    }
    
    private var path: String {
        switch self {
        case .clusters_temp:
            return ""
        case .profile_pics:
            return "profilePics"
        case .nomination_pics:
            return "nominationPics"
            
        }
    }
}
