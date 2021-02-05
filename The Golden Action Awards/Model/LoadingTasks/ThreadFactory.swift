//
//  ThreadFactory.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//


import Foundation
import SwiftKeychainWrapper

enum DispatchLabel {
    case normal
    
    var key: String {
        switch self {
        case .normal:
            return "default"
        }
    }
}
enum ThreadFactory {
    case normal
    case data_bg // Listening for Notifications through Realm to update the UI
    case ui_bg // The transfer of Notifications from data_bg to update the UI
    case data_utility
    case ui_utility
    case data_normal
    case ui_normal
    case data_userInit
    case ui_userInit
    case data_userInteract
    case ui_userInteract
    
    
    func generate(priority: Int) -> DispatchFactory {
        switch self {
        case .normal:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .default, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .main)
        case .data_bg:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .background, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .global())
        case .ui_bg:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .background, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .main)
        case .data_utility:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .utility, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .global())
        case .ui_utility:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .utility, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .main)
        case .data_normal:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .default, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .global())
        case .ui_normal:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .default, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .main)
        case .data_userInit:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .userInitiated, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .global())
        case .ui_userInit:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .userInitiated, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .main)
        case .data_userInteract:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .userInteractive, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .global())
        case .ui_userInteract:
            return DispatchFactory(label: self.generateLabel(priority: priority), qosClass: .userInteractive, priority: priority, attributes: .concurrent, autorelease: .workItem, target: .main)
            
        }
    }
    
    private func generateLabel(priority: Int) -> String {
        switch self {
        case .normal:
            return "default"
        case .data_bg:
            return "dataBg\(priority)"
        case .data_utility:
            return "dataUtility\(priority)"
        case .ui_bg:
            return "uiBg\(priority)"
        case .ui_utility:
            return "uiUtility\(priority)"
        case .data_normal:
            return "dataNormal\(priority)"
        case .ui_normal:
            return "uiNormal\(priority)"
        case .data_userInit:
            return "dataUserInit\(priority)"
        case .ui_userInit:
            return "uiUserInit\(priority)"
        case .data_userInteract:
            return "dataUserInteract\(priority)"
        case .ui_userInteract:
            return "uiUserInteract\(priority)"
        }
    }
    
}

class DispatchFactory: NSObject, NSCoding {
    var label: String
    var priority: Int // --> -15 to 0 --> 0 Being Highest!
    /*var qos: DispatchQoS.QoSClass
     var attributes: DispatchQueue.Attributes
     var autorelease: DispatchQueue.AutoreleaseFrequency
     var target: DispatchQueue*/
    var que: DispatchQueue
    var group = DispatchGroup()
    
    init(label: String, qosClass: DispatchQoS.QoSClass, priority: Int, attributes: DispatchQueue.Attributes, autorelease: DispatchQueue.AutoreleaseFrequency, target: DispatchQueue) {
        self.label = label
        self.priority = priority
        self.que = DispatchQueue(label: label, qos: DispatchQoS.init(qosClass: qosClass, relativePriority: priority), attributes: attributes, autoreleaseFrequency: autorelease, target: target)
    }
    init(label: String, que: DispatchQueue, group: DispatchGroup, prior: Int) {
        self.label = label
        self.que = que
        self.group = group
        self.priority = prior
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let lab = aDecoder.decodeObject(forKey: "label") as? String ?? DispatchLabel.normal.key
        let priority = aDecoder.decodeInteger(forKey: "prior") ?? 0
        let q = aDecoder.decodeObject(forKey: "\(lab)que") as? DispatchQueue ?? DispatchQueue(label: lab)
        let g = aDecoder.decodeObject(forKey: "\(lab)group") as? DispatchGroup ?? DispatchGroup()
        self.init(label: lab, que: q, group: g, prior: priority)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.label, forKey: "label")
        aCoder.encode(self.que, forKey: "\(self.label)que")
        aCoder.encode(self.group, forKey: "\(self.label)group")
        aCoder.encode(self.priority, forKey: "prior")
    }
}





