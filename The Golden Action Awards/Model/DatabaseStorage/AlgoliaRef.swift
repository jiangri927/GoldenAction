//
//  AlgoliaRef.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/30/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
//import AlgoliaSearch


enum AlgoliaRef {
    
    case cities
    case charities
    
    case nominations
    case awards
    
    
    case users
    case banned_users
    
    case admin
    case admin_awards
    case admin_nominations
    
//    func reference() -> Index {
//        return rootClient.index(withName: indice)
//    }
//    private var rootClient: Client {
//        //return Client(appID: "0L3X8OR2A4", apiKey: "76b50d5f3ca14ae116a6eb298f08bbc1")
//        //return Client(appID: "0X1E31NHC3", apiKey: "d779f480e6ec1dc7e0d80059f42ceb2b")
//        return Client(appID: "9ABFPLXP4E", apiKey: "da54313ace5daa89d8f907d0b88fb31c")
//    }
    
    private var indice: String {
        switch self {
        case .cities:
            return "City Clusters"
        case .charities:
            return "Charities"
        case .nominations:
            return "Nominations"
        case .awards:
            return "Awards"
        case .users:
            return "Users"
        case .banned_users:
            return "banned_users"
        case .admin:
            return "Admins"
        case .admin_awards:
            return "admin_pending_awards"
        case .admin_nominations:
            return "admin_nominations"
        }
        
        
    }
    
    
}

