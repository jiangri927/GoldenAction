//
//  Authorize.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/18/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import NYAlertViewController
import SwiftKeychainWrapper
import Bond
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging


enum AcctType {
    case phone
    case email
    case google
    case anonymous
    
    var type: String {
        switch self {
        case .phone:
            return "phone"
        case .email:
            return "email"
        case .google:
            return "google"
        case .anonymous:
            return "anon"
        }
    }
    
    
}
class Authorize {
    
    private static let instanceInner = Authorize()
    
    static var instance: Authorize {
        return instanceInner
    }
    
    private var currentUserInner: Person!
    private var currentNomCatInner: String!
    private var currentNomLocationInner: Cities!
    private var currentNominationsInner: [Nominations]!
    private var currentAwardsCatInner: String!
    private var currentAwardsLocationInner: Cities!
    private var currentAwardsInner: [Nominations]!
    
    var currentUser: Person {
        set {
            currentUserInner = newValue
        } get {
            return currentUserInner
        }
    }
    var currentNomCategory: String {
        set {
            currentNomCatInner = newValue
        } get {
            return currentNomCatInner
        }
    }
    var currentNomLocation: Cities {
        set {
            currentNomLocationInner = newValue
        } get {
            return currentNomLocationInner
        }
    }
    var currentNominations: [Nominations] {
        set {
            currentNominationsInner = newValue
        } get {
            
            return currentNominationsInner
        }
    }
    
    var currentAwardCategory: String {
        set {
            currentAwardsCatInner = newValue
        } get {
            return currentAwardsCatInner
        }
    }
    var currentAwardLocation: Cities {
        set {
            currentAwardsLocationInner = newValue
        } get {
            return currentAwardsLocationInner
        }
    }
    var currentAwards: [Nominations] {
        set {
            currentAwardsInner = newValue
        } get {
            return currentAwardsInner
        }
    }
    
    let phoneAuthKey = "phoneAuthID"
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "none"
    
    func createUser(acctType: String, credential: AuthCredential, email: String?, password: String?, fullName: String, region: String, cityState: String, phone: String, admin: Bool, adminStage: Int, sponsorDescription: String, profilePic: UIImage, view: UIViewController, completion: @escaping (Error?, Int?) -> Void) {
        guard Auth.auth().currentUser != nil else {
            let err = NSError()
            completion(err as Error, nil)
            return
        }
        let anonUser = Auth.auth().currentUser!
        if acctType == AcctType.phone.type {
            
            self.saveAccount(view: view, profilePic: profilePic, uid: anonUser.uid, fullName: fullName, acctType: acctType, email: email ?? "N/A", phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: sponsorDescription) { (error, existing) in
                completion(error, existing)
            }
        } else {
            //anonUser.link(with: credential) { (user, error) in
// sudesh anonUser.link is depricated
            
//            guard anonUser.uid != nil else{
//                print("Error occurred")
//                return
//            }
            //if let uid = anonUser.uid {
            /*    self.saveAccount(view: view, profilePic: profilePic, uid: anonUser.uid, fullName: fullName, acctType: acctType, email: email ?? "N/A", phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: sponsorDescription) { (error, existing) in
                    completion(error, existing)
                }
 */
            //}
            
            anonUser.linkAndRetrieveData(with: credential) { (userAuth, error) in
                if error != nil {
                    let err = error! as NSError
                    self.handleAlert(error: err, view: view)
                    completion(error, nil)
                } else {
                    if let uid = userAuth?.user.uid {
//                        self.saveAccount(view: view, profilePic: profilePic, uid: uid, fullName: fullName, acctType: acctType, email: email ?? "N/A", phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: sponsorDescription) { (error, existing) in
//                            completion(error, existing)
//                        }
                        self.saveAccount(view: view, profilePic: profilePic, uid: uid, fullName: fullName, acctType: acctType, email: email ?? "N/A", phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: sponsorDescription) { (error, existing) in
                            completion(error, existing)
                        }

                    }
                }
            }
            
        }
        
    }
    func saveAccount(view: UIViewController, profilePic: UIImage?, uid: String, fullName: String, acctType: String, email: String, phone: String, region: String, cityState: String, uuid: String, admin: Bool, adminStage: Int, adminDescription: String, completion: @escaping (Error?, Int?) -> Void) {
        let image = UIImage.init(named:"profpic_placeholder")!
        
        ImageSaving(image: profilePic ?? image).saveProfPic(userUID: uid, completion: { (error, url) in
            guard error == nil && url != nil else {
                let err = error! as NSError
                self.handleAlert(error: err, view: view)
                completion(error, nil)
                return
            }
            var goldenPerson: Person!
            if acctType == AcctType.email.type {
                goldenPerson = Person(uid: uid, fullName: fullName, acctType: acctType, profilePic: url!, email: email, phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: adminDescription,isSponsor: false, address: "")
            } else if acctType == AcctType.phone.type {
                goldenPerson = Person(uid: uid, fullName: fullName, acctType: acctType, profilePic: url!, email: "N/A", phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: adminDescription,isSponsor: false, address: "")
            } else {
                goldenPerson = Person(uid: uid, fullName: fullName, acctType: acctType, profilePic: url!, email: email, phone: phone, region: region, cityState: cityState, uuid: self.uuid, admin: admin, adminStage: adminStage, adminDescription: adminDescription,isSponsor: false, address: "")
            }
            
            goldenPerson.saveFullAccount(completion: { (error, complete) in
                guard error == nil else {
                    let err = error! as NSError
                    self.handleAlert(error: err, view: view)
                    completion(error, nil)
                    return
                }
                // MARK: - This is to show if user has been nominated already
                if complete {
                    //KeychainWrapper.standard.set(uid, forKey: Keys.uid.key)
                    self.subscribe(user: goldenPerson)
                    goldenPerson.checkUserAccept(completion: { (noms) in
                        completion(nil, noms.count)
                    })
                    
                } else {
                    completion(nil, nil)
                }
            })
        })
    }
    func subscribeToNomination(nominationUID: String) {
        Messaging.messaging().subscribe(toTopic: nominationUID)
    }
    func unsubscribeToNomination(nominationUID: String) {
        Messaging.messaging().unsubscribe(fromTopic: nominationUID)
    }
    func subscribe(user: Person) {
        Messaging.messaging().subscribe(toTopic: user.phone)
        Messaging.messaging().subscribe(toTopic: user.region)
        Messaging.messaging().subscribe(toTopic: user.uid)
        for uu in user.uuid {
            Messaging.messaging().subscribe(toTopic: uu)
        }
        print("User Subscribed to Notifications")
    }
    func unsubscribe(user: Person, toRegion: Bool, toUID: Bool, toUUIDS: Bool) {
        if toRegion {
            Messaging.messaging().unsubscribe(fromTopic: user.region)
        }
        if toUID {
            Messaging.messaging().unsubscribe(fromTopic: user.uid)
        }
        if toUUIDS {
            for uu in user.uuid {
                Messaging.messaging().unsubscribe(fromTopic: uu)
            }
        }
    }
    func createGoogleUser(credential: AuthCredential, view: WelcomeViewController, completion: @escaping (Error?, Bool) -> Void) {
        let anonUser = Auth.auth().currentUser
        anonUser?.link(with: credential, completion: { (user, error) in
            guard error == nil && user != nil else {
                let err = error! as NSError
                print(error!.localizedDescription)
                self.handleAlert(error: err, view: view)
                completion(error, false)
                return
            }
            let person = Person(uid: user!.uid, fullName: user!.displayName ?? "N/A", acctType: AcctType.google.type, profilePic: "N/A", email: user!.email ?? "N/A", phone: user!.phoneNumber ?? "N/A", region: "000", cityState: "N/A", uuid: self.uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false, address: "")
            person.saveFullAccount(completion: { (error, complete) in
                guard error == nil else {
                    return
                }
            })
            completion(nil, true)
        })
        /*anonUser.signIn(with: credential) { (user, error) in
            guard error == nil && user != nil else {
                let err = error! as NSError
                print(error!.localizedDesription)
                self.handleAlert(error: err, view: view)
                completion(error, false)
                return
            }
            let person = Person(uid: user!.uid, fullName: user!.displayName ?? "N/A", acctType: AcctType.google.type, profilePic: "N/A", email: user!.email ?? "N/A", phone: user!.phoneNumber ?? "N/A", region: "000", cityState: "N/A", uuid: self.uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false)
            person.saveFullAccount(completion: { (error, complete) in
                guard error == nil else {
                    return
                }
            })
            completion(nil, true)
        } */
    }
    func signExistingGoogle(credential: AuthCredential, completion: @escaping (Error?, Bool) -> Void) {
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if error != nil {
                //let err = error! as NSError
                //self.handleAlert(error: err, view: view)
                completion(error, false)
            } else {
                completion(nil, true)
            }
            
        }
    }
    func createExistingUserAdmin(user: Person, sponsorDescription: String) {
        
    }
    func completeSignUp(email: String, password: String, view: UIViewController, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                let err = error! as NSError
                self.handleAlert(error: err, view: view)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    func signGoogleAccountIn(credential: AuthCredential, view: UIViewController, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(with: credential) { (user, error) in
        
            if error != nil {
                let err = error! as NSError
                self.handleAlert(error: err, view: view)
                completion(error)
            } else {
                completion(nil)
            }
            
        }
    }
//    func signUpAnonymously(view: UIViewController, completion: @escaping (Error?) -> Void) {
//        Auth.auth().signInAnonymously { (user, error) in
//
//            if error != nil {
//                let err = error! as NSError
//                self.handleAlert(error: err, view: view)
//                completion(error)
//            } else {
//                let uid = user!.user.uid
//                let person = Person(uid: uid, fullName: "Anonymous", acctType: "anon", profilePic: "N/A", email: "N/A", phone: "N/A", region: "000", cityState: "N/A", uuid: self.uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false)
//                person.saveAnon()
//                //KeychainWrapper.standard.set(uid, forKey: Keys.uid.key)
//                completion(nil)
//
//            }
//        }
//    }
    func resignAnon(view: UIViewController, completion: @escaping (Error?) -> Void) {
        Auth.auth().signInAnonymously { (user, error) in
    
            if error != nil {
                let err = error! as NSError
                self.handleAlert(error: err, view: view)
                completion(error)
            } else {
                let uid = user!.user.uid
                let person = Person(uid: uid, fullName: "Anonymous", acctType: "anon", profilePic: "N/A", email: "N/A", phone: "N/A", region: "000", cityState: "N/A", uuid: self.uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false, address: "")
                person.saveAnon()
                //KeychainWrapper.standard.set(uid, forKey: Keys.uid.key)
                
            }
        }
    }
    
    // MARK: - Handling errors
    func handleAlert(error: NSError, view: UIViewController) {
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .userNotFound:
                self.displayCreationAlert(title: "User not found", message: "", view: view)
            case .invalidEmail:
                self.displayCreationAlert(title: "Invalid Email", message: "", view: view)
            case .wrongPassword:
                self.displayCreationAlert(title: "Wrong Password", message: "", view: view)
            case .accountExistsWithDifferentCredential:
                fallthrough
            case .emailAlreadyInUse:
                self.displayCreationAlert(title: "Email Already in use", message: "", view: view)
            default:
                self.displayCreationAlert(title: "Problem connecting to internet: \(error.code)", message: "", view: view)
            }
        }
    }
    func displayCreationAlert(title: String, message: String, view: UIViewController) {
        // Set a title and message
        // Customize appearance as desired
        let alertVC = NYAlertViewController()
        
        // Background Color and Corner Design
        alertVC.alertViewBackgroundColor = Colors.black.generateColor()
        alertVC.buttonCornerRadius = 10.0
        // Title and Message Designs
        alertVC.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
        alertVC.titleColor = Colors.app_text.generateColor()
        alertVC.messageFont = Fonts.hira_pro_three.generateFont(size: 17.0)
        alertVC.messageColor = Colors.app_text.generateColor()
        
        // Cancel Then Default Button Designs
        alertVC.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        alertVC.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        alertVC.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
        alertVC.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        alertVC.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        alertVC.buttonColor = Colors.nom_detail_innerBorder.generateColor()
        
        alertVC.title = title
        alertVC.message = message
        alertVC.buttonCornerRadius = 20.0
        
        
    
        // Actions
        alertVC.swipeDismissalGestureEnabled = true
        alertVC.backgroundTapDismissalGestureEnabled = true
        
        let okayAction = NYAlertAction(title: "Okay", style: .default) { (_) in
            view.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okayAction)
        view.present(alertVC, animated: true, completion: nil)
    }
    
    
    
}
