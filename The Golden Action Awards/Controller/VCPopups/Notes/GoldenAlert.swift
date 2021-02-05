//
//  GoldenAlert.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation

class GoldenAlert {
    /*
     private static let instanceInner = CustomAlert()
     
     static var instance: CustomAlert {
     return instanceInner
     }
     
     var emailText: UITextField!
     var passwordTextField: UITextField!
     
     
     
     // MARK: - Edit with new use of GrandCentralStation
     func presentTextAlertHome(title: String, message: String, emailPlaceholder: String, buttonTitle: String, view: UIViewController, passwordPlaceholder: String) {
     let alertVC = NYAlertViewController()
     alertVC.title = title
     alertVC.message = message
     alertVC.addTextField { (txtField) in
     txtField?.placeholder = emailPlaceholder
     txtField?.tintColor = UIColor.black
     txtField?.borderStyle = .roundedRect
     txtField?.font = UIFont(name: "Avenir-Black", size: 13)
     self.emailText = txtField
     }
     alertVC.addTextField { (txtField) in
     txtField?.placeholder = passwordPlaceholder
     txtField?.borderStyle = .roundedRect
     txtField?.tintColor = UIColor.black
     txtField?.isSecureTextEntry = true
     txtField?.font = UIFont(name: "Avenir-Black", size: 13)
     self.passwordTextField = txtField
     }
     
     
     // Customize appearance as desired
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     
     // Actual Alert Design
     alertVC.alertViewCornerRadius = 20
     alertVC.alertViewBackgroundColor = UIColor.white
     
     
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     let sendAction = NYAlertAction(title: "Send", style: .default) { (_) in
     guard self.emailText != nil || self.passwordTextField != nil else {
     view.dismiss(animated: true, completion: nil)
     
     return
     }
     guard EduEmailAuth.eduAuthInstance.checkEmail(eduEmail: self.emailText.text!) else {
     // Alert
     return
     }
     view.dismiss(animated: true, completion: nil)
     FIRAuthenticate.instanceAuthenticate.loginStudentToFIR(withEmail: self.emailText.text!, password: self.passwordTextField.text!, view: view, completion: { (error, user) in
     guard error == nil else {
     return
     }
     if let user = Auth.auth().currentUser {
     if !user.isEmailVerified {
     user.sendEmailVerification(completion: { (error) in
     guard error == nil else {
     self.designTextAlert(title: "Error", message: "There was an error sending verification please try again", view: view)
     return
     }
     self.designTextAlert(title: "Verification Email Sent!", message: "", view: view)
     })
     
     } else {
     self.designTextAlert(title: "Your account is already verified", message: "Log in and your good to go!", view: view)
     }
     }
     })
     
     }
     let canc = NYAlertAction(title: "Cancel", style: .default) { (_) in
     print("cancelled")
     view.dismiss(animated: true, completion: nil)
     }
     alertVC.addAction(sendAction)
     alertVC.addAction(canc)
     view.present(alertVC, animated: true, completion: nil)
     }
     
     // Main Alert for any type of error --> Usually regarding internet connection
     func designTextAlert(title: String, message: String, view: UIViewController) {
     // Set a title and message
     // Customize appearance as desired
     let alertVC = NYAlertViewController()
     alertVC.title = title
     alertVC.message = message
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     
     let okayAction = NYAlertAction(title: "Okay", style: .default) { (_) in
     view.dismiss(animated: true, completion: nil)
     }
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     
     }
     func deleteAccount(mainStation: GrandCentralStation, view: UIViewController, firMessage: Messaging, browsing: Stud, completion: @escaping (Error?) -> Void) {
     let deleteUser = DispatchWorkItem {
     mainStation.deleteUser(mainStation: mainStation, firMessage: firMessage, browsing: browsing, completion: { (error) in
     guard error == nil else {
     completion(error)
     print(error?.localizedDescription)
     return
     }
     print("done")
     })
     }
     let alertVC = NYAlertViewController()
     alertVC.title = "Are you sure you want to delete your account?"
     alertVC.message = "You will lose all profile information, conversations, socials and listings?"
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = UIColor.red
     alertVC.cancelButtonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     let cancelAction = NYAlertAction(title: "No", style: .cancel) { (_) in
     view.dismiss(animated: true, completion: nil)
     }
     let okayAction = NYAlertAction(title: "Yes", style: .default) { (_) in
     view.dismiss(animated: true, completion: nil)
     mainStation.que.asyncAfter(deadline: .now() + .nanoseconds(900), execute: deleteUser)
     //mainStation.que.async(group: mainStation.group, execute: deleteUser)
     }
     
     alertVC.addAction(cancelAction)
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     }
     func verificationTextField(view: UIViewController, user: User) {
     // Set a title and message
     // Customize appearance as desired
     let alertVC = NYAlertViewController()
     alertVC.title = "Error with Verification"
     alertVC.message = "Your email has not yet been verified, should we resend the verification email to \(user.email!)?"
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     let sendAction = NYAlertAction(title: "Send!", style: .default) { (_) in
     user.sendEmailVerification(completion: nil)
     view.dismiss(animated: true, completion: nil)
     }
     let okayAction = NYAlertAction(title: "Cancel", style: .default) { (_) in
     view.dismiss(animated: true, completion: nil)
     }
     alertVC.addAction(sendAction)
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     }
     func editProfileAlert(view: UIViewController, station: GrandCentralStation, workItem: DispatchWorkItem) {
     station.que.async {
     let alertVC = NYAlertViewController()
     alertVC.title = "Are you sure you would like to edit your profile?"
     alertVC.message = nil
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = UIColor.red
     alertVC.cancelButtonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     let okayAction = NYAlertAction(title: "Yes", style: .default) { (_) in
     station.que.asyncAfter(deadline: .now() + .nanoseconds(50), execute: workItem)
     view.dismiss(animated: true, completion: nil)
     }
     let cancelAction = NYAlertAction(title: "No", style: .cancel) { (_) in
     view.dismiss(animated: true, completion: nil)
     }
     alertVC.addAction(cancelAction)
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     }
     }
     func genericDeletedObject(view: UIViewController, station: GrandCentralStation, workItem: DispatchWorkItem, title: String) {
     let newStation = station
     station.que.async {
     let alertVC = NYAlertViewController()
     alertVC.title = "Error with Verification"
     alertVC.message = nil
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = UIColor.red
     alertVC.cancelButtonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     let okayAction = NYAlertAction(title: "Yes", style: .default) { (_) in
     station.que.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
     view.dismiss(animated: true, completion: nil)
     }
     let cancelAction = NYAlertAction(title: "No", style: .cancel) { (_) in
     view.dismiss(animated: true, completion: nil)
     }
     alertVC.addAction(cancelAction)
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     }
     
     }
     func genericDeletedCheck(view: UIViewController, station: GrandCentralStation, workItem: DispatchWorkItem, title: String) {
     
     station.que.async {
     let alertVC = NYAlertViewController()
     alertVC.title = "Error with Verification"
     alertVC.message = nil
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     // Actions
     alertVC.swipeDismissalGestureEnabled = true
     alertVC.backgroundTapDismissalGestureEnabled = true
     let okayAction = NYAlertAction(title: "Okay", style: .default) { (_) in
     station.que.asyncAfter(deadline: .now() + .nanoseconds(400), execute: workItem)
     view.dismiss(animated: true, completion: nil)
     }
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     }
     }
     // MARK: Transfer to new update file
     func updateAlert(title: String, message: String?, versionNum: Double, view: UIViewController) {
     let alertVC = NYAlertViewController()
     let q = DispatchQueue(label: "AppUpdate", qos: DispatchQoS.init(qosClass: .userInteractive, relativePriority: 0), attributes: .concurrent, autoreleaseFrequency: .workItem, target: .main)
     let k = DispatchQueue(label: "keyUpdate", qos: DispatchQoS.init(qosClass: .utility, relativePriority: 0), attributes: .concurrent, autoreleaseFrequency: .workItem, target: .global())
     let keychainItem = DispatchWorkItem {
     let data = NSKeyedArchiver.archivedData(withRootObject: versionNum)
     KeychainWrapper.standard.set(data, forKey: KeychainKey.versionKey.key)
     }
     
     let appStoreItem = DispatchWorkItem {
     if let url = URL(string: "https://itunes.apple.com/us/app/roomdig-the-college-app/id1271294543?mt=8"),
     UIApplication.shared.canOpenURL(url)
     {
     if #available(iOS 10.0, *) {
     UIApplication.shared.open(url, options: [:], completionHandler: nil)
     } else {
     UIApplication.shared.openURL(url)
     }
     }
     k.asyncAfter(deadline: .now() + .nanoseconds(100), execute: keychainItem)
     }
     let updateItem = DispatchWorkItem {
     view.dismiss(animated: true, completion: nil)
     q.asyncAfter(deadline: .now() + .nanoseconds(10), execute: appStoreItem)
     }
     let updateLater = DispatchWorkItem {
     view.dismiss(animated: true, completion: nil)
     k.asyncAfter(deadline: .now() + .nanoseconds(10), execute: keychainItem)
     }
     
     q.async {
     alertVC.title = title
     alertVC.message = message
     alertVC.buttonCornerRadius = 20.0
     
     alertVC.view.tintColor = UIColor.white
     
     alertVC.titleFont = UIFont(name: "Avenir-Black", size: 19.0)
     alertVC.messageFont = UIFont(name: "AvenirNext-Book", size: 16.0)
     alertVC.cancelButtonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     alertVC.buttonTitleFont = UIFont(name: "Avenir-Book", size: 16.0)
     
     alertVC.buttonColor = ElementEditing.elementInstance.appColor
     alertVC.buttonTitleColor = UIColor.white
     alertVC.titleColor = ElementEditing.elementInstance.appColor
     
     // Actions
     alertVC.swipeDismissalGestureEnabled = false
     alertVC.backgroundTapDismissalGestureEnabled = false
     let sendAction = NYAlertAction(title: "Update!", style: .default) { (_) in
     q.asyncAfter(deadline: .now() + .nanoseconds(10), execute: updateItem)
     }
     let okayAction = NYAlertAction(title: "Remind Me Later", style: .default) { (_) in
     q.asyncAfter(deadline: .now() + .nanoseconds(10), execute: updateLater)
     }
     alertVC.addAction(sendAction)
     alertVC.addAction(okayAction)
     view.present(alertVC, animated: true, completion: nil)
     }
     
     }
 */
}
