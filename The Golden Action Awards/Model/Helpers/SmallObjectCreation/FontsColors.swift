//
//  Strings.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit

// Used For Strings
enum Strings {
    
    case buttons
    case description_text
    
    case titleview_title
    case titleview_category
    case titleview_location
    
    case cell_nominee_name
    case cell_nominee_location
    case cell_nominee_nominatedBy
    case cell_nominee_votesLabel
    case cell_nominee_numberVotes
    
    case cell_settings_title
    case cell_settings_description
    
    case cell_notification_description
    
    case cell_cart_price
    case cell_cart_bundle
    case cell_cart_numvotes
    
    case popup_nominated_placeholder
    func generateString(text: String) -> NSMutableAttributedString {
        switch self {
        case .buttons:
            // Hiragino-Micho-Pro-W3
            let font = UIFont(name: "Avenir Next", size: 17.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : font])
            
       case .description_text:
            // MARK: - Change here to alter font for all labels
            // Hiragino-Micho-Pro-W3
            let font = UIFont(name: "Avenir Next", size: 20.0)!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : font, NSAttributedStringKey.paragraphStyle : paragraphStyle, ])
        case .titleview_title:
            let font = UIFont(name: "Avenir Next", size: 20.0)!
            
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        case .titleview_category:
            let font = UIFont(name: "Avenir Next", size: 12.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : font])
            
        case .titleview_location:
            let font = UIFont(name: "Avenir Next", size: 14.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font : font])
        
        case .cell_nominee_name:
            let font = UIFont(name: "Avenir Next", size: 21.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        case .cell_nominee_location:
            let font = UIFont(name: "Avenir Next", size: 21.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        case .cell_nominee_nominatedBy:
            let font = UIFont(name: "Avenir Next", size: 21.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        case .cell_nominee_votesLabel:
            let font = UIFont(name: "Avenir Next", size: 21.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        case .cell_nominee_numberVotes:
            let font = UIFont(name: "Avenir Next", size: 21.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
            
        case .cell_settings_title:
            let font = UIFont(name: "Avenir Next", size: 18.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
            
        case .cell_settings_description:
            let font = UIFont(name: "Avenir Next", size: 13.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
            
        case .cell_notification_description:
            let font = UIFont(name: "Avenir Next", size: 15.0)!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font, NSAttributedStringKey.paragraphStyle : paragraphStyle])
            
        case .cell_cart_numvotes:
            let font = UIFont(name: "Avenir Next", size: 13.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
            
        case .cell_cart_price:
            let font = UIFont(name: "Avenir Next", size: 22.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
            
        case .cell_cart_bundle:
            let font = UIFont(name: "Avenir Next", size: 16.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        case .popup_nominated_placeholder:
            let font = UIFont(name: "Avenir Next", size: 14.0)!
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : font])
        }
        
    }
}
enum Fonts {
    case hira_pro_six
    case hira_pro_three
    
    func generateFont(size: CGFloat) -> UIFont {
        switch self {
        case .hira_pro_six:
            return UIFont(name: "Avenir Next", size: size)!
        case .hira_pro_three:
            return UIFont(name: "Avenir Next", size: size)!
        }
    }
}
// Used for Colors 
enum Colors {
    
    case black
    case white
    case app_color
    
    case reusable_view
    
    case app_tabbar_tint
    case app_navbar_tint
    
    case app_tabbar_unselected
    
    case app_text
    
    case app_tableview_seperator
    case app_tableview_background
    
    
    case app_maincell_background
    
    case settings_title
    
    case tutorialone_background
    
    
    case nom_detail_firstBackground
    case nom_detail_outerBackground
    case nom_detail_innerBackground
    case nom_detail_innerBorder
    
    case filter_unselected_button_background
    case filter_unselected_text
    case filter_selected_button_background
    case filter_selected_text
    
    case popup_background
    case popup_recognized_background
    case popup_recognized_text
    case popup_unanimous_background
    case popup_unanimous_text
    
    func generateColor() -> UIColor {
        switch self {
        case .black:
            return UIColor.black
        case .white:
            return UIColor.white
            
        case .app_tabbar_unselected:
           // return UIColor(red: 116/255, green: 105/255, blue: 51/255, alpha: 1.0)
            return UIColor.clear
        case .reusable_view:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.35)
        case .settings_title:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        case .app_tabbar_tint:
            return UIColor(red: 255/255, green: 224/255, blue: 101/255, alpha: 1.0)
            
            
        case .app_navbar_tint:
            return UIColor(red: 255/255, green: 224/255, blue: 101/255, alpha: 1.0)
        
        // Used extremely widely
        case .app_text:
            //return UIColor(red: 157/255, green: 134/255, blue: 56/255, alpha: 1.0)
            let background = #colorLiteral(red: 0.968627451, green: 0.7529411765, blue: 0.3450980392, alpha: 1)
            return background
        case .app_color:
            return UIColor(red: 62/255, green: 56/255, blue: 63/255, alpha: 1.0)
            
        case .app_tableview_seperator:
            return UIColor(red: 62/255, green: 56/255, blue: 63/255, alpha: 1.0)
            
        case .app_tableview_background:
            return UIColor.black
            
        case .app_maincell_background:
            return UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
            
        case .tutorialone_background:
            return UIColor.clear
        
        case .popup_background:
            return UIColor.black
            
        case .nom_detail_firstBackground:
            return UIColor(red: 254/255, green: 250/255, blue: 231/255, alpha: 1.0)
        case .nom_detail_outerBackground:
            return UIColor.black
        case .nom_detail_innerBackground:
            return UIColor.black
        case .nom_detail_innerBorder:
            return UIColor(red: 157/255, green: 134/255, blue: 56/255, alpha: 1.0)
            
            
 
        case .popup_recognized_background:
            return UIColor(red: 157/255, green: 134/255, blue: 56/255, alpha: 1.0)
        case .popup_recognized_text:
            return UIColor.black
        case .popup_unanimous_background:
            return UIColor(red: 254/255, green: 250/255, blue: 231/255, alpha: 1.0)
        case .popup_unanimous_text:
            return UIColor.black
            
        case .filter_unselected_text:
            return UIColor.black
        case .filter_unselected_button_background:
            return UIColor(red: 254/255, green: 250/255, blue: 231/255, alpha: 1.0)
        case .filter_selected_text:
            return UIColor.black
        case .filter_selected_button_background:
            return UIColor(red: 157/255, green: 134/255, blue: 56/255, alpha: 1.0)
        
        }
    }
    
    
}


extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, fontSize:CGFloat) -> NSMutableAttributedString {
        if let font = UIFont(name: "Avenir Next", size: fontSize) {
            let attrs: [NSAttributedStringKey: Any] = [.font:font ]
            let boldString = NSMutableAttributedString(string:text, attributes: attrs)
            append(boldString)
        }
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
