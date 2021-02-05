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
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit



class SignInEmailViewController: UIViewController{
    
    // MARK: - Outlet Declaration
    var dict : [String : AnyObject]!

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signUpView: UIView!
    
    
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var passwordLine: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
   // @IBOutlet weak var nominationSponsorButton: UIButton!
    
    var activityView:DGActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.designMainView()
        self.designTextField()
        self.designScreen()
        let keyboardDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        self.view.addGestureRecognizer(keyboardDismiss)

    }
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.colorButtons()
    }
    
    
    func designMainView(){
        self.view.backgroundColor = Constants.background
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
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
        self.emailTextField.setBottomBorder()
        self.emailTextField.delegate = self
        self.emailTextField.returnKeyType = .default
        self.emailTextField.keyboardType = .emailAddress
        
        self.passwordTextField.attributedPlaceholder = NSMutableAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.passwordTextField.backgroundColor = .black
        self.passwordTextField.borderStyle = .none
        self.passwordTextField.textColor = Constants.loginFontColor
        self.passwordTextField.setBottomBorder()
        self.passwordTextField.delegate = self
        self.passwordTextField.returnKeyType = .default

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorButtons()
    }

    func designButton() {

        self.loginButton.layer.cornerRadius  = 10.0
        self.loginButton.layer.masksToBounds = true
        self.loginButton.setAttributedTitle(LoginStrings.login_text.generateString(text: "Let's Go!"), for: [])
        self.loginButton.addTarget(self, action: #selector(loginUser(_:)), for: .touchUpInside)
        
//        self.nominationSponsorButton.addTarget(self, action: #selector(segueSignup(_:)), for: .touchUpInside)
//        self.nominationSponsorButton.layer.cornerRadius = 10.0
//        self.nominationSponsorButton.layer.masksToBounds = true
//        self.nominationSponsorButton.backgroundColor = .clear
//        self.nominationSponsorButton.setAttributedTitle(LoginStrings.signup_text.generateString(text: "Become a Nomination Sponsor!"), for: [])
//        self.nominationSponsorButton.layer.borderWidth = 2.0
        
        self.facebookButton.layer.cornerRadius = 10.0
        self.facebookButton.layer.masksToBounds = true
        self.facebookButton.layer.borderWidth = 2.0
        self.facebookButton.layer.borderColor = UIColor.clear.cgColor
        self.facebookButton.addTarget(self, action: #selector(facebookLoginMethod(_:)), for: .touchUpInside)


    }
    
    func colorButtons(){
        let imageColor = self.gradient(size: self.loginButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.loginButton.backgroundColor     = UIColor.init(patternImage: imageColor!)
        
//        let imageColor1 = self.gradient(size: self.nominationSponsorButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
//        self.nominationSponsorButton.layer.borderColor = UIColor.init(patternImage: imageColor1!).cgColor
    }
    
    func designExtra() {
        self.forgotPasswordButton.setAttributedTitle(LoginStrings.forgot_password.generateString(text: "Forgot Password?"), for: [])
        self.forgotPasswordButton.backgroundColor = LoginColors.forgot_password.generateColor()
    }
    
    @IBAction func btnActionOnForgotPassword(_ sender: UIButton)
    {
        ProfilePopup.instance.forgotPassword(view:self , email: "")
    }
    
    
    @objc func loginUser(_ sender: UIButton) {
        guard self.emailTextField.text != "" else {
            self.goldenAlert(title: "Error", message: "Please enter your email or phone number", view: self)
            return
        }
        if RegexChecker.email(text: self.emailTextField.text!).check() {
            guard self.passwordTextField.text != "" else {
                self.goldenAlert(title: "Error", message: "Please enter your password", view: self)
                return
            }
            let password = self.passwordTextField.text!
            let email = self.emailTextField.text!
           // self.activityView.startAnimating()
            Authorize.instance.completeSignUp(email: email, password: password, view: self) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    //self.activityView.stopAnimating()
                    return
                }
               // self.activityView.stopAnimating()
                NotificationHelper.instance.saveForLoggedUser()
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    
    @objc func sponsorDidTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: SegueId.welcome_sponsorinfo.id, sender: self)
    }
    
    
//    @objc func segueSignup(_ sender: UIButton) {
//        self.performSegue(withIdentifier: SegueId.welcome_signupEmail.id, sender: self)
//    }
    
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

extension SignInEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
            self.loginUser(self.loginButton)
        }
        return true
    }
}

extension SignInEmailViewController{
    
   /* func gradient(size:CGSize,color:[UIColor]) -> UIImage?{
        //turn color into cgcolor
        let colors = color.map{$0.cgColor}
        //begin graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        // From now on, the context gets ended if any return happens
        defer {UIGraphicsEndImageContext()}
        //create core graphics context
        let locations:[CGFloat] = [0.0,1.0]
        guard let gredient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as NSArray as CFArray, locations: locations) else {
            return nil
        }
        
        //draw the gradient
        context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width ,y:size.height), options: [.drawsAfterEndLocation,.drawsBeforeStartLocation])
        
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    } */
    
}

extension SignInEmailViewController {
    
    @objc func facebookLoginMethod(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                NotificationHelper.instance.saveForLoggedUser()
                self.dismiss(animated: true, completion: nil)

                
            })
            
        }
       
    }
    
//    func getFBUserData(){
//        if((FBSDKAccessToken.current()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! [String : AnyObject]
//                    print(result!)
//                    print(self.dict)
//                }
//            })
//        }
//    }
    
    
}
