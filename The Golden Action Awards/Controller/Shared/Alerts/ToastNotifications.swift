//
//  ToastNotifications.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

//
//  ToastNotification.swift
//  Bonita-Admin
//
//  Created by Michael Kunchal on 9/3/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Toast_Swift

enum StyledToast {
    case messages
    case clocking // Location Service
    case errors
    
    func getStyle() -> ToastStyle {
        var style = ToastStyle()
        style.cornerRadius = cornerRadius
        style.titleAlignment = titleAlginment
        style.titleFont = titleFont
        style.messageFont = messageFont
        style.displayShadow = true
        style.titleColor = titleColor
        style.messageColor = messageColor
        style.imageSize = imageSize
        style.backgroundColor = UIColor.white
        switch self {
        case .clocking:
            return style
        case .messages:
            return style
        case .errors:
            return style
        }
    }
    var type: String {
        switch self {
        case .messages:
            return "messages"
        case .clocking:
            return "clocking"
        case .errors:
            return "errors"
        }
    }
    private var cornerRadius: CGFloat {
        return 10.0
    }
    private var titleAlginment: NSTextAlignment {
        return .center
    }
    private var avenirCondensedMedium: String {
        return "AvenirNextCondensed-Medium"
    }
    private var titleColor: UIColor {
        switch self {
        case .messages:
            return UIColor.black
        case .clocking:
            return UIColor.black
        case .errors:
            return UIColor.red
        }
    }
    private var messageColor: UIColor {
        switch self {
        case .messages:
            return UIColor.black
        case .clocking:
            return UIColor.black
        case .errors:
            return UIColor.black
        }
    }
    private var titleFont: UIFont {
        switch self {
        case .messages:
            return UIFont(name: self.avenirCondensedMedium, size: 17.0)!
        case .errors:
            return UIFont(name: self.avenirCondensedMedium, size: 17.0)!
        case .clocking:
            return UIFont(name: self.avenirCondensedMedium, size: 17.0)!
        }
    }
    private var imageSize: CGSize {
        switch self {
        case .messages:
            return CGSize(width: 21.0, height: 21.0)
        case .errors:
            return CGSize(width: 21.0, height: 21.0)
        case .clocking:
            return CGSize(width: 21.0, height: 21.0)
        }
    }
    private var messageFont: UIFont {
        switch self {
        case .messages:
            return UIFont(name: self.avenirCondensedMedium, size: 15.0)!
        case .errors:
            return UIFont(name: self.avenirCondensedMedium, size: 15.0)!
        case .clocking:
            return UIFont(name: self.avenirCondensedMedium, size: 15.0)!
        }
    }
}
class ToastNotification: NSObject, NSCoding {
    
    var img: UIImage
    var message: String!
    var title: String
    var duration: Double
    var type: String
    var vc: UIViewController
    var style: ToastStyle
    var task: DispatchFactory
    
    init(img: UIImage, message: String!, title: String, duration: Double, type: String, vc: UIViewController) {
        self.task = ThreadFactory.ui_userInteract.generate(priority: -6)
        self.img = img
        self.message = message
        self.title = title
        self.duration = duration
        self.type = type
        self.vc = vc
        if self.type == StyledToast.clocking.type {
            self.style = StyledToast.clocking.getStyle()
        } else if self.type == StyledToast.errors.type {
            self.style = StyledToast.errors.getStyle()
        } else {
            self.style = StyledToast.messages.getStyle()
        }
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        let data = aDecoder.decodeObject(forKey: "imgData") as! Data
        let img = UIImage(data: data)
        let title = aDecoder.decodeObject(forKey: "title") as? String ?? "N/A"
        let message = aDecoder.decodeObject(forKey: "message") as? String ?? nil
        let duration = aDecoder.decodeDouble(forKey: "duration")
        let type = aDecoder.decodeObject(forKey: "type") as? String ?? StyledToast.errors.type
        let vc = aDecoder.decodeObject(forKey: "vc") as! UIViewController
        self.init(img: img!, message: message, title: title, duration: duration, type: type, vc: vc)
    }
    func encode(with aCoder: NSCoder) {
        let imgData = UIImageJPEGRepresentation(self.img, 0.9)
        aCoder.encode(imgData, forKey: "imgData")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.message, forKey: "message")
        aCoder.encode(self.duration, forKey: "duration")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.vc, forKey: "vc")
    }
    
    func displayToast(position: ToastPosition) {
        let workItem = DispatchWorkItem {
            self.vc.view.makeToast(self.message, duration: self.duration, position: position, title: self.title, image: self.img, style: self.style, completion: nil)
        }
        self.task.que.async(execute: workItem)
    }
    
    /*func setupAlert(message: String) {
     var style = ToastStyle()
     style.cornerRadius = 10.0
     style.titleAlignment = .center
     style.titleFont = UIFont(name: "AvenirNextCondensed-Medium", size: 15.0)!
     style.titleColor = UIColor(displayP3Red: 0, green: 195/255, blue: 132/255, alpha: 1.0)
     //style.backgroundColor = UIColor(displayP3Red: 248/255, green: 248/255, blue: 255/255, alpha: 0.8)
     //style.activityBackgroundColor = UIColor(displayP3Red: 248/255, green: 248/255, blue: 255/255, alpha: 0.8)
     //style.activityIndicatorColor = UIColor(displayP3Red: 120/255, green: 120/255, blue: 120/255, alpha: 1.0)
     style.displayShadow = true
     style.messageColor = UIColor(displayP3Red: 0, green: 195/255, blue: 132/255, alpha: 1.0)
     style.messageFont = UIFont(name: "AvenirNextCondensed-Medium", size: 15.0)!
     style.imageSize = CGSize(width: 21, height: 21)
     self.view.makeToast(nil, duration: 4.0, position: .top, title: message, image: self.checked, style: style, completion: nil)
     } */
}


