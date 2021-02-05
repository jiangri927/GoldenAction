//
//  SCLCustomFactory.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/10/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SCLAlertView
import Firebase
import Alamofire
import PhoneNumberKit
import Bond
import StoreKit
import SearchTextField
import Toucan
import SwiftKeychainWrapper
import ImagePicker
import CropViewController
import MobileCoreServices
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging




enum AlertTypeScreen {
    case checkout_screen
    
    case phone_auth
    case feedback_screen
    case rate_screen
    case delete_screen
    
    case any_error
    var id: Int {
        switch self {
        case .checkout_screen:
            return 0
        case .phone_auth:
            return 1
        case .feedback_screen:
            return 2
        case .rate_screen:
            return 3
        case .delete_screen:
            return 4
        case .any_error:
            return 5
        }
    }
}
extension UIViewController {
    
    func checkVerification(currentUser: Person, message: String, workitem: DispatchWorkItem) {
        guard currentUser.acctType != AcctType.anonymous.type else {
            let setup = SCLCustomFactory(everyVC: self, title: "Create Account", message: message, currentUser: currentUser, doneButton: workitem)
            setup.setupEnumeratedView(alerttypescreen: AlertTypeScreen.phone_auth.id)
            return
        }
    }
    
    func checkNominations(currentUser: Person, messages: String, workitem: DispatchWorkItem) {
        guard currentUser.purchasedNoms != 0 else {
            /*if nomData != nil && currentCreatePage != nil {
                let pageRef = DBRef.create_nom_segue_page(uid: currentUser.uid).reference()
                let dataRef = DBRef.create_nom_segue_data(uid: currentUser.uid).reference()
                pageRef.setValue(currentCreatePage!)
                dataRef.setValue(nomData!)
            } */
            let setup = SCLCustomFactory(everyVC: self, title: "Purchase Nominations", message: messages, currentUser: currentUser, doneButton: workitem)
            setup.setupEnumeratedView(alerttypescreen: AlertTypeScreen.checkout_screen.id)
            return
        }
    }
    
    func showFeedback(currentUser: Person, workItem: DispatchWorkItem) {
        let setup = SCLCustomFactory(everyVC: self, title: "Give Feedback", message: "Please enter feedback below", currentUser: currentUser, doneButton: workItem)
        setup.setupEnumeratedView(alerttypescreen: AlertTypeScreen.feedback_screen.id)
    }
    
    func showRate(currentUser: Person, workItem: DispatchWorkItem) {
        let setup = SCLCustomFactory(everyVC: self, title: "Rate App!", message: "Press Below to Rate App", currentUser: currentUser, doneButton: workItem)
        setup.setupEnumeratedView(alerttypescreen: AlertTypeScreen.rate_screen.id)
    }
    
    func showDelete(currentUser: Person, workItem: DispatchWorkItem) {
        let setup = SCLCustomFactory(everyVC: self, title: "Logout", message: "", currentUser: currentUser, doneButton: workItem)
        setup.setupEnumeratedView(alerttypescreen: AlertTypeScreen.delete_screen.id)
    }
    
    func error(title: String?, message: String?, error: Error?) {
        let setup = SCLCustomFactory(errorVC: self, title: title, message: message, error: error)
        setup.setupEnumeratedView(alerttypescreen: AlertTypeScreen.any_error.id)
    }

    
}
class SCLCustomFactory {
    
    var description: String!
    
    
    let que = ThreadFactory.ui_userInteract.generate(priority: -6)
    var vc: UIViewController
    var animationStyle: SCLAnimationStyle
    var customImage: UIImage!
    var title: String!
    var message: String!
    var progress: LinearProgress!
    let phoneVerif = UIImage(named: "phone-verif")!
    var currentUser: Person!
    var doneWorkItem: DispatchWorkItem!
    // String being monitored in view
    var phoneText: String?
    var error: Error?
    
    var locationHolder: SearchTextFieldItem!
    var locationButton: SCLButton!
    var first: UITextField!
    var last: UITextField!
    var email: UITextField!
    var profPic: UIImageView!
    var profImg: UIImage!
    var imgPick: GoldenImagePicker!
    let picPlaceholder = StaticPictures.picture_selection.generatePic()
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "none"
    let phoneApperance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: false, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
    let errorAppearance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: true, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
    init(vc: UIViewController, animationStyle: SCLAnimationStyle, customImage: UIImage!, title: String!, message: String!) {
        self.vc = vc
        self.animationStyle = animationStyle
        self.customImage = customImage
        self.title = title
        self.message = message
        self.progress = LinearProgress(height: 15, width: self.vc.view.frame.width)
    }
    init(authVC: UIViewController, message: String!) {
        self.vc = authVC
        self.title = "Phone Authorization"
        self.message = message
        self.animationStyle = .noAnimation
        self.customImage = self.phoneVerif
        self.progress = LinearProgress(height: 15, width: self.vc.view.frame.width)
    }
    
    init(everyVC: UIViewController, title: String, message: String, currentUser: Person!, doneButton: DispatchWorkItem) {
        self.vc = everyVC
        self.title = title
        self.message = message
        self.animationStyle = .noAnimation
        self.customImage = nil
        self.currentUser = currentUser
        self.doneWorkItem = doneButton
        self.progress = LinearProgress(height: 15, width: self.vc.view.frame.width)
        
    }
    
    
    init(errorVC: UIViewController, title: String?, message: String?, error: Error?) {
        self.vc = errorVC
        self.title = title
        self.message = message
        self.error = error
        self.customImage = nil
        self.animationStyle = .topToBottom
        self.progress = LinearProgress(height: 15, width: self.vc.view.frame.width)
    }
    // MARK: - Start Segue for iOS In App Purchases --> Uses Enum for Switch statement
    func setupEnumeratedView(alerttypescreen: Int) {
        switch alerttypescreen {
        case AlertTypeScreen.checkout_screen.id:
            let alert = self.designCheckoutView()
            alert.showNotice(self.title, subTitle: self.message ?? "")
        case AlertTypeScreen.phone_auth.id:
            let alert = self.designPhoneAuth()
            alert.showNotice(self.title, subTitle: self.message ?? "")
        case AlertTypeScreen.rate_screen.id:
            let alert = self.designRateApp()
            alert.showNotice(self.title, subTitle: self.message ?? "")
        case AlertTypeScreen.feedback_screen.id:
            let alert = self.designFeedback()
            alert.showNotice(self.title, subTitle: self.message ?? "")
        case AlertTypeScreen.delete_screen.id:
            let alert = self.designDeleteAccount()
            alert.showNotice(self.title, subTitle: self.message ?? "")
        case AlertTypeScreen.any_error.id:
            self.handleAnyError(title: self.title, message: self.message ?? "", error: self.error, view: self.vc)
        default:
            print("Error View Controller Alert SCL")
        }
    }
    
    
    
    // MARK: - USED Phone Auth
    func designPhoneAuth() -> SCLAlertView {
        
        let alert = SCLAlertView(appearance: phoneApperance)
        let phoneField = alert.addTextField("Enter Phone Number with Area Code")
        phoneField.keyboardType = .phonePad
        phoneField.becomeFirstResponder()
        phoneField.reactive.text.observeNext { (text) in
            if text?.count == 10 {
                phoneField.isEnabled = false
                self.phoneText = text!
                self.progress.startAnimation()
                let workItem = DispatchWorkItem {
                    PhoneAuthProvider.provider().verifyPhoneNumber("+1\(text!)", uiDelegate: nil, completion: { (verifId, error) in
                        self.progress.stopAnimation()
                        if error != nil {
                            let err = error! as NSError
                            self.displayError(oldAlert: alert, error: err)
                            //self.vc.dismiss(animated: true, completion: nil)
                            //self.handleAlert(error: err, view: self.vc)
                            phoneField.isEnabled = true
                            phoneField.text = ""
                        } else {
                            alert.hideView()
                            self.designVerificationAuth(verification: verifId!)
                        }
                    })
                }
                DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now(), execute: workItem)
                /*self.runPhoneAuth(pipedPhone: "+1\(text!)", completion: { (verification, error) in
                    self.progress.stopAnimation()
                    guard error == nil else {
                        let err = error! as NSError
                        self.vc.dismiss(animated: true, completion: nil)
                        self.handleAlert(error: err, view: self.vc)
                        phoneField.isEnabled = true
                        phoneField.text = ""
                        return
                    }
                    alert.dismiss(animated: true, completion: nil)
                    let workItem = DispatchWorkItem {
                        self.designVerificationAuth(verification: verification ?? "")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: workItem)
                    
                }) */
            }
        }
        self.addBackButton(alert: alert)
        
        return alert
    }
    
    func getCode(phonePipe: String) {
        
    }
    
    func designVerificationAuth(verification: String) {
        let alert = SCLAlertView(appearance: phoneApperance)
        let codeField = alert.addTextField("Enter Verification Code")
        codeField.keyboardType = .numberPad
        codeField.becomeFirstResponder()
        codeField.reactive.text.observeNext { (text) in
            if text?.count == 6 {
                self.progress.startAnimation()
                codeField.isEnabled = false
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verification, verificationCode: text!)
                Auth.auth().currentUser?.link(with: credential, completion: { (authuser, error) in
                    self.progress.stopAnimation()
                    if error != nil {
                        let err = error! as NSError
                        self.displayError(oldAlert: alert, error: err)
                    } else {
                        alert.hideView()
                        self.designProfileCreationAlert(user: authuser!, phone: self.phoneText!)
                    }
                })
            }
        }
        self.addBackButton(alert: alert)
        alert.showInfo("Enter Code", subTitle: "If you get two verification codes, please enter the most recent one recieved. Thanks!")
    }
    
    // MARK: - Code Verification Account Creation
    func designProfileCreationAlert(user: User, phone: String) {
        
        let alert = SCLAlertView(appearance: phoneApperance)
        self.first = alert.addTextField("Enter first name")
        self.last = alert.addTextField("Enter last name")
        self.email = alert.addTextField("Enter email")
        self.first.becomeFirstResponder()
        // self.first.delegate = self
        self.first.keyboardType = .namePhonePad
        self.last.keyboardType = .namePhonePad
        self.email.keyboardType = .emailAddress
        // self.last.delegate = self
        // self.email.delegate = self
        alert.addButton("Next", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            guard self.first.text != "" else {
                self.first.attributedPlaceholder = LoginStrings.error_text.generateString(text: "Please enter First Name!")
                return
            }
            guard self.last.text != "" else {
                self.last.attributedPlaceholder = LoginStrings.error_text.generateString(text: "Please enter Last Name!")
                return
            }
            guard self.email.text != "" else {
                self.email.attributedPlaceholder = LoginStrings.error_text.generateString(text: "Please enter Email!")
                return
            }
            guard RegexChecker.email(text: self.email.text!).check() else {
                self.email.text = nil
                self.email.attributedPlaceholder = LoginStrings.error_text.generateString(text: "Please enter a valid email")
                return
            }
            // alert.resignFirstResponder()
            alert.hideView()
            self.designLocationCreation(authuser: user, phone: phone, first: self.first.text!, last: self.last.text!, email: self.email.text!)
        }
        self.addBackButton(alert: alert)
        alert.showInfo("Add General Profile Information", subTitle: "")
    }
    
    /* func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.first {
            self.last.becomeFirstResponder()
        } else if textField == self.last {
            self.email.becomeFirstResponder()
        } else if textField == self.email {
            self.email.resignFirstResponder()
        }
        return true
    } */
    // MARK: - Location Account Creation
    func designLocationCreation(authuser: User, phone: String, first: String, last: String, email: String) {
        
        let alert = SCLAlertView(appearance: phoneApperance)
        let location = alert.addTextField("Enter your City, State")
        location.keyboardType = .default
        location.reactive.text.observeNext { (text) in
            guard text != nil else {
                return
            }
            if text!.count >= 3 {
                SearchFirebaseDB.instance.loadCityQuery(query: text){(searches) in
                    guard searches != nil else {
                        return
                    }
                    let relevant = searches![0]
//                    let relevant = SearchTextFieldItem.init(title: "Berryville", subtitle: "AR")
//                    relevant.cluster = "0"
                    let cityState = "\(relevant.title), \(relevant.subtitle ?? "")"
                    self.locationButton.setTitle(cityState, for: [])
                    self.locationHolder = relevant
                    self.locationButton.isEnabled = true
                }

                  /*  //let relevant = searches![0]
                    let relevant = SearchTextFieldItem.init(title: "Berryville", subtitle: "AR")
                    relevant.cluster = "0"
                    let cityState = "\(relevant.title), \(relevant.subtitle ?? "")"
                    self.locationButton.setTitle(cityState, for: [])
                    self.locationHolder = relevant
                    self.locationButton.isEnabled = true
                 */
            }
        }
        location.becomeFirstResponder()
        self.locationButton = alert.addButton("No Location", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            guard self.locationHolder != nil else {
                location.attributedPlaceholder = LoginStrings.error_text.generateString(text: "Please enter your Location!")
                return
            }
            location.resignFirstResponder()
            self.progress.startAnimation()
            let cityState = "\(self.locationHolder.title), \(self.locationHolder.subtitle!)"
            let person = Person(uid: authuser.uid, fullName: "\(first.capitalized) \(last.capitalized)", acctType: AcctType.phone.type, profilePic: "N/A", email: email, phone: phone, region: self.locationHolder.cluster ?? "000", cityState: cityState, uuid: self.uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false, address: "")
            self.saveFullAccountCheckExisting(alert: alert, person: person, completion: { (error, existingNomCount) in
                if error != nil {
                    self.displayError(oldAlert: alert, error: error!)
                } else {
                    self.progress.stopAnimation()
                    self.currentUser = person
                    alert.hideView()
                    self.checkAddProfilePicture()
                }
            })
        }
        self.locationButton.isEnabled = false
        self.addBackButton(alert: alert)
        alert.showInfo("Add Location", subTitle: "Start typing location below and press the button when the title is your location")
    }
    
    
    // MARK: - Profile Picture Load
    func checkAddProfilePicture() {
        let alert = SCLAlertView(appearance: phoneApperance)
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        self.profPic = UIImageView(image: self.picPlaceholder)
        subview.addSubview(self.profPic)
        self.designProfPic(pic: self.profPic)
        LoadLayout.instance.addCenteredPic(view: subview, dg: self.profPic)
        
        alert.customSubview = subview
        alert.addButton("Add", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            guard self.profImg != nil else {
                return
            }
            self.currentUser.saveImage(profilePic: self.profImg, completion: { (error) in
                if error != nil {
                    self.displayError(oldAlert: alert, error: error!)
                } else {
                    alert.hideView()
                }
            })
            print("adding Profile picture")
        }
        self.addFinishButton(alert: alert)
        alert.showInfo("Add Profile Picture?", subTitle: "")
    }
    
    
    func profilePictureActionSheet() {
        
    }
    // MARK: - Gesture Recognizer Delegate
    @objc func profPicTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            self.imgPick = GoldenImagePicker(viewController: self.vc, type: CropType.prof_pic.type, completion: { (image) in
                guard image != nil else {
                    self.profPic.image = self.picPlaceholder
                    return
                }
                self.profPic.layer.cornerRadius = self.profPic.frame.width / 2.0
                self.profPic.layer.masksToBounds = true
                self.profPic.image = Toucan(image: image!).maskWithEllipse().image
                self.profImg = image!
            })
        }
    }
    
    func designProfPic(pic: UIImageView) {
        pic.contentMode = UIViewContentMode.scaleAspectFit
        pic.layer.masksToBounds = false
        pic.layer.cornerRadius = self.profPic.frame.height / 2
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.profPicTapped(recognizer:)))
        pic.isUserInteractionEnabled = true
        pic.addGestureRecognizer(gesture)
    }
    
    func saveFullAccountCheckExisting(alert: SCLAlertView, person: Person, completion: @escaping (NSError?, Int?) -> Void) {
        person.saveFullAccount(completion: { (error, complete) in
            guard error == nil else {
                let err = error! as NSError
                completion(err, nil)
                return
            }
            // MARK: - This is to show if user has been nominated already
            if complete {
                //KeychainWrapper.standard.set(uid, forKey: Keys.uid.key)
                Authorize.instance.subscribe(user: person)
                person.checkUserAccept(completion: { (noms) in
                    
                    completion(nil, noms.count)
                })
            }
        })
    }
    
    // FUNCTION TWO
    func runPhoneAuth(pipedPhone: String, completion: @escaping (String?, Error?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(pipedPhone, uiDelegate: nil) { (verifId, error) in
            completion(verifId, error)
        }
        
    }
    
    /*func designPhoneAuthSecond() -> SCLAlertView {
        
    }*/
    // MARK: - Checkout View Setup
    func designCheckoutView() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: false, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Go to Cart", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            let checkoutVC = self.vc.storyboard?.instantiateViewController(withIdentifier: VCID.cart_screen.id) as! CartViewController
            let navVC = UINavigationController(rootViewController: checkoutVC)
            checkoutVC.currentUser = self.currentUser
            checkoutVC.fromAlert = true
            self.vc.present(navVC, animated: true, completion: nil)
        }
        self.addBackButton(alert: alert)
        
        return alert
    }
    func displayError(oldAlert: SCLAlertView, error: NSError) {
        oldAlert.hideView()
        self.handleAlert(error: error, view: self.vc)
        
    }
    func addBackButton(alert: SCLAlertView) {
        alert.addButton("Go Back", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            alert.hideView()
            DispatchQueue.main.async(execute: self.doneWorkItem)
        }
    }
    func addDismiss(alert: SCLAlertView) {
        alert.addButton("Dismiss", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            alert.hideView()
            if self.doneWorkItem != nil {
                DispatchQueue.main.async(execute: self.doneWorkItem)
            }
        }
    }
    func addFinishButton(alert: SCLAlertView) {
        alert.addButton("Finish", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            alert.hideView()
        }
    }
    
    func designDeleteAccount() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: true, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Logout", backgroundColor: LoginColors.form_error.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
//            guard self.currentUser.acctType != AcctType.anonymous.type else {
//                alert.hideView()
//                return
//            }
//            /// Assign acctType to anon acount
//            let ref = DBRef.user(uid: self.currentUser.uid).reference()
//            ref.child("acctType").setValue(AcctType.anonymous.type)
            
            /// removing account type from application
                guard Auth.auth().currentUser != nil else {
                    alert.hideView()

                    return
                }
                let user = Auth.auth().currentUser!

                do {
                    try Auth.auth().signOut()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutNotification"), object: nil)
                } catch (let error) {
                    print("Auth sign out failed: \(error)")
                }

            alert.hideView()
            
        }
        self.addDismiss(alert: alert)
        
        return alert
    }
    
    
    func designRateApp() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: true, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Go to Rating", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            self.rateUsButtonClicked()
        }
        self.addDismiss(alert: alert)
        
        return alert
    }
    func designFeedback() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: true, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
        let alert = SCLAlertView(appearance: appearance)
        let feedbackView = alert.addTextView()
        
        alert.addButton("Send Feedback", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            guard feedbackView.text != "" else {
                alert.dismiss(animated: true, completion: nil)
                return
            }
            let ref = DBRef.feedback(uid: self.currentUser.uid).reference()
            ref.setValue(feedbackView.text)
            alert.dismiss(animated: true, completion: nil)
            alert.hideView()
            self.vc.goldenAlert(title: "Feedback", message: "Thanks for your valuable feedback!", view: self.vc)
            
        }
        self.addDismiss(alert: alert)
        
        return alert
    }
    func showSuccess() {
        
    }
    func getRating() {
        
    }
    
    func rateUsButtonClicked() {
        self.rateApp(appId: "id1387621029")
    }
    func rateApp(appId: String) {
        self.openUrl("itms-apps://itunes.apple.com/app/\(appId)")
    }
    
    func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    // MARK: - Handling errors
    func handleAlert(error: NSError, view: UIViewController) {
        let alertView = SCLAlertView(appearance: errorAppearance)
        self.addDismiss(alert: alertView)
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .userNotFound:
                alertView.showError("Error Code : \(error.code)", subTitle: "\(error.localizedDescription)")
                // self.vc.goldenAlert(title: "Error Code : \(error.code)", message: "\(error.localizedFailureReason)", view: self.vc)
                print("User not found")
                // self.displayCreationAlert(title: "User not found", message: "", view: view)
            case .invalidEmail:
                alertView.showError("Error Code : \(error.code)", subTitle: "\(error.localizedDescription)")
                // self.vc.goldenAlert(title: "Error Code : \(error.code)", message: "\(error.localizedFailureReason)", view: self.vc)
                print("Invalid Email")
                // self.displayCreationAlert(title: "Invalid Email", message: "", view: view)
            case .wrongPassword:
                alertView.showError("Error Code : \(error.code)", subTitle: "\(error.localizedDescription)")
                // self.vc.goldenAlert(title: "Error Code : \(error.code)", message: "\(error.localizedFailureReason)", view: self.vc)
                print("Wrong Password")
                // self.displayCreationAlert(title: "Wrong Password", message: "", view: view)
            case .accountExistsWithDifferentCredential:
                alertView.showError("Error Code : \(error.code)", subTitle: "\(error.localizedDescription)")
                print("You have an account with a different email or phone number already")
                // self.vc.goldenAlert(title: "Error Code : \(error.code)", message: "\(error.localizedFailureReason)", view: self.vc)
                // self
            case .emailAlreadyInUse:
                alertView.showError("Error Code : \(error.code)", subTitle: "\(error.localizedDescription)")
                // self.vc.goldenAlert(title: "Error Code : \(error.code)", message: "Email already in use", view: self.vc)
                print("Email already in use")
                // self.displayCreationAlert(title: "Email Already in use", message: "", view: view)
            default:
                alertView.showError("Error Code : \(error.code)", subTitle: "\(error.localizedDescription)")
                // self.vc.goldenAlert(title: "Error Code : \(error.code)", message: "\(error.localizedFailureReason)", view: self.vc)
                print("Problem connecting to internet: \(error.localizedDescription)")
                // self.displayCreationAlert(title: "Problem connecting to internet: \(error.code)", message: "", view: view)
            }
        }
    }
    
    func handleAnyError(title: String?, message: String?, error: Error?, view: UIViewController) {
        let alertView = SCLAlertView(appearance: errorAppearance)
        self.addDismiss(alert: alertView)
        if error != nil {
            alertView.showError(title ?? "Error", subTitle: "\(error!.localizedDescription)")
        } else {
            alertView.showError(title ?? "Error", subTitle: message ?? "")
        }
    }
}





















