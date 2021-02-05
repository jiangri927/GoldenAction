//
//  ProfilePopup.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import NYAlertViewController
import Firebase
import SwiftKeychainWrapper
import SCLAlertView
import FirebaseStorage
import FirebaseAuth

class ProfilePopup {
    
    private static let instanceInner = ProfilePopup()
    
    static var instance: ProfilePopup {
        return instanceInner
    }
    var confirmOldPasswordField: UITextField!
    var newPasswordField: UITextField!
    var confirmNewPasswordField: UITextField!
    
    
    
    func displayEditProfile(view: UIViewController, currentUser: Person) {
        let workItem = DispatchWorkItem {
            let alertVC = NYAlertViewController()
            let app_color = Colors.app_text.generateColor()
            
            // Background Color and Corner Design
            alertVC.alertViewBackgroundColor = Colors.black.generateColor()
        
            alertVC.buttonCornerRadius = 10.0
            // Title and Message Designs
            alertVC.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
            alertVC.titleColor = app_color
            alertVC.messageFont = Fonts.hira_pro_three.generateFont(size: 17.0)
            alertVC.messageColor = app_color
            
            // Cancel Then Default Button Designs
            alertVC.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
            alertVC.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
            alertVC.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
            alertVC.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
            alertVC.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
            alertVC.buttonColor = Colors.nom_detail_innerBorder.generateColor()
            
            alertVC.title = "Edit Password"
            alertVC.message = nil
            alertVC.buttonCornerRadius = 20.0
            
            
            
            // Actions
            alertVC.swipeDismissalGestureEnabled = true
            alertVC.backgroundTapDismissalGestureEnabled = true
            
            let okayAction = NYAlertAction(title: "Okay", style: .default) { (_) in
                print("okay Action")
                // let ref = DBRef.user(uid: currentUser.uid)
            }
            let cancelAction = NYAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertVC.addAction(okayAction)
            alertVC.addAction(cancelAction)
            view.present(alertVC, animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: workItem)
        
    }
    
    func displayEditPassword(view: UIViewController, confirmOld: Bool, email: String) {
        let workItem = DispatchWorkItem {
            let alertVC = NYAlertViewController()
            let app_color = Colors.app_text.generateColor()
            
            // Background Color and Corner Design
            alertVC.alertViewBackgroundColor = Colors.black.generateColor()
            if confirmOld {
                alertVC.addTextField(configurationHandler: { (textField) in
                    self.confirmOldPasswordField = textField
                    self.confirmOldPasswordField.textColor = Colors.app_text.generateColor()
                    self.confirmOldPasswordField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Confirm Old Password")
                    self.confirmOldPasswordField.backgroundColor = LoginColors.text_field.generateColor()
                    self.confirmOldPasswordField.borderStyle = .roundedRect
                    self.confirmOldPasswordField.isSecureTextEntry = true
                })
            } else {
                alertVC.addTextField(configurationHandler: { (textField) in
                    self.newPasswordField = textField
                    self.newPasswordField.textColor = Colors.app_text.generateColor()
                    self.newPasswordField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "New Password")
                    self.newPasswordField.backgroundColor = LoginColors.text_field.generateColor()
                    self.newPasswordField.borderStyle = .roundedRect
                    self.newPasswordField.isSecureTextEntry = true
                })
                alertVC.addTextField(configurationHandler: { (textField) in
                    self.confirmNewPasswordField = textField
                    self.confirmNewPasswordField.textColor = Colors.app_text.generateColor()
                    self.confirmNewPasswordField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Confirm New Password")
                    self.confirmNewPasswordField.backgroundColor = LoginColors.text_field.generateColor()
                    self.confirmNewPasswordField.borderStyle = .roundedRect
                    self.confirmNewPasswordField.isSecureTextEntry = true
                })
            }
            
            alertVC.buttonCornerRadius = 10.0
            // Title and Message Designs
            alertVC.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
            alertVC.titleColor = app_color
            alertVC.messageFont = Fonts.hira_pro_three.generateFont(size: 17.0)
            alertVC.messageColor = app_color
            
            // Cancel Then Default Button Designs
            alertVC.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
            alertVC.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
            alertVC.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
            alertVC.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
            alertVC.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
            alertVC.buttonColor = Colors.nom_detail_innerBorder.generateColor()
            
            alertVC.title = "Edit Password"
            alertVC.message = nil
            alertVC.buttonCornerRadius = 20.0
            
            
            
            // Actions
            alertVC.swipeDismissalGestureEnabled = true
            alertVC.backgroundTapDismissalGestureEnabled = true
            
            let okayAction = NYAlertAction(title: "Okay", style: .default) { (_) in
                if confirmOld {
                    let credential = EmailAuthProvider.credential(withEmail: email, password: self.confirmOldPasswordField.text!)
                    Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
                        guard error == nil else {
                            view.goldenAlert(title: "Error", message: "You have entered the wrong password", view: view)
                            let err = error! as NSError
                            Authorize.instance.handleAlert(error: err, view: view)
                            return
                        }
                        alertVC.dismiss(animated: true, completion: nil)
                        self.displayEditPassword(view: view, confirmOld: false, email: email)
                        
                    })
                } else {
                    guard self.newPasswordField.text != "" else {
                        view.goldenAlert(title: "Error", message: "Please enter your password", view: view)
                        return
                    }
                    guard self.confirmNewPasswordField.text != "" else {
                        view.goldenAlert(title: "Error", message: "Please enter your password", view: view)
                        return
                    }
                    guard self.newPasswordField.text == self.confirmNewPasswordField.text else {
                        view.goldenAlert(title: "Error", message: "Your passwords do not match", view: view)
                        return
                    }
                    Auth.auth().currentUser?.updatePassword(to: self.newPasswordField.text!, completion: { (error) in
                        guard error == nil else {
                            view.goldenAlert(title: "Error", message: "Error changing password, please check your internet and try again", view: view)
                            return
                        }
                        
                    })
                }
            }
            let cancelAction = NYAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertVC.addAction(okayAction)
            alertVC.addAction(cancelAction)
            view.present(alertVC, animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: workItem)
        
        
    }
    
    
    func editUserPassword(view:UIViewController, confirmOld: Bool, email:String){
       // let app_color = Colors.app_text.generateColor()
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon:false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        // Creat the subview
        var subview = UIView(frame: CGRect(x:0, y:0, width:216, height:140))
        let x = (subview.frame.width - 180) / 2
        
        if confirmOld {
            subview = UIView(frame: CGRect(x:0, y:0, width:216, height:50))
            self.confirmOldPasswordField = UITextField(frame: CGRect(x:x, y:15, width:180, height:30))
            self.confirmOldPasswordField.textColor = Colors.app_text.generateColor()
            self.confirmOldPasswordField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Confirm Old Password")
            self.confirmOldPasswordField.backgroundColor = LoginColors.text_field.generateColor()
            self.confirmOldPasswordField.borderStyle = .roundedRect
            self.confirmOldPasswordField.isSecureTextEntry = true
            
            subview.addSubview(self.confirmOldPasswordField)

        }else{
            subview = UIView(frame: CGRect(x:0, y:0, width:216, height:90))

            self.newPasswordField = UITextField(frame: CGRect(x:x, y:15, width:180, height:30))
            self.newPasswordField.textColor = Colors.app_text.generateColor()
            self.newPasswordField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "New Password")
            self.newPasswordField.backgroundColor = LoginColors.text_field.generateColor()
            self.newPasswordField.borderStyle = .roundedRect
            self.newPasswordField.isSecureTextEntry = true
            
            self.confirmNewPasswordField = UITextField(frame: CGRect(x:x, y:self.newPasswordField.frame.maxY + 15, width:180, height:30))
            self.confirmNewPasswordField.textColor = Colors.app_text.generateColor()
            self.confirmNewPasswordField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Confirm New Password")
            self.confirmNewPasswordField.backgroundColor = LoginColors.text_field.generateColor()
            self.confirmNewPasswordField.borderStyle = .roundedRect
            self.confirmNewPasswordField.isSecureTextEntry = true
            
            subview.addSubview(self.newPasswordField)
            subview.addSubview(self.confirmNewPasswordField)

        }
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
      //  alert.showEdit(nil, subTitle: nil, closeButtonTitle: "band", timeout: nil, colorStyle: nil, colorTextButton: nil, circleIconImage: nil, animationStyle: nil)
        
        alert.addButton("Okay", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil){
        
        
       // alert.addButton("Okay") {
            print("Logged in")
            if confirmOld {
                let credential = EmailAuthProvider.credential(withEmail: email, password: self.confirmOldPasswordField.text!)
                Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (authResult, error) in
                    guard error == nil else {
                        view.goldenAlert(title: "Error", message: "You have entered the wrong password", view: view)
                        let err = error! as NSError
                        return
                    }
                    
                    self.editUserPassword(view:view, confirmOld:false, email:email)
                })
            } else {
                guard self.newPasswordField.text != "" else {
                    view.goldenAlert(title: "Error", message: "Please enter your password", view: view)
                    return
                }
                guard self.confirmNewPasswordField.text != "" else {
                    view.goldenAlert(title: "Error", message: "Please enter your password", view: view)
                    return
                }
                guard self.newPasswordField.text == self.confirmNewPasswordField.text else {
                    view.goldenAlert(title: "Error", message: "Your passwords do not match", view: view)
                    return
                }
                Auth.auth().currentUser?.updatePassword(to: self.newPasswordField.text!, completion: { (error) in
                    guard error == nil else {
                        view.goldenAlert(title: "Error", message: "Error changing password, please check your internet and try again", view: view)
                        return
                    }
                    view.goldenAlert(title: "Change Password", message: "Password changed sucessfull!", view: view)
                })
            }
        }
        
        alert.addButton("Cancel", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil){
        //alert.addButton("Cancel", action: {
            print("Duration button tapped")
        }
        //)
        
        alert.showInfo("Edit password", subTitle: "")
    }
    
    
    
    func forgotPassword(view:UIViewController, email:String)
    {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon:false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        // Creat the subview
        var subview = UIView(frame: CGRect(x:0, y:0, width:216, height:140))
        let x = (subview.frame.width - 180) / 2
        
        
        subview = UIView(frame: CGRect(x:0, y:0, width:216, height:50))
        self.confirmOldPasswordField = UITextField(frame: CGRect(x:x, y:15, width:180, height:30))
        self.confirmOldPasswordField.textColor = Colors.app_text.generateColor()
        self.confirmOldPasswordField.attributedPlaceholder = NSAttributedString(string: "Enter Account Email",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 14.0)])
        self.confirmOldPasswordField.font = UIFont(name: self.confirmOldPasswordField.font?.fontName ?? "", size: 15)
        self.confirmOldPasswordField.backgroundColor = LoginColors.text_field.generateColor()
        self.confirmOldPasswordField.borderStyle = .roundedRect
        self.confirmOldPasswordField.textAlignment = .center
        self.confirmOldPasswordField.autocapitalizationType = .none
        self.confirmOldPasswordField.autocorrectionType = .no
        
        subview.addSubview(self.confirmOldPasswordField)
        
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        //  alert.showEdit(nil, subTitle: nil, closeButtonTitle: "band", timeout: nil, colorStyle: nil, colorTextButton: nil, circleIconImage: nil, animationStyle: nil)
        
        alert.addButton("Okay", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil){
            guard self.confirmOldPasswordField.text != "" else {
                view.goldenAlert(title: "Error", message: "Please enter your email address", view: view)
                return
            }
            
            if self.confirmOldPasswordField.text != "" {
                Auth.auth().sendPasswordReset(withEmail: self.confirmOldPasswordField.text!, completion: nil)
            }


        }
        
        alert.addButton("Cancel", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil){
            //alert.addButton("Cancel", action: {
            print("Duration button tapped")
        }
        //)
        
        alert.showInfo("Password Reset", subTitle: "Enter Account Email")
    }
    
}
