//
//  UserSettingsMenu.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/6/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

//
//  AdminSettingsMenu.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/6/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
enum UserSettingsMenu {
    case rate
    case feedback
    case updates
    case votes
    case about
    case privacyPolicy
    case adminLogin
    case deleteAccount
    
    func routeSideMenu(vc: DispatchWorkItem) {
        switch self {
        case .rate:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .feedback:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .updates:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .votes:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .about:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .privacyPolicy:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .adminLogin:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        case .deleteAccount:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: vc)
        }
    }
    
    
    private var id: Int {
        switch self {
        case .rate:
            return 0
        case .feedback:
            return 1
        case .updates:
            return 2
        case .votes:
            return 3
        case .about:
            return 4
        case .privacyPolicy:
            return 5
        case .adminLogin:
            return 6
        case .deleteAccount:
            return 7
        }
    }
}

