//
//  WelcomeViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 sudesh kumar. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import SwiftKeychainWrapper
import NYAlertViewController
import PhoneNumberKit
import SCLAlertView
import JSSAlertView
import DGActivityIndicatorView


class SignUpViewController: UIViewController{
    
    // MARK: - Outlet Declaration
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designMainView()
        self.designTextField()
        self.designScreen()
        let keyboardDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        self.view.addGestureRecognizer(keyboardDismiss)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        designButton()
    }
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func designMainView(){
        self.view.backgroundColor = Constants.background
    }
    
    
    func designScreen(){
        // MARK: - Implement Work Items on UI Thread per design Item Once working with the data model!!!! ---> This is why you have created so many seperate design functions
        self.designButton()
        self.designTextField()
        self.implementGestures()
    }
    
    func designTextField() {
        
        self.emailTextField.attributedPlaceholder = NSMutableAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.emailTextField.backgroundColor = .black
        self.emailTextField.borderStyle = .none
        self.emailTextField.textColor = Constants.loginFontColor
        self.emailTextField.delegate = self
        self.emailTextField.returnKeyType = .default
        self.emailTextField.setBottomBorder()
        
        self.passwordTextField.attributedPlaceholder = NSMutableAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.passwordTextField.backgroundColor = .black
        self.passwordTextField.borderStyle = .none
        self.passwordTextField.textColor = Constants.loginFontColor
        self.passwordTextField.delegate = self
        self.passwordTextField.returnKeyType = .default
        self.passwordTextField.setBottomBorder()
        
        self.rePasswordTextField.attributedPlaceholder = NSMutableAttributedString(string: "Password repeat", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.rePasswordTextField.backgroundColor = .black
        self.rePasswordTextField.borderStyle = .none
        self.rePasswordTextField.textColor = Constants.loginFontColor
        self.rePasswordTextField.delegate = self
        self.rePasswordTextField.returnKeyType = .default
        self.rePasswordTextField.setBottomBorder()
    }
    
    func designButton() {
        let imageColor = self.gradient(size: self.createAccountButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        self.createAccountButton.layer.cornerRadius  = 10.0
        self.createAccountButton.layer.masksToBounds = true
        self.createAccountButton.backgroundColor     = UIColor.init(patternImage: imageColor!)
        self.createAccountButton.setAttributedTitle(LoginStrings.login_text.generateString(text: "Create Account"), for: [])
        self.createAccountButton.addTarget(self, action: #selector(profileDetails(_:)), for: .touchUpInside)
    }
    
    @objc func profileDetails(_ sender: UIButton) {
        guard self.emailTextField.text != "" else {
            self.goldenAlert(title: "Error", message: "Please enter your email or phone number", view: self)
            return
        }
        
        if RegexChecker.email(text: self.emailTextField.text!).check() {
            guard self.passwordTextField.text != "" else {
                self.goldenAlert(title: "Error", message: "Please enter your password", view: self)
                return
            }
            
            guard self.passwordTextField.text == self.rePasswordTextField.text else {
                self.goldenAlert(title: "Error", message: "Please check your password", view: self)
                return
            }
            
            let password = self.passwordTextField.text!
            let email = self.emailTextField.text!
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let yourProfile: SignupDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "SignupDetailViewController") as! SignupDetailViewController
        
        yourProfile.password = self.passwordTextField.text
        yourProfile.email = self.emailTextField.text
        yourProfile.acctType = "email"
        yourProfile.admin = false
        yourProfile.isEditProfile = false
        yourProfile.adminDescription = "No admin description"
        yourProfile.adminAddress = "No address"
        self.navigationController?.pushViewController(yourProfile, animated: true)
    }
    
    
    @objc func sponsorDidTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: SegueId.welcome_sponsorinfo.id, sender: self)
    }
    
    
    @objc func segueSignup(_ sender: UIButton) {
        self.performSegue(withIdentifier: SegueId.welcome_signupEmail.id, sender: self)
    }
    
    // MARK: - Gesture Recognizer Delegate
    func implementGestures() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .down
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.signupGoogle_signupDetail.id {
            let destinationVC = segue.destination as! SignupDetailViewController
            destinationVC.acctType    = AcctType.google.type
        }
    }
    
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }else if textField == self.passwordTextField {
            self.rePasswordTextField.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
        return true
    }
}


