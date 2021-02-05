//
//  NotificationHelper.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/25/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import FirebaseAuth

// MARK: - Helper class to store uuid for messaging
class NotificationHelper {
    private static let instanceInner = NotificationHelper()
    
    static var instance: NotificationHelper {
        return instanceInner
    }
    
    var currentUUID: String?
    
    func checkRememberedUID(uuid: String?, completion: @escaping (Bool) -> Void) {
        if uuid != nil {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func saveForLoggedUser(){
        guard Auth.auth().currentUser != nil else{
            print("User must login.")
            return
        }
        
        let uid = Auth.auth().currentUser?.uid
        loadPerson(uid: uid ?? "N/A", complition:{(status) in
            print("users uuid is updated.")
        })
    }
    
    func loadPerson(uid:String, complition: @escaping (Bool) -> Void){
        let dbRef = DBRef.user(uid: uid).reference().child("uuid")
        dbRef.setValue([currentUUID])
        complition(true)
    }
    
}
