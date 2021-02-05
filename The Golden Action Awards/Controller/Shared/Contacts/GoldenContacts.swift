//
//  GoldenContacts.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/6/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftyContacts
import SwiftEventBus
enum ContactBus {
    case bg
    case main
    case error
    
    var key: String {
        switch self {
        case .bg:
            return "backgroundContacts"
        case .main:
            return "mainContacts"
        case .error:
            return "errorContacts"
        }
    }
}
class GoldenContact {
    
    private static let instanceInner = GoldenContact()
    
    static var instance: GoldenContact {
        return instanceInner
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        requestAccess { (response) in
            completion(response)
        }
    }
    func currentStatus(completion: @escaping (String) -> Void) {
        authorizationStatus { (status) in
            switch status {
            case .authorized:
                completion("Authorized")
                break
            case .denied:
                completion("Denied")
                break
            case .restricted:
                completion("Restricted")
                break
            case .notDetermined:
                completion("n/a")
                break
            }
        }
    }
    
    func getContacts() {
        SwiftEventBus.onBackgroundThread(self, name: ContactBus.bg.key) { (notification) in
            fetchContacts(completionHandler: { (result) in
                switch result {
                case .Success(let contacts):
                    SwiftEventBus.postToMainThread(ContactBus.main.key, sender: contacts)
                    break
                case .Error(let error):
                    SwiftEventBus.post(ContactBus.error.key, sender: error)
                    break
                }
            })
        }
    }
    
}
