//
//  Colors.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/23/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit



class Design {
    
    
    private static let instanceInner = Design()
    
    static var instance: Design {
        return instanceInner
    }
    
    
    let black = UIColor.black
    let white = UIColor.white
    let clear = UIColor.clear
    
    let lighter_app_color = UIColor(red: 255/255, green: 224/255, blue: 101/255, alpha: 1.0)
    
    let darker_app_color = UIColor(red: 157/255, green: 134/255, blue: 56/255, alpha: 1.0)
    
    let app_color = UIColor(red: 62/255, green: 56/255, blue: 63/255, alpha: 1.0)
    
    
}
