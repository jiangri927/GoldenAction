//
//  NomDetailStrings.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/17/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit

enum NomDetailStrings {
    
    case nomineeName
    case location
    case pendingAward
    case nominatedBy
    case numberVotesLabel
    case numberVotesButton
    case donateLabel
    case votesLabel
    case timeRemaining
    case photosLabel
    case achievmentsLabel
    case achievmentsSummary
    case tierDetils
    
    
    func generateString(text: String) -> NSMutableAttributedString {
        switch self {
        case .nomineeName:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 15.0)])
        case .location:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 14.0)])
        case .pendingAward:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 13.0)])
        case .nominatedBy:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 12.0)])
            
        case .numberVotesLabel:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 15.0)])
        case .numberVotesButton:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 15.0)])
            
        case .donateLabel:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 12.0)])
        case .votesLabel:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 12.0)])
        case .timeRemaining:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 12.0)])
            
        case .photosLabel:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 15.0)])
        
        case .achievmentsLabel:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 15.0)])
        case .achievmentsSummary:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_three.generateFont(size: 12.0)])
        case .tierDetils:
            return NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : Colors.app_text.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 15.0)])
            
        }
    }
    
}
