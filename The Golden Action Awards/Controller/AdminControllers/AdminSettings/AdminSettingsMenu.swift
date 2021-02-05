//
//  AdminSettingsMenu.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/6/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
enum AdminSettingsMenu {
    case duties
    case feedback
    case contactOwners
    case privacyPolicy
    case backToMain
    case stopSponsor
    
    func routeSideMenu(vc: UIViewController, currentUser: Person) {
        switch self {
        case .duties:
            let workItem = DispatchWorkItem {
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
        case .feedback:
            let workItem = DispatchWorkItem {
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
        case .contactOwners:
            let workItem = DispatchWorkItem {
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
        case .privacyPolicy:
            let workItem = DispatchWorkItem {
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
        case .backToMain:
            let workItem = DispatchWorkItem {
                vc.performSegue(withIdentifier: SegueId.admin_settings_home.id, sender: vc)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
        case .stopSponsor:
            let workItem = DispatchWorkItem {
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
        }
    }
    
    private var id: Int {
        switch self {
        case .duties:
            return 0
        case .feedback:
            return 1
        case .contactOwners:
            return 2
        case .privacyPolicy:
            return 3
        case .backToMain:
            return 4
        case .stopSponsor:
            return 5
        }
    }
}
