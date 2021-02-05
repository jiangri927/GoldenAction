//
//  PopoverFactory.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Popover

enum ElementType {
    case button
    case imageview
    case tabbar
    case view
    
    var id: Int {
        switch self {
        case .button:
            return 0
        case .imageview:
            return 1
        case .tabbar:
            return 2
        case .view:
            return 3
        }
    }
}
class PopoverFactory: NSObject, NSCoding {
    
    let que = ThreadFactory.ui_userInit.generate(priority: 0)
    var vc: UIViewController
    var type: Int
    var element: Any
    var button: UIButton!
    var imageView: UIImageView!
    var tabbar: UITabBar!
    var view: UIView!
    
    init(vc: UIViewController, type: Int, element: Any) {
        self.vc = vc
        self.type = type
        self.element = element
        
    }
    
    
  
    func displayPopover() {
        let width = self.vc.view.frame.width / 4.0
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        let options = [
            .type(.down),
            .cornerRadius(width / 2),
            .animationIn(0.3),
            .blackOverlayColor(Colors.app_color.generateColor()),
            .arrowSize(CGSize.init(width: 2, height: 5)),
            .color(Colors.black.generateColor())
            ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        self.checkElementAndShow(popover: popover, aView: aView)
    }
    
    func checkElementAndShow(popover: Popover, aView: UIView) {
        switch (self.type) {
        case ElementType.button.id:
            self.button = element as! UIButton
            popover.show(aView, fromView: self.button)
        case ElementType.imageview.id:
            self.imageView = element as! UIImageView
            popover.show(aView, fromView: self.imageView)
        case ElementType.tabbar.id:
            self.tabbar = element as! UITabBar
            popover.show(aView, fromView: self.tabbar)
        case ElementType.view.id:
            self.view = element as! UIView
            popover.show(aView, fromView: self.view)
            
        default:
            self.view = element as! UIView
            popover.show(aView, fromView: self.view)
        }
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let vc = aDecoder.decodeObject(forKey: "vc") as! UIViewController
        let type = aDecoder.decodeInteger(forKey: "type")
        let element = aDecoder.decodeObject(forKey: "element")
        self.init(vc: vc, type: type, element: element)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.vc, forKey: "vc")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.element, forKey: "element")
    
    }
    
}





















