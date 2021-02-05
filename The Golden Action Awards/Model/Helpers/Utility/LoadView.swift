//
//  LoadView.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/23/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import DGActivityIndicatorView


class LoadView {
    
    private static let instanceInner = LoadView()
    
    static var instance: LoadView {
        return instanceInner
    }
    let type = DGActivityIndicatorAnimationType.ballClipRotate
    let app_color = Colors.app_navbar_tint.generateColor()
    let black = Colors.black.generateColor()
    
    func generateLoad(size: CGFloat, appColor: Bool) -> DGActivityIndicatorView {
        switch appColor {
        case true:
            let load = DGActivityIndicatorView(type: self.type, tintColor: self.app_color, size: size)
            return load!
        case false:
            let load = DGActivityIndicatorView(type: self.type, tintColor: self.black, size: size)
            return load!
        default:
            let load = DGActivityIndicatorView(type: self.type, tintColor: self.app_color, size: size)
            return load!
            
        }
        
    }
}
class LoadLayout {
    private static let instanceInner = LoadLayout()
    
    static var instance: LoadLayout {
        return instanceInner
    }
    func addCenteredPic(view: UIView, dg: UIImageView) {
        dg.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: dg, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dg.bounds.width)
        let heightConstraint = NSLayoutConstraint(item: dg, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dg.bounds.height)
        let xConstraint = NSLayoutConstraint(item: dg, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: dg, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
    }
    func addCenteredLoadScreen(view: UIView, dg: DGActivityIndicatorView) {
        
        dg.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: dg, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dg.bounds.width)
        let heightConstraint = NSLayoutConstraint(item: dg, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dg.bounds.height)
        let xConstraint = NSLayoutConstraint(item: dg, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: dg, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
    }
    
}
