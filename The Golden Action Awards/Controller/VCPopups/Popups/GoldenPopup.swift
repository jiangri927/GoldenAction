//
//  GoldenPopup.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper
import NYAlertViewController
enum GoldenPopupReason {
    case new_nomination
    case change_location
    case change_category
    case vote_nomination
    
    var key: Int {
        switch self {
        case .new_nomination:
            return 0
        case .change_location:
            return 1
        case .change_category:
            return 2
        case .vote_nomination:
            return 3
        }
    }
}
class NominatePopup: NSObject, NSCoding {
    
    var vc: UIViewController!
    var customPopup: NYAlertViewController!
    
    
    var firstText: UITextField!
    var lastText: UITextField!
    var emailText: UITextField!
    var contactText: UITextField!
    var locationText: UITextField!
    var storyView: UITextField!
    var nomineePic: UIImageView!
    
    
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    init(vc: UIViewController, customPopup: NYAlertViewController) {
        self.vc = vc
        self.customPopup = customPopup
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let vc = aDecoder.decodeObject(forKey: "vc") as! UIViewController
        let popup = aDecoder.decodeObject(forKey: "popup") as! NYAlertViewController
        self.init(vc: vc, customPopup: popup)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.vc, forKey: "vc")
        aCoder.encode(self.customPopup, forKey: "popup")
    }
    
    func createPopup() {
        
    }
    func designTitle() {
        // Title
        self.customPopup.titleFont = Fonts.hira_pro_six.generateFont(size: 16.0)
        self.customPopup.titleColor = Colors.app_navbar_tint.generateColor()
        self.customPopup.view.tintColor = Colors.popup_background.generateColor()
        // UIImageView --> Picture for Nominee
    }
    
    
    func designTextField(placeholder: String, textField: UITextField) {
        // TextFields --> First Name, Last Name, Email Address, Contact Number, Location
        textField.attributedPlaceholder = Strings.popup_nominated_placeholder.generateString(text: placeholder)
        textField.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        textField.borderStyle = .roundedRect
        textField.tintColor = Colors.popup_background.generateColor()
        textField.layer.borderColor = Colors.app_text.generateColor().cgColor
        textField.layer.borderWidth = 1.0
    }
}
extension UIView {
    
    func addFormatedConstraints(format: String, views: UIView...) {
        var viewsDictionary = [String : UIView]()
        for (index, view) in views.enumerated() {
            let ky = "v\(index)"
            viewsDictionary[ky] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

















