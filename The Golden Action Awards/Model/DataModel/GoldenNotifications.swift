//
//  GoldenNotifications.swift
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

enum NotificationType {
    case phase_one
    case phase_two
    case phase_three
    case phase_four
    case phase_five
    case phase_six
    
    var typ: Int {
        switch self {
        case .phase_one:
            return 1
        case .phase_two:
            return 2
        case .phase_three:
            return 3
        case .phase_four:
            return 4
        case .phase_five:
            return 5
        case .phase_six:
            return 6
        }
    }
    
}

class GoldenNotifications {
    let uid: String
    
    var notificationType: Int
    
    var nominationUID: String
    
    var targetPhone: String
    var targetName: String
    var targetUID: String
    var targetVerification: String?
    
    var senderURL: String
    var senderUID: String
    var senderName: String
    var senderPhone: String
    
    var startTime: Double
    var endDate: Double
    var hasAccount: Bool
    
    var region: String
    
    var notifText: String
    var notifTitle: String
    
    init(notificationType: Int, nominationUID: String, targetPhone: String, targetName: String, targetUID: String, senderURL: String, senderUID: String, senderName: String, senderPhone: String, startTime: Double, endDate: Double, hasAccount: Bool, region: String, notifText: String, notifTitle: String) {
        self.notificationType = notificationType
        self.nominationUID = nominationUID
        
        self.targetPhone = targetPhone
        self.targetName = targetName
        self.targetUID = targetUID
        
        self.senderUID = senderUID
        self.senderName = senderName
        self.senderURL = senderURL
        self.senderPhone = senderPhone
        
        self.startTime = startTime
        self.endDate = endDate
        self.hasAccount = hasAccount
        self.region = region
        self.notifText = notifText
        self.notifTitle = notifTitle
        self.uid = DBRef.notifications(phone: targetPhone).reference().childByAutoId().key as? String ?? "N/A"
    }
    init(dict: [String : Any]) {
        self.uid = dict["uid"] as? String ?? "N/A"
        self.notificationType = dict["type"] as? Int ?? 0
        self.nominationUID = dict["nominationUID"] as? String ?? "N/A"
        
        self.targetName = dict["targetName"] as? String ?? "N/A"
        self.targetPhone = dict["targetPhone"] as? String ?? "N/A"
        self.targetUID = dict["targetUID"] as? String ?? "N/A"
        
        self.startTime = dict["startTime"] as? Double ?? 0
        self.hasAccount = dict["hasAccount"] as? Bool ?? false
        self.endDate = dict["endDate"] as? Double ?? 0
        
        self.senderUID = dict["senderUID"] as? String ?? "N/A"
        self.senderURL = dict["senderURL"] as? String ?? "N/A"
        self.senderPhone = dict["senderPhone"] as? String ?? "N/A"
        self.senderName = dict["senderName"] as? String ?? "N/A"
        
        self.region = dict["region"] as? String ?? "000"
        self.notifText = dict["notifText"] as? String ?? "N/A"
        self.notifTitle = dict["notifTitle"] as? String ?? "N/A"
    }
    func toDictionary() -> [String : Any] {
        return [
            "uid": self.uid,
            "type": self.notificationType,
            "nominationUID": self.nominationUID,
            "targetName": self.targetName,
            "targetPhone": self.targetPhone,
            "targetUID": self.targetUID,
            "senderUID": self.senderUID,
            "senderURL": self.senderURL,
            "senderPhone": self.senderPhone,
            "senderName": self.senderName,
            "startTime": self.startTime,
            "endDate": self.endDate,
            "hasAccount": self.hasAccount,
            "region": self.region,
            "notifText": self.notifText,
            "notifTitle": self.notifTitle
        ]
    }
    class func fetchNotifications(user: Person, completion: @escaping ([GoldenNotifications]) -> Void) {
        DBRef.notifications(phone: user.phone).reference().observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var notifs = [GoldenNotifications]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let notif = GoldenNotifications(dict: dict)
                        if !notifs.contains(notif) {
                            notifs.append(notif)
                        }
                    }
                }
                completion(notifs)
            }
        }
    }
    class func fetchTargetVerification(phone: String, completion: @escaping (String?) -> Void) {
        DBRef.verification_notif(phone: phone).reference().observeSingleEvent(of: .value) { (snapshot) in
            if let verif = snapshot.value as? String {
                completion(verif)
            } else {
                completion(nil)
            }
        }
    }
}
extension GoldenNotifications: Equatable { }

func ==(lhs: GoldenNotifications, rhs: GoldenNotifications) -> Bool {
    return lhs.uid == rhs.uid
}
extension GoldenNotifications: Comparable {
    static func <(lhs: GoldenNotifications, rhs: GoldenNotifications) -> Bool {
        return (lhs.startTime) > (rhs.startTime)
    }
}
