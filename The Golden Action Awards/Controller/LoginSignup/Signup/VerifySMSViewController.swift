//
//  VerifySMSViewController.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 16/05/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleUtilities
import Firebase
import FirebaseAuth

class VerifySMSViewController : UIViewController,UITextFieldDelegate{
    // MARK: - Outlet Declaration
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var verifySMSButton: UIButton!
    @IBOutlet weak var smsTextField: UITextField!
    
    @IBOutlet weak var reSendVerificationCode:UIButton!

    
    var signUpController : SignupDetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
       
        let createGesture = UITapGestureRecognizer(target: self, action: #selector(createDidTap(recognizer:)))
        self.verifySMSButton.addGestureRecognizer(createGesture)
        
        let keyboardDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        self.view.addGestureRecognizer(keyboardDismiss)
        
        let imageColor1 = self.gradient(size: self.titleLbl.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.titleLbl.textColor = UIColor.init(patternImage: imageColor1!)
        
        self.designTextField()
        
        let resendGesture = UITapGestureRecognizer(target: self, action: #selector(resendDidTap(recognizer:)))
        self.reSendVerificationCode.addGestureRecognizer(resendGesture)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let imageColor = self.gradient(size: self.verifySMSButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        self.verifySMSButton.backgroundColor = UIColor.init(patternImage: imageColor!)
        self.verifySMSButton.setTitleColor(UIColor.white, for: [])
        self.verifySMSButton.layer.cornerRadius = 10.0
        self.verifySMSButton.layer.masksToBounds = true
        
    }
    
    @objc func resendDidTap(recognizer: UITapGestureRecognizer) {
        let textField = self.signUpController.phoneField
        let trimmedString = textField!.text!.trimmingCharacters(in: .whitespacesAndNewlines) as String
        let phoneNumber = trimmedString.replacingOccurrences(of: " ", with: "")
        print(phoneNumber)
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+1\(phoneNumber))", uiDelegate: nil) { (verificationID, error) in
            guard error == nil else {
                self.goldenAlert(title: "Error", message: "There was an error authing the phone, please try again", view: self)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    
    func designTextField(){
        self.smsTextField.attributedPlaceholder = NSMutableAttributedString(string: "verification code", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.smsTextField.backgroundColor = .black
        self.smsTextField.borderStyle = .none
        self.smsTextField.textColor = Constants.loginFontColor
        self.smsTextField.setBottomBorder()
        self.smsTextField.delegate = self
        self.smsTextField.returnKeyType = .default
    }
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func createDidTap(recognizer: UITapGestureRecognizer) {
        
        let testVerificationCode = "123456"
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        print(verificationID)
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: self.smsTextField.text!)
       
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                self.goldenAlert(title: "SMS Verification", message: "Please check your verification!", view: self)
                return
            }
            self.signUpController.submitUserDataToServer()            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkingPhoneValidation(){
        
        let phoneNumber = "+1 704-557-0145"
        
        // This test verification code is specified for the given test phone number in the developer console.
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            guard error == nil else {
                self.goldenAlert(title: "Error", message: "There was an error authing the phone, please try again", view: self)
                print(error!.localizedDescription)
                return
            }
            
        }
    }
    
}


