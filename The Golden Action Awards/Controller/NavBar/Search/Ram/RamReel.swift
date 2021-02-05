//
//  RamReel.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/6/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

/*import Foundation
import UIKit
import RAMReel
import SwiftEventBus
import SwiftyContacts
import Contacts
import ContactsUI

enum RamReel {
    case contacts //  0
    //case cities // 1
    //case charities // 2
    //case users // 3
    //case nominations// 4
    //case awards // 5
    //case admin_users //6
    //case admin_donations // 7
    //case admin_nominations //8
    //case owner_manage// 9
    
    func generateRam(bounds: CGRect) -> RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>! {
        var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
        
    }
    var placeholder: String {
        switch self {
        case .contacts:
            return "Enter your contacts name or phone..."
        }
    }
    var data: FlowDataSource {
        switch self {
        case .contacts:
            GoldenContact.instance.getContacts()
            SwiftEventBus.onMainThread(GoldenContact, name: ContactBus.main.key) { (result) in
                let cns: [CNContact] = result?.object as? [CNContact] ?? []
                data = cns
                print(cns)
                return data
            }
        
        }
    }
        
    var theme: RAMTheme {
        switch self {
        case .contacts:
            let textColor: UIColor = Colors.app_color.generateColor()
            let listBackgroundColor: UIColor = Colors.app_tabbar_unselected.generateColor()
            let font: UIFont = Fonts.hira_pro_three.generateFont(size: 16.0)
            
            let theme = RAMTheme(textColor: textColor, listBackgroundColor: listBackgroundColor, font: font)
        }
    }
}
public struct ComplexQueryDataSource: FlowDataSource {
    public typealias ResultType = QueryType
    
    public init(_ data: )
} */

