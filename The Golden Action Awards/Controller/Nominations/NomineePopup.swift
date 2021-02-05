//
//  NomineePopup.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Firebase
import NYAlertViewController

class NomineePopup: NSObject, NSCoding {
    
    var vc: UITableViewController!
    var popup: NYAlertViewController!
    
    init(vc: UITableViewController) {
        self.vc = vc
    }
    
    init(vc: UITableViewController, popup: NYAlertViewController) {
        self.vc = vc
        self.popup = popup
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let vc = aDecoder.decodeObject(forKey: "vc") as! UITableViewController
        let popup = aDecoder.decodeObject(forKey: "popup") as! NYAlertViewController
        self.init(vc: vc, popup: popup)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.vc, forKey: "vc")
        aCoder.encode(self.popup, forKey: "popup")
    }
    
    
    func createNominatePopup() {
        self.popup = NYAlertViewController()
        self.popup.alertViewBackgroundColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.buttonCornerRadius = 10.0
        // Title
        self.popup.title = "VOTE"
        self.popup.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
        self.popup.titleColor = Colors.app_text.generateColor()
        // Message
        self.popup.message = "Do you wish to nominate an individual unanimously? or recognized?"
        self.popup.messageFont = Fonts.hira_pro_three.generateFont(size: 17.0)
        self.popup.messageColor = Colors.app_text.generateColor()
        // Buttons
        let unanimousAction = NYAlertAction(title: "UNANIMOUS", style: .cancel) { (_) in
            // Put if statement in here to see if they need nominations and if not then display the New Nomination Screen.
            let workItem = DispatchWorkItem {
                let checkoutVC = self.vc.storyboard?.instantiateViewController(withIdentifier: VCID.cart_screen.id) as! CartViewController
                let navController = UINavigationController(rootViewController: checkoutVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.vc.present(navController, animated:true, completion: nil)
            }
            self.vc.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        self.popup.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        self.popup.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
        
        let recognizedAction = NYAlertAction(title: "RECOGNIZED", style: .default) { (_) in
            // Check to see if users is logged in and if they have votes here!!
            // Segue to Login and Welcome Screen
            let workItem = DispatchWorkItem {
                let welcomeVC = self.vc.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.vc.present(navVC, animated: true, completion: nil)
            }
            self.vc.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        self.popup.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        self.popup.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.buttonColor = Colors.nom_detail_innerBorder.generateColor()
        // Actions
        self.popup.addAction(unanimousAction)
        self.popup.addAction(recognizedAction)
        
        self.popup.swipeDismissalGestureEnabled = true
        self.popup.backgroundTapDismissalGestureEnabled = true
    }
    
}
