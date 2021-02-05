//
//  Twicket.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/6/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//



import Foundation
import UIKit
import TwicketSegmentedControl

enum MessagingTitles {
    case incoming
    case outgoing
    
    var key: String {
        switch self {
        case .incoming:
            return "incoming"
        case .outgoing:
            return "outgoing"
        }
    }
}
enum NominationTypes {
    case heart
    case hand
    case health
    case head
    
    var key: String {
        switch self {
        case .head:
            return "HEAD"
        case .hand:
            return "HAND"
        case .health:
            return "HEALTH"
        case .heart:
            return "HEART"
        }
    }
}
enum CreateUserTypes {
    case existing
    case contacts
    case new
    
    var key: String {
        switch self {
        case .existing:
            return "Existing User"
        case .contacts:
            return "From Contacts"
        case .new:
            return "Input New User"
        }
    }
}
enum AdminDonation {
    case pending
    case finished
    
    var key: String {
        switch self {
        case .pending:
            return "Donation Pending"
        case .finished:
            return "Finished"
        }
    }
}
enum AdminNomination {
    case approval
    case active
    
    var key: String {
        switch self {
        case .approval:
            return "Approval Needed"
        case .active:
            return "Active"
        }
    }
}
enum AdminUsers {
    case all
    case banned
    
    var key: String {
        switch self {
        case .all:
            return "All Users"
        case .banned:
            return "Banned Users"
        }
    }
}
enum Twicket {
    case messaging(view: UIView)
    case create_noms(view: UIView)
    case create_users(view: UIView)
    //case adminTabs(view: UIView)
    
    func generate() -> TwicketSegmentedControl {
        let segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.setSegmentItems(titles)
        let segment = self.design(segment: segmentedControl)
        return segment
    }
    
    private func design(segment: TwicketSegmentedControl) -> TwicketSegmentedControl {
        segment.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        segment.defaultTextColor = UIColor.black
        segment.segmentsBackgroundColor = UIColor.black
        segment.sliderBackgroundColor = Colors.app_text.generateColor()
        return segment
        /*switch self {
         case .bookings(let view):
         return segment
         case .reports(let view):
         return segment
         } */
    }
    
    private var frame: CGRect {
        switch self {
        case .messaging(let view):
            return CGRect(x: 5, y: view.frame.height / 2 - 24, width: view.frame.width - 10, height: 40)
        case .create_noms(let view):
            return CGRect(x: 5, y: view.frame.height / 2 - 24, width: view.frame.width - 10, height: 40)
        case .create_users(let view):
            return CGRect(x: 5, y: view.frame.height / 2 - 24, width: view.frame.width - 10, height: 40)
        }
    }
    // MARK: - Type Enumerators for Twicket Located in AppSettings Model
    private var titles: [String] {
        switch self {
        case .messaging(_):
            return [MessagingTitles.incoming.key, MessagingTitles.outgoing.key]
        case .create_noms(_):
            return [NominationTypes.hand.key, NominationTypes.head.key, NominationTypes.health.key, NominationTypes.heart.key]
        case .create_users(_):
            return [CreateUserTypes.existing.key, CreateUserTypes.contacts.key, CreateUserTypes.new.key]
        }
    }
}


