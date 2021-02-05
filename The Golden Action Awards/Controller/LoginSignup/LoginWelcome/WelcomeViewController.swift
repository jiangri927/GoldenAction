//
//  WelcomeViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
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
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class WelcomeViewController: UIViewController {
    
    // MARK: - Outlet Declaration
    @IBOutlet weak var segmentController : UISegmentedControl!
    
    @IBOutlet weak var loginSignupButtonView:UIView!
    @IBOutlet weak var loginOptionButton:UIView!
    @IBOutlet weak var signupOptionButton:UIView!

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signUpView: UIView!
    
    @IBOutlet weak var titleLbl : UILabel!
    
    
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var passwordLine: UIView!
    
    @IBOutlet weak var goldenLogo: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var notRegisteredLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nominationSponsorButton: UIButton!
    
    var activityView:DGActivityIndicatorView!
    
    var googleEmailHolder: String!
    var googleFirstName: String!
    var googleLastName: String!
    var googleCredHolder: AuthCredential!
    var phoneNumber: String!
    var phoneCredential: AuthCredential!
    
    var phoneTextField = PhoneNumberTextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationDefaultColor()
        appDelegate.isAdminLoggedIn = false
        self.view.backgroundColor = Constants.background
       // self.designSegmentButton()

        let image1 = self.gradient(size: self.titleLbl.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.titleLbl.textColor = UIColor.init(patternImage: image1)
        
        self.setupSegmentedControl()
        let keyboardDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        self.view.addGestureRecognizer(keyboardDismiss)
        
        let image2 = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.segmentController.layer.borderColor = UIColor.init(patternImage: image2).cgColor
        
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .selected)
        self.updateGradientBackground()

    }
    
    override func viewWillAppear(_ animated: Bool) {
       // self.selectionDidChange(self.segmentController)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        let segmentFrame = self.segmentController.frame
        //        let rect = CGRect(origin: self.segmentController.frame.origin, size: CGSize(width: self.segmentController.frame.size.width, height: 50))
        //        self.segmentController.frame = rect
        
        let image2 = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.segmentController.layer.borderColor = UIColor.init(patternImage: image2).cgColor
        
        // self.loginButton.backgroundColor = LoginColors.login_button.generateColor()
        
    }
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        self.segmentController.removeAllSegments()
        self.segmentController.insertSegment(withTitle: "Login", at: 0, animated: false)
        self.segmentController.insertSegment(withTitle: "Sign up", at: 1, animated: false)
        self.segmentController.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        self.segmentController.layer.borderWidth = 2
        self.segmentController.layer.masksToBounds = true
        self.segmentController.layer.cornerRadius = 8
        self.segmentController.selectedSegmentIndex = 0

    }
    
    
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        self.updateGradientBackground()
        if sender.selectedSegmentIndex == 0 {
            self.loginView.isHidden  = true
            self.signUpView.isHidden = false
            self.titleLbl.text = "Login"
            
        }else{
            self.signUpView.isHidden = true
            self.loginView.isHidden  = false
            self.titleLbl.text = "Signup"
        }
    }
    
    func designSegmentButton(){
        
        let image = self.gradient(size: self.loginSignupButtonView.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.loginSignupButtonView.layer.borderColor = UIColor.init(patternImage: image).cgColor
        self.loginSignupButtonView.layer.borderWidth = 2.0
        self.loginSignupButtonView.backgroundColor = .clear
        self.loginSignupButtonView.layer.cornerRadius = 10
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.loginOptionButton.frame
        rectShape.position = self.loginOptionButton.center
        rectShape.path = UIBezierPath(roundedRect: self.loginOptionButton.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.loginOptionButton.layer.mask = rectShape
        
        let loginGesture = UITapGestureRecognizer(target: self, action: #selector(loginGestureClicked(recognizer:)))
        self.loginOptionButton.addGestureRecognizer(loginGesture)
    
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = self.signupOptionButton.frame
        rectShape1.position = self.signupOptionButton.center
        rectShape1.path = UIBezierPath(roundedRect: self.signupOptionButton.bounds, byRoundingCorners: [.bottomRight , .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.signupOptionButton.layer.mask = rectShape1
        
        let signupGesture = UITapGestureRecognizer(target: self, action: #selector(signupGestureClicked(recognizer:)))
        self.loginOptionButton.addGestureRecognizer(signupGesture)

    }
    
    @objc func loginGestureClicked(recognizer: UITapGestureRecognizer) {
        let image = self.gradient(size: self.loginOptionButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.loginOptionButton.backgroundColor = UIColor.init(patternImage: image)
        self.signupOptionButton.backgroundColor = .clear
        self.signUpView.isHidden = true
        self.loginView.isHidden  = false
        self.titleLbl.text = "Login"
    }
    
    @objc func signupGestureClicked(recognizer: UITapGestureRecognizer) {
        let image = self.gradient(size: self.loginOptionButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.loginOptionButton.backgroundColor = .clear
        self.signupOptionButton.backgroundColor = UIColor.init(patternImage: image)
        self.loginView.isHidden  = true
        self.signUpView.isHidden = false
        self.titleLbl.text = "Sign Up"
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        //self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
    }
    
    func designScreen(){
        self.designLogo()
        self.designButton()
        self.designTextField()
        self.implementGestures()
        self.googleButtonActions()
    }
    
    func designTextField() {
        self.emailTextField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Email")
        self.emailTextField.backgroundColor = LoginColors.text_field.generateColor()
        self.emailTextField.borderStyle = .none
        self.emailTextField.textColor = Colors.app_text.generateColor()
        
        self.passwordTextField.attributedPlaceholder = LoginStrings.welcome_password.generateString(text: "Password")
        self.passwordTextField.backgroundColor = LoginColors.text_field.generateColor()
        self.passwordTextField.borderStyle = .none
        self.passwordTextField.textColor = Colors.app_text.generateColor()
    }
    
    func designLogo() {
        self.goldenLogo.image = UIImage(named: "headLogo")!
        self.goldenLogo.contentMode = UIViewContentMode.scaleAspectFill
        self.goldenLogo.layer.masksToBounds = false
        self.goldenLogo.layer.cornerRadius = self.goldenLogo.frame.height/2
    }
    
    func designButton() {
        self.loginButton.layer.cornerRadius = 10.0
        self.loginButton.layer.masksToBounds = true
        self.loginButton.backgroundColor = LoginColors.login_button.generateColor()
        self.loginButton.setAttributedTitle(LoginStrings.login_text.generateString(text: "Let's Go!"), for: [])
        self.loginButton.addTarget(self, action: #selector(loginUser(_:)), for: .touchUpInside)
        self.nominationSponsorButton.addTarget(self, action: #selector(segueSignup(_:)), for: .touchUpInside)
        self.nominationSponsorButton.layer.cornerRadius = 10.0
        self.nominationSponsorButton.layer.masksToBounds = true
        self.nominationSponsorButton.backgroundColor = LoginColors.signup_button.generateColor()
        self.nominationSponsorButton.setAttributedTitle(LoginStrings.signup_text.generateString(text: "Become a Nomination Sponsor!"), for: [])
        self.signupButton.layer.cornerRadius = 10.0
        self.signupButton.layer.masksToBounds = true
        self.signupButton.backgroundColor = LoginColors.signup_button.generateColor()
        self.signupButton.setAttributedTitle(LoginStrings.signup_text.generateString(text: "Sign Up!"), for: [])
        self.signupButton.addTarget(self, action: #selector(segueSignup(_:)), for: .touchUpInside)
    }
    
    func designExtra() {
        self.forgotPasswordButton.setAttributedTitle(LoginStrings.forgot_password.generateString(text: "Forgot Password?"), for: [])
        self.forgotPasswordButton.backgroundColor = LoginColors.forgot_password.generateColor()
        self.notRegisteredLabel.attributedText = LoginStrings.not_registered.generateString(text: "Not Registered?")
    }
    
    @objc func loginUser(_ sender: UIButton) {
        guard self.emailTextField.text != "" else {
            self.goldenAlert(title: "Error", message: "Please enter your email or phone number", view: self)
            return
        }
        self.phoneTextField.text = self.emailTextField.text
        if RegexChecker.email(text: self.emailTextField.text!).check() {
            guard self.passwordTextField.text != "" else {
                self.goldenAlert(title: "Error", message: "Please enter your password", view: self)
                return
            }
            let password = self.passwordTextField.text!
            let email = self.emailTextField.text!
            self.activityView.startAnimating()
            Authorize.instance.completeSignUp(email: email, password: password, view: self) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    self.activityView.stopAnimating()
                    return
                }
                //updating uuid value for logged user with firebase message notification
                self.activityView.stopAnimating()
                NotificationHelper.instance.saveForLoggedUser()
                self.dismiss(animated: true, completion: nil)
                
            }
        } else if self.phoneTextField.isValidNumber {
            if let verifID = KeychainWrapper.standard.string(forKey: Keys.phone_id(number: self.phoneTextField.text!).key) {
                PhoneAuthProvider.provider().verifyPhoneNumber("+1\(self.phoneTextField.text!)", uiDelegate: nil) { (verificationID, error) in
                    guard error == nil else {
                        self.goldenAlert(title: "Error", message: "There was an error authing the phone, please try again", view: self)
                        print(error!.localizedDescription)
                        return
                    }
                    print(verifID)
                    self.passwordTextField.attributedPlaceholder = LoginStrings.welcome_password.generateString(text: "Enter verification code here")
                    self.loginButton.setAttributedTitle(LoginStrings.login_text.generateString(text: "Auth Phone!"), for: [])
                }
            } else {
                self.goldenAlert(title: "Phone Number not associated with an account", message: "Please press the phone button below and sign up with a phone number", view: self)
            }
        } else {
            self.goldenAlert(title: "Error", message: "Please enter a valid email or phone number", view: self)
        }
    }
    
    @objc func sponsorDidTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: SegueId.welcome_sponsorinfo.id, sender: self)
    }
    
    @objc func segueSignup(_ sender: UIButton) {
        self.performSegue(withIdentifier: SegueId.welcome_signupEmail.id, sender: self)
    }
    
    @objc func phoneDidTap(_ sender: UIButton) {
        let phoneView = PhoneView(welcomeVC: self)
        print("Phone pressed")
        phoneView.createPhone(verification: false, phoneID: "", phoneNumber: "")
    }
    
    // MARK: - Gesture Recognizer Delegate
    func implementGestures() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .down
        //self.innerInputView.addGestureRecognizer(gesture)
        //self.outerInputView.addGestureRecognizer(gesture)
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
        } else
            if segue.identifier == SegueId.signupPhone_signupDetail.id {
            guard self.phoneCredential != nil || self.phoneNumber != nil else {
                self.goldenAlert(title: "There was an error processing you phone number", message: "Please try again", view: self)
                return
            }
            let destinationVC = segue.destination as! SignupDetailViewController
            destinationVC.acctType = AcctType.phone.type
            destinationVC.credentialPhone = self.phoneCredential
            destinationVC.phoneNumber = self.phoneNumber
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
extension WelcomeViewController: GIDSignInUIDelegate {
    // MARK: - Facebook and Google Sign In Actions & Design
    func googleButtonActions() {
        self.googleButton.addTarget(self, action: #selector(googleSignInTapped(_:)), for: .touchUpInside)
    }
    @objc func googleSignInTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        
    }
    func monitorGoogleSignInCreation(completion: @escaping (Bool) -> Void) {
        let googleKey = Keys.google_creation.key
        if let creation = KeychainWrapper.standard.bool(forKey: googleKey) {
            guard creation else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("--------->")
        print(user.description)
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        self.googleEmailHolder = user.profile.email
        self.googleCredHolder  = credential
        self.googleFirstName   = user.profile.givenName
        self.googleLastName    = user.profile.familyName
        print(credential)
        self.monitorGoogleSignInCreation { (created) in
            if !created {
                self.performSegue(withIdentifier: SegueId.signupGoogle_signupDetail.id, sender: self)
            } else {
                Authorize.instance.signGoogleAccountIn(credential: credential, view: self, completion: { (error) in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
       // self.performSegue(withIdentifier: SegueId.signupGoogle_signupDetail.id, sender: self)
    }

    

}
extension WelcomeViewController: UITextFieldDelegate {
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
extension UIViewController {
    
    func goldenAlert(title: String, message: String, view: UIViewController) {
        // Set a title and message
        // Customize appearance as desired
        let workItem = DispatchWorkItem {
            
            var alertview = JSSAlertView().show(
                view,
                title: title,
                text: message,
                buttonText: "OK"
            )
            //let app_color = Colors.app_text.generateColor()

      /*      let alertVC = NYAlertViewController()
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
            
            alertVC.title              = title
            alertVC.message            = message
            alertVC.buttonCornerRadius = 20.0
            
            // Actions
            alertVC.swipeDismissalGestureEnabled = true
            alertVC.backgroundTapDismissalGestureEnabled = true
            
           /* let okayAction = NYAlertAction(title: "Okay", style: .default) { (_) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okayAction) */
            let cancelAction = NYAlertAction(
                title: "Okey",
                style: .cancel,
                handler: { (action: NYAlertAction!) -> Void in
                    alertVC.dismiss(animated: true, completion: nil)
            }
            )
            
            alertVC.addAction(cancelAction)
            view.present(alertVC, animated: true, completion: nil) */
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: workItem)
    }

    func goldenCustomActions(vc: UIViewController, title: String, message: String, buttonOneTitle: String, buttonTwoTitle: String?, buttonOneAction: DispatchWorkItem, buttonTwoAction: DispatchWorkItem?, buttonThreeAction: DispatchWorkItem?, buttonThreeTitle: String?, twoAction: Bool, threeAction: Bool) -> NYAlertViewController {
        // Set a title and message
        // Customize appearance as desired
        let alertVC = NYAlertViewController()
        self.designAlertView(alertVC: alertVC)
        alertVC.title = title
        alertVC.message = message
        if twoAction {
            if threeAction {
                let leftAction = NYAlertAction(title: buttonOneTitle, style: .default) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: buttonOneAction)
                }
                let middleAction = NYAlertAction(title: buttonTwoTitle!, style: .default) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: buttonTwoAction!)
                }
                let rightAction = NYAlertAction(title: buttonThreeTitle!, style: .default) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: buttonThreeAction!)
                }
                alertVC.addAction(leftAction)
                alertVC.addAction(middleAction)
                alertVC.addAction(rightAction)
            } else {
                let leftAction = NYAlertAction(title: buttonOneTitle, style: .default) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: buttonOneAction)
                }
                let rightAction = NYAlertAction(title: buttonTwoTitle!, style: .default) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: buttonTwoAction!)
                }
                alertVC.addAction(leftAction)
                alertVC.addAction(rightAction)
            }
        } else {
            let action = NYAlertAction(title: buttonOneTitle, style: .default) { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: buttonOneAction)
            }
            alertVC.addAction(action)
        }
        return alertVC
    }
    func goldenCustomActionAlert(title: String, message: String, leftButtonTitle: String, rightButtonTitle: String, leftButtonAction: Selector, rightButtonAction: Selector, placeholder: String) -> NYAlertViewController {
        // Set a title and message
        // Customize appearance as desired
        let alertVC = NYAlertViewController()
        alertVC.title = title
        alertVC.message = message
        self.designAlertView(alertVC: alertVC)
        
        let leftAction = NYAlertAction(title: leftButtonTitle, style: .default) { (_) in
            self.perform(leftButtonAction)
        }
        let rightAction = NYAlertAction(title: rightButtonTitle, style: .default) { (_) in
            self.perform(rightButtonAction)
        }
        alertVC.addAction(leftAction)
        alertVC.addAction(rightAction)
        return alertVC
    }
    func designAlertView(alertVC: NYAlertViewController) {
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
        
        
        alertVC.buttonCornerRadius = 20.0
        
        
        
        // Actions
        alertVC.swipeDismissalGestureEnabled = true
        alertVC.backgroundTapDismissalGestureEnabled = true
    }
    
    func designInputViews(outer: UIView, inner: UIView, main: UIView) {
        // Inherited
        //main.backgroundColor = Colors.nom_detail_firstBackground.generateColor()
        // Outer
        outer.backgroundColor = Colors.nom_detail_outerBackground.generateColor()
        outer.layer.cornerRadius = 15.0
        outer.layer.masksToBounds = true
        // Inner
        inner.backgroundColor = Colors.nom_detail_innerBackground.generateColor()
        inner.layer.borderColor = Colors.nom_detail_innerBorder.generateColor().cgColor
        inner.layer.borderWidth = 1.0
        inner.layer.cornerRadius = 15.0
        inner.layer.masksToBounds = true
        
    }
    
    func setNavigationDefaultColor(){
        let colorImage = self.gradient(size: (self.navigationController?.navigationBar.frame.size)!, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.navigationController?.navigationBar.barTintColor = UIColor.init(patternImage: colorImage!)
    }
}

extension WelcomeViewController{
    
/*    func gradient(size:CGSize,color:[UIColor]) -> UIImage?{
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
        context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width,y:size.height), options: [])
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    */
    fileprivate func updateGradientBackground() {
        let image = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!

        let sortedViews = self.segmentController.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        for (index, view) in sortedViews.enumerated() {
            if index == self.segmentController.selectedSegmentIndex {
                //very important thing to notice here is because tint color was not honoring the `UIColor(patternImage` I rather used `backgroundColor` to create the effect and set clear color as clear color
                view.backgroundColor = UIColor(patternImage: image)
                view.tintColor = UIColor.clear
            } else {
                //very important thing to notice here is because tint color was not honoring the `UIColor(patternImage` I rather used `backgroundColor` to create the effect and set clear color as clear color
                view.backgroundColor = .clear //Whatever the color of non selected segment controller tab
                //view.tintColor = UIColor.whi
            }
        }
    }
    
}
