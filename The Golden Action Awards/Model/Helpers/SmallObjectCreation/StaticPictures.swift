//
//  StaticPictures.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit

enum StaticPictures {
    
    case head_logo
    case heart_logo
    case hand_logo
    case health_logo
    case checkbox_form
    case error_form
    case picture_selection
    
    case titleview_head
    case titleview_heart
    case titleview_hand
    case titleview_health
    
    case gold_head
    case gold_heart
    case gold_hand
    case gold_health
    
    case background
    
    func generatePic() -> UIImage {
        switch self {
        case .head_logo:
            return UIImage(named: "headLogo")!
        case .heart_logo:
            return UIImage(named: "heartLogo")!
        case .checkbox_form:
            return UIImage(named: "checkmark_golden")!
        case .error_form:
            return UIImage(named: "wrong_golden")!
        case .picture_selection:
            return UIImage(named: "profpic_placeholder")!
        case .titleview_head:
            return UIImage(named: "titleviewhead")!
        case .titleview_heart:
            return UIImage(named: "titleviewheart")!
        case .titleview_hand:
            return UIImage(named: "titleviewhand")!
        case .titleview_health:
            return UIImage(named: "titleviewhealth")!
        case .hand_logo:
            return UIImage(named: "handLogo")!
        case .health_logo:
            return UIImage(named: "healthLogo")!
        case .gold_head:
            return UIImage(named: "gold_head")!
        case .gold_heart:
            return UIImage(named: "gold_heart")!
        case .gold_hand:
            return UIImage(named: "gold_hand")!
        case .gold_health:
            return UIImage(named: "gold_health")!
        case .background:
            return UIImage(named: "bg")!
        }
        
        
        
    }
    
    
    
    
}
