//
//  PhoneView.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/13/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Firebase
import NYAlertViewController
import PhoneNumberKit



class PhoneView: NSObject, NSCoding {
    
    var welcomeVC: WelcomeViewController!
    var popup: NYAlertViewController!
    var phoneTextField: UITextField!
    var verificationField: UITextField!
    var phoneText = PhoneNumberTextField()
    let phoneKit = PhoneNumberKit()
    
    let auth = Authorize.instance
    
    init(welcomeVC: WelcomeViewController) {
        self.welcomeVC = welcomeVC
    }
    init(welcomeVC: WelcomeViewController, popup: NYAlertViewController, phone: UITextField) {
        self.welcomeVC = welcomeVC
        self.popup = popup
        self.phoneTextField = phone
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let welcomeVC = aDecoder.decodeObject(forKey: "welcomeVC") as! WelcomeViewController
        let popup = aDecoder.decodeObject(forKey: "popup") as! NYAlertViewController
        let phoneField = aDecoder.decodeObject(forKey: "phoneField") as! UITextField
        self.init(welcomeVC: welcomeVC, popup: popup, phone: phoneField)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.welcomeVC, forKey: "welcomeVC")
        aCoder.encode(self.popup, forKey: "popup")
        aCoder.encode(self.phoneTextField, forKey: "phoneField")
    }
    
    func createPhone(verification: Bool, phoneID: String, phoneNumber: String) {
        self.popup = NYAlertViewController()
        self.popup.alertViewBackgroundColor = Colors.popup_background.generateColor()
        self.popup.buttonCornerRadius = 10.0
        // Title
        
        self.popup.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
        self.popup.titleColor = Colors.app_text.generateColor()
        self.popup.message = nil
        if !verification {
            self.popup.title = "Enter Phone Number"
            self.popup.addTextField { (textField) in
                self.phoneTextField = textField
                self.phoneTextField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "(xxx) xxx-xxxx")
                self.phoneTextField.borderStyle = .roundedRect
                self.phoneTextField.layer.cornerRadius = 10.0
                self.phoneTextField.layer.masksToBounds = false
                self.phoneTextField.keyboardType = .phonePad
                self.phoneTextField.becomeFirstResponder()
                //self.phoneText.text = textField?.text
            }
        } else {
            self.popup.title = "Enter Verification Code"
            self.popup.addTextField { (textField) in
                self.verificationField = textField
                self.verificationField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter verification code")
                self.verificationField.borderStyle = .roundedRect
                self.verificationField.layer.cornerRadius = 10.0
                self.verificationField.layer.masksToBounds = false
                self.verificationField.keyboardType = .numberPad
                self.verificationField.becomeFirstResponder()
            }
        }
        // Buttons
        let cancelAction = NYAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.popup.dismiss(animated: true, completion: nil)
        }
        self.popup.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        self.popup.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
        
        let proceedAction = NYAlertAction(title: "Proceed", style: .default) { (button) in
            button?.enabled = true
            if !verification {
                guard self.phoneTextField.text != "" else {
                    self.popup.dismiss(animated: true, completion: nil)
                    self.welcomeVC.goldenAlert(title: "Please enter your phone number", message: "", view: self.welcomeVC)
                    return
                }
                self.phoneText.text = self.phoneTextField.text!
                print(self.phoneText.nationalNumber)
                guard self.phoneText.isValidNumber else {
                    self.popup.dismiss(animated: true, completion: nil)
                    self.welcomeVC.goldenAlert(title: "Please enter a valid phone number", message: "", view: self.welcomeVC)
                    return
                }
                button?.enabled = false
                if KeychainWrapper.standard.hasValue(forKey: Keys.phone_id(number: self.phoneText.text!).key) {
                    self.popup.dismiss(animated: true, completion: nil)
                    self.welcomeVC.goldenAlert(title: "Account already associated", message: "Please use your phone number to sign in above!", view: self.welcomeVC)
                } else {
                    PhoneAuthProvider.provider().verifyPhoneNumber("+1\(self.phoneText.nationalNumber)", uiDelegate: nil, completion: { (verifID, error) in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            self.popup.dismiss(animated: true, completion: nil)
                            Authorize.instance.handleAlert(error: error! as NSError, view: self.welcomeVC)
                            return
                        }
                        self.popup.dismiss(animated: true, completion: nil)
                        //KeychainWrapper.standard.set(verifID!, forKey: Keys.phone_id(number: self.phoneText.nationalNumber).key)
                        self.createPhone(verification: true, phoneID: verifID!, phoneNumber: self.phoneTextField.text!)
                    })
                }
            } else {
                guard self.verificationField.text != "" else {
                    self.popup.dismiss(animated: true, completion: nil)
                    self.welcomeVC.goldenAlert(title: "Please enter the verification code", message: "", view: self.welcomeVC)
                    return
                }
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: phoneID, verificationCode: self.verificationField.text!)
                Auth.auth().currentUser?.link(with: credential, completion: { (user, error) in
                    guard error == nil else {
                        self.popup.dismiss(animated: true, completion: nil)
                        let alertVC = self.errorVerification(title: "Error", message: "\(error!.localizedDescription)", buttonOneTitle: "Retry", buttonTwoTitle: "Cancel", phoneId: phoneID, phoneNumber: phoneNumber)
                        self.welcomeVC.present(alertVC, animated: true, completion: nil)
                        print(error!.localizedDescription)
                        return
                    }
                    button?.enabled = false
                    self.welcomeVC.phoneCredential = credential
                    self.welcomeVC.phoneNumber = phoneNumber
                    self.popup.dismiss(animated: true, completion: nil)
                    self.welcomeVC.performSegue(withIdentifier: SegueId.signupPhone_signupDetail.id, sender: self)
                })
                
                //let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifID, verificationCode: self.verificationField.text!)
                //let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: Keys.load_vc.key) as! LoadViewController
                //self.present(loadingVC, animated: false, completion: nil)
            }
        }
        self.popup.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        self.popup.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.buttonColor = Colors.nom_detail_innerBorder.generateColor()
        // Actions
        self.popup.addAction(proceedAction)
        self.popup.addAction(cancelAction)
        
        
        self.popup.swipeDismissalGestureEnabled = true
        self.popup.backgroundTapDismissalGestureEnabled = true
        self.welcomeVC.present(self.popup, animated: true, completion: nil)
        
    }
    func errorVerification(title: String, message: String, buttonOneTitle: String, buttonTwoTitle: String, phoneId: String, phoneNumber: String) -> NYAlertViewController {
        // Set a title and message
        // Customize appearance as desired
        let alertVC = NYAlertViewController()
        alertVC.title = title
        alertVC.message = message
        self.welcomeVC.designAlertView(alertVC: alertVC)
        
        let leftAction = NYAlertAction(title: buttonOneTitle, style: .default) { (_) in
            alertVC.dismiss(animated: true, completion: nil)
            self.createPhone(verification: true, phoneID: phoneId, phoneNumber: phoneNumber)
        }
        let rightAction = NYAlertAction(title: buttonTwoTitle, style: .default) { (_) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(leftAction)
        alertVC.addAction(rightAction)
        return alertVC
    }
    @objc func retryDidTap(_ sender: NYAlertAction) {
        if let key = KeychainWrapper.standard.string(forKey: Keys.phone_id(number: self.phoneText.text!).key) {
            self.popup.dismiss(animated: true, completion: nil)
            self.createPhone(verification: true, phoneID: key, phoneNumber: self.phoneText.text!)
        }
    }
    @objc func cancelDidTap(_ sender: NYAlertAction) {
        self.popup.dismiss(animated: true, completion: nil)
    }
    func createVerification() {
        
    }
    
    
}
