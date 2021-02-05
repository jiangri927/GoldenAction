//
//  LoginConstraints.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 15/05/19.
//  Copyright © 2019 Sudesh Kumar. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let background         = UIColor.init(red: 37.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha: 1)
    static let gradientStartColor = UIColor.init(red: 253.0/255.0, green: 146.0/255, blue: 109.0/255.0, alpha: 1)
    static let gradientEndColor   = UIColor.init(red: 255.0/255.0, green: 227.0/255, blue: 113.0/255.0, alpha: 1)
    static let loginFontColor     = UIColor.init(red: 99.0/255.0, green: 99.0/255.0, blue: 99.0/255.0, alpha: 1)
    static let loginCellColor     = UIColor.init(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1)
    static let loginLineColor     = UIColor.init(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1)
}


class GradientColors {
    var gl:CAGradientLayer!
    
    init() {
        let colorLeft    = Constants.gradientStartColor.cgColor
        let colorRight   = Constants.gradientEndColor.cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorLeft, colorRight]
        //self.gl.locations = [0.0, 1.1]
        self.gl.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.gl.endPoint = CGPoint(x: 1.0, y: 1.0)

    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = Constants.background.cgColor
        self.textColor = UIColor.white
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = Constants.loginLineColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}



