//
//  Keys.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation

// Used for the Keychain Storing Values 
enum Keys {
    
    case isAdminLogin
    case download_check
    case app_version(version: String)
    
    
    case google_creation
    case cluster_250
    case cluster_250_citys
    case current_user
    case profile_pic(url: String)
    case nom_pics(url: String)
    case uid
    
    case notification_id
    
    case phone_id(number: String)
    case google_signedin
    
    public var key: String {
        switch self {
        case .isAdminLogin:
            return "isAdminLogin"
        case .app_version(let version):
            return "V\(version)"
        case .download_check:
            return "Download"
        case .google_creation:
            return "GoogleCreation"
        case .cluster_250:
            return "cluster-250"
        case .cluster_250_citys:
            return "cluster-250-city"
        case .current_user:
            return "currentUser"
        case .profile_pic(let url):
            return "profilePic-\(url)"
        case .nom_pics(let url):
            return "nomPics-\(url)"
        case .uid:
            return "uid"
        case .phone_id(let number):
            return "phone-\(number)"
        case .google_signedin:
            return "google-signedin"
        case .notification_id:
            return "notif-id"
            
        }
    }
    
    
    
}
