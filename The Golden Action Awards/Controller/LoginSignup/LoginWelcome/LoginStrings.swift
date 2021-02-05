//
//  LoginStrings.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/17/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit

enum LoginStrings {
    case welcome_email
    case welcome_password
    case login_text
    case forgot_password
    case not_registered
    case signup_text
    
    case signup_titles
    case signup_formvalidate_labels
    
    case new_nom_text
    
    case placeholder_text
    
    case error_text
    
    func generateString(text: String) -> NSMutableAttributedString {
        switch self {
        case .welcome_email:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 14.0)])
        case .welcome_password:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 14.0)])
        case .login_text:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        case .signup_text:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 15.0)])
        case .forgot_password:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 12.0)])
        case .not_registered:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 12.0)])
        case .signup_titles:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 21.0)])
        case .signup_formvalidate_labels:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : LoginColors.form_error.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 12.0)])
        case .new_nom_text:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 15.0)])
        case .placeholder_text:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 17.0)])
            
        case .error_text:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 13.0)])
            
        }
    }
}


enum LoginColors {
    case login_button
    case view_lines
    case signup_button
    case text_field
    case forgot_password
    

    case form_success
    case form_error
    
    func generateColor() -> UIColor {
        switch self {
        case .login_button:
            return UIColor(red: 252/255, green: 231/255, blue: 145/255, alpha: 1.0)
        case .view_lines:
            return Colors.app_text.generateColor()
        case .signup_button:
            return UIColor(red: 197/255, green: 171/255, blue: 73/255, alpha: 1.0)
        case .text_field:
            return UIColor.clear
        case .forgot_password:
            return UIColor.clear
        case .form_success:
            return UIColor.green
        case .form_error:
            return UIColor.red
        }
    }
}

