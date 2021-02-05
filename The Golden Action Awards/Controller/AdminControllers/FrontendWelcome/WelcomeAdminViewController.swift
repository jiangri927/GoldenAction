//
//  WelcomeAdminViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import SwiftKeychainWrapper
import NYAlertViewController
import PhoneNumberKit
import SCLAlertView
import FirebaseStorage
import FirebaseAuth

class WelcomeAdminViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var forgotPass: UIButton!
    @IBOutlet weak var sponsorDescription: UITextView!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var outerInputView: UIView!
    @IBOutlet weak var innerInputView: UIView!
    @IBOutlet weak var goldenLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapDismiss()
        self.implementGestures()
        self.designInputViews(outer: self.outerInputView, inner: self.innerInputView, main: self.view)
        self.goldenLogo.layer.cornerRadius = self.goldenLogo.frame.height/2
        self.goldenLogo.layer.masksToBounds = false
        self.login.layer.cornerRadius = 10.0
        self.login.layer.masksToBounds = true
        self.login.backgroundColor = LoginColors.login_button.generateColor()
        self.login.setAttributedTitle(LoginStrings.login_text.generateString(text: "Admin Login!"), for: [])
        self.signup.layer.cornerRadius = 10.0
        self.signup.layer.masksToBounds = true
        self.signup.backgroundColor = LoginColors.signup_button.generateColor()
        self.signup.setAttributedTitle(LoginStrings.signup_text.generateString(text: "Become a Nomination Sponsor!"), for: [])
        self.forgotPass.setAttributedTitle(LoginStrings.forgot_password.generateString(text: "Forgot Password?"), for: [])
        self.forgotPass.backgroundColor = LoginColors.forgot_password.generateColor()
        self.email.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Email")
        self.email.backgroundColor = LoginColors.text_field.generateColor()
        self.email.borderStyle = .none
        self.email.textColor = Colors.app_text.generateColor()
        
        self.password.attributedPlaceholder = LoginStrings.welcome_password.generateString(text: "Password")
        self.password.backgroundColor = LoginColors.text_field.generateColor()
        self.password.borderStyle = .none
        self.password.textColor = Colors.app_text.generateColor()
        self.sponsorDescription.layer.cornerRadius = 5.0
        self.sponsorDescription.layer.borderColor = Colors.app_text.generateColor().cgColor
        self.sponsorDescription.layer.borderWidth = 1.0
        self.sponsorDescription.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Gesture Recognizer Delegate
    func implementGestures() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .down
        leftGesture.direction = .left
        rightGesture.direction = .right
        self.innerInputView.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        self.outerInputView.isUserInteractionEnabled = true
        self.innerInputView.addGestureRecognizer(gesture)
        self.outerInputView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(leftGesture)
        self.view.addGestureRecognizer(rightGesture)
        self.outerInputView.addGestureRecognizer(leftGesture)
        self.outerInputView.addGestureRecognizer(rightGesture)
        self.innerInputView.addGestureRecognizer(leftGesture)
        self.innerInputView.addGestureRecognizer(rightGesture)
    }
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.dismiss(animated: false, completion: nil)
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                self.dismiss(animated: false, completion: nil)
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
        
    }
    // MARK: - UI Actions
    
    @IBAction func loginDidTap(_ sender: Any) {
        guard self.email.text != "" else {
            self.goldenAlert(title: "Error", message: "Please enter your email or phone number", view: self)
            return
        }
        //self.phoneTextField.text = self.email.text
        if RegexChecker.email(text: self.email.text!).check() {
            guard self.password.text != "" else {
                self.goldenAlert(title: "Error", message: "Please enter your password", view: self)
                return
            }
            let password = self.password.text!
            let email = self.email.text!
            
            Authorize.instance.completeSignUp(email: email, password: password, view: self) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                guard Auth.auth().currentUser != nil else {
                    return
                }
                self.loadCurrentUser() { (currentUser, error) in
                    guard error == nil && currentUser != nil else {
                        print("Hey error loading current user")
                        return
                    }
                    
                    if currentUser?.admin == true {
                        print("Loged in user is admin user.")
                        appDelegate.isAdminLoggedIn = true
                        KeychainWrapper.standard.set(true, forKey: Keys.isAdminLogin.key)
                        self.dismiss(animated: true, completion: nil)
                        
                    }else{
                        do {
                            self.goldenAlert(title: "Admin Login Error", message: "Your account is verifyed as Admin!", view: self)
                            try Auth.auth().signOut()
                            appDelegate.isAdminLoggedIn = false
                            KeychainWrapper.standard.set(false, forKey: Keys.isAdminLogin.key)
                        } catch (let error) {
                            print("Auth sign out failed: \(error)")
                        }
                    }
                }
                
            }
        }
    }
    
    
    // MARK: - Load Current Person
    func loadCurrentUser(completion: @escaping (Person?, String?) -> Void) {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            self.loadPerson(uid: uid, completion: { (person, error) in
                completion(person, error)
            })
            
        } else {
            //sud
            //self.createAnonymousUser()
        }
    }
    func loadPerson(uid: String, completion: @escaping (Person?, String?) -> Void) {
        Person.loadCurrentPerson(uid: uid) { (error, current) in
            guard error == nil && current != nil else {
                completion(current, error)
                return
            }
            
            completion(current, error)
        }
    }
    @IBAction func forgotPassDidTap(_ sender: Any) {
    }
    
    
    @IBAction func signupDidTap(_ sender: Any) {
    }
    
    
    
    
   
}
