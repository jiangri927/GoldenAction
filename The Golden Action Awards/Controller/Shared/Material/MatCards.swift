//
//  MatCards.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
//import MaterialComponents
//import MaterialComponents.MaterialCards

class ShadowedView: UIView {
    
    override class var layerClass: AnyClass {
        return UIView.self
    }
    
//    var shadowLayer: MDCShadowLayer {
//        return self.layer as! MDCShadowLayer
//    }
    
    func setDefaultElevation() {
       // self.shadowLayer.elevation = .cardPickedUp
    }
    
}
//class ShadowedCollectionViewCell: MDCCardCollectionCell {
//}
