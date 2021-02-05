//
//  UserNominations.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/27/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase




class UserVotes {
    
    var nominationUID: String
    var nomineeName: String
    var nomineeCategory: String
    var totalVotes: Int
    
    init(nomUID: String, nomineeName: String, nomineeCategory: String, totalVotes: Int) {
        self.nomineeName = nomineeName
        self.nominationUID = nomUID
        self.nomineeCategory = nomineeCategory
        self.totalVotes = totalVotes
    }
    init(dict: [String : Any]) {
        self.nomineeName = dict["nomineeName"] as? String ?? "none"
        self.nominationUID = dict["nomUID"] as? String ?? "none"
        self.nomineeCategory = dict["nomineeCategory"] as? String ?? "none"
        self.totalVotes = dict["total"] as? Int ?? 0
    }
    func toDictionary() -> [String : Any] {
        return [
            "nomUID": self.nominationUID,
            "nomineeName": self.nomineeName,
            "nomineeCategory": self.nomineeCategory,
            "total": self.totalVotes
        ]
    }
    
    
    
}
extension UserVotes: Equatable { }

func ==(lhs: UserVotes, rhs: UserVotes) -> Bool {
    return lhs.nominationUID == rhs.nominationUID
}

