//
//  Person.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/3/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Firebase
import Alamofire
//import AlgoliaSearch
import Bond
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging




enum AdminStatus {
    
    case not_accepted
    case denied
    case accepted_initial // Trigger to show tutorial for this
    case accepted_final
    case none

    var status: Int {
        switch self {
        case .not_accepted:
            return 0
        case .denied:
            return 1
        case .accepted_initial:
            return 2
        case .accepted_final:
            return 3
        case .none:
            return 4
        }
    }
    
    func setProfileButton(selector: DispatchWorkItem, button: UIButton) {
        switch self {
        case .not_accepted: // Display Alert
            button.setTitle("Awaiting Approval", for: [])
            button.reactive.tap.observeNext {
                DispatchQueue.main.async(execute: selector)
            }
        case .none: // Display Sign up screen
            button.setTitle("Awaiting Approval", for: [])
            button.reactive.tap.observeNext {
                DispatchQueue.main.async(execute: selector)
            }
        case .denied: // Show Alert
            button.setTitle("New Sponsor Status", for: [])
            button.reactive.tap.observeNext {
                DispatchQueue.main.async(execute: selector)
            }
        case .accepted_initial: // Go to Tutorial Admin Screens
            button.setTitle("You have been Accepted!", for: [])
            button.reactive.tap.observeNext {
                DispatchQueue.main.async(execute: selector)
            }
        case .accepted_final: // Go to main Admin Screen
            button.setTitle("Go to Admin", for: [])
            button.reactive.tap.observeNext {
                DispatchQueue.main.async(execute: selector)
            }
        }
    }
    
    
    
    
}
class Person: NSObject, NSCoding {

    let uid: String
    var fullName: String
    var email: String
    var region: String
    var cityState: String
    var acctType: String // "google", "email", or "anon"
    var phone: String
    var profilePictureURL: String
    var purchasedVotes: Int
    var purchasedNoms: Int
    var uuid: [String]
    var admin: Bool
    var owner: Bool
    var adminStage: Int // MARK: - See AdminStatus Enum for description on this.
    var adminDescription: String
    var banned: Bool
    var nominee: Bool!
    var isSponsor: Bool!
    var address: String
    
    var keychain = KeychainWrapper.standard
    
    init(uid: String, fullName: String, acctType: String, profilePic: String, email: String, phone: String, region: String, cityState: String, uuid: String, admin: Bool, adminStage: Int, adminDescription: String, isSponsor: Bool, address: String) {
        self.uid = uid
        self.fullName = fullName
        self.region = region
        self.cityState = cityState
        self.profilePictureURL = profilePic
        self.email = email
        self.acctType = acctType
        self.phone = phone
        self.purchasedVotes = 0
        self.purchasedNoms = 0
        self.uuid = []
        self.uuid.append(uuid)
        self.admin = admin
        self.adminStage = adminStage
        self.adminDescription = adminDescription
        self.banned = false
        self.owner = false
        self.isSponsor = isSponsor
        self.address = address
    }
    init(decodedUID: String, fullName: String, acctType: String, profilePic: String, email: String, phone: String, region: String, cityState: String, votes: Int, noms: Int, uuid: [String], admin: Bool, adminStage: Int, adminDescription: String, banned: Bool, owner: Bool, isSponsor: Bool, address: String) {
        self.uid = decodedUID
        self.fullName = fullName
        self.region = region
        self.cityState = cityState
        self.profilePictureURL = profilePic
        self.email = email
        self.acctType = acctType
        self.phone = phone
        self.purchasedVotes = 0
        self.purchasedNoms = 0
        self.uuid = uuid
        self.admin = admin
        self.adminStage = adminStage
        self.adminDescription = adminDescription
        self.banned = banned
        self.owner = owner
        self.isSponsor = isSponsor
        self.address = address
    }
    
    init(dict: [String : Any]) {
        self.uid = dict["uid"] as? String ?? "N/A"
        self.fullName = dict["fullName"] as? String ?? "N/A"
        self.region = dict["region"] as? String ?? "000"
        self.cityState = dict["cityState"] as? String ?? "N/A"
        self.acctType = dict["acctType"] as? String ?? AcctType.anonymous.type
        self.profilePictureURL = dict["url"] as? String ?? "N/A"
        self.email = dict["email"] as? String ?? "N/A"
        self.phone = dict["phone"] as? String ?? "N/A"
        self.purchasedVotes = dict["votes"] as? Int ?? 0
        self.purchasedNoms = dict["noms"] as? Int ?? 0
        self.uuid = dict["uuid"] as? [String] ?? []
        self.admin = dict["admin"] as? Bool ?? false
        self.adminStage = dict["adminStage"] as? Int ?? AdminStatus.none.status
        self.adminDescription = dict["adminDescription"] as? String ?? "N/A"
        self.banned = dict["banned"] as? Bool ?? false
        self.nominee = dict["nominee"] as? Bool ?? false
        self.owner = dict["owner"] as? Bool ?? false
        self.isSponsor = dict["isSponsor"] as? Bool ?? false
        self.address = dict["address"] as? String ?? ""
    }
    
   
    
    required convenience init?(coder aDecoder: NSCoder) {
        let uid = aDecoder.decodeObject(forKey: "uid") as? String ?? "N/A"
        let full = aDecoder.decodeObject(forKey: "full") as? String ?? "N/A"
        let region = aDecoder.decodeObject(forKey: "region") as? String ?? "000"
        let cityState = aDecoder.decodeObject(forKey: "cityState") as? String ?? "N/A"
        let url = aDecoder.decodeObject(forKey: "url") as? String ?? "N/A"
        let acctType = aDecoder.decodeObject(forKey: "acct") as? String ?? "anon"
        let email = aDecoder.decodeObject(forKey: "email") as? String ?? "N/A"
        let phone = aDecoder.decodeObject(forKey: "phone") as? String ?? "N/A"
        let votes = aDecoder.decodeInteger(forKey: "votes")
        let noms = aDecoder.decodeInteger(forKey: "noms")
        let admin = aDecoder.decodeBool(forKey: "admin")
        let uuid = aDecoder.decodeObject(forKey: "uuid") as? [String] ?? []
        let status = aDecoder.decodeInteger(forKey: "adminStage") ?? AdminStatus.none.status
        let adminDescription = aDecoder.decodeObject(forKey: "adminDescription") as? String ?? "N/A"
        let banned = aDecoder.decodeBool(forKey: "banned")
        let owner = aDecoder.decodeBool(forKey: "owner")
        let isSpon = aDecoder.decodeBool(forKey: "isSponsor")
        let address = aDecoder.decodeObject(forKey: "address") as? String ?? ""
        
        self.init(decodedUID: uid, fullName: full, acctType: acctType, profilePic: url, email: email, phone: phone, region: region, cityState: cityState, votes: votes, noms: noms, uuid: uuid, admin: admin, adminStage: status, adminDescription: adminDescription, banned: banned, owner: owner,isSponsor: isSpon, address: address)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.uid,              forKey: "uid")
        aCoder.encode(self.fullName,         forKey: "full")
        aCoder.encode(self.region,           forKey: "region")
        aCoder.encode(self.cityState,        forKey: "cityState")
        aCoder.encode(self.profilePictureURL, forKey: "url")
        aCoder.encode(self.acctType, forKey: "acct")
        aCoder.encode(self.email,            forKey: "email")
        aCoder.encode(self.phone,            forKey: "phone")
        aCoder.encode(self.purchasedVotes,   forKey: "votes")
        aCoder.encode(self.purchasedNoms,    forKey: "noms")
        aCoder.encode(self.uuid,             forKey: "uuid")
        aCoder.encode(self.admin,            forKey: "admin")
        aCoder.encode(self.adminStage,       forKey: "adminStage")
        aCoder.encode(self.adminDescription, forKey: "adminDescription")
        aCoder.encode(self.banned,           forKey: "banned")
        aCoder.encode(self.owner,            forKey: "owner")
        aCoder.encode(self.isSponsor,        forKey: "isSponsor")
        aCoder.encode(self.address,        forKey: "address")
    }
    
    // MARK: - Creates Anonymous Account
    func saveAnon() {
        let ref = DBRef.user(uid: self.uid).reference()
        let lastNomCatRef = DBRef.userLastNomCategory(uid: self.uid).reference()
        let lastNomLocRef = DBRef.userLastNomLocation(uid: self.uid).reference()
        let lastAwardCatRef = DBRef.userLastAwardCategory(uid: self.uid).reference()
        let lastAwardLocRef = DBRef.userLastAwardLocation(uid: self.uid).reference()
        let lastNomination = DBRef.userPreNomination(uid: self.uid).reference()
        let popularCity = Cities(cluster: "000", cityState: "Popular")
        let legalStatus = DBRef.legal(uid: self.uid).reference()
        ref.setValue(self.toDictionary())
        lastNomCatRef.setValue(FilterStrings.all_category.id)
        lastNomLocRef.setValue(popularCity.toDictionary())
        lastAwardCatRef.setValue(FilterStrings.all_category.id)
        lastAwardLocRef.setValue(popularCity.toDictionary())
        legalStatus.setValue(false)
        lastNomination.setValue("none")
    }
    // MARK: - Links Anonymous Account to full account --> profile picture is saved prior for url
    func saveFullAccount(completion: @escaping (Error?, Bool) -> Void) {
        let ref = DBRef.user(uid: self.uid).reference()
        let phoneRef = DBRef.userPhoneNumber(phoneNumber: self.phone).reference()
        
        phoneRef.setValue(self.uid) { (error, ref) in
            print(error?.localizedDescription)
            print(ref)
        }
        
        //let totalUserVotes = DBRef.totalUserVotes(uid: self.uid).reference()
        //let totalUserNomes = DBRef.totalUserNoms(uid: self.uid).reference()
        let badgeWorkItem = DispatchWorkItem {
            self.badgeGeneralSaveCheck { (complete) in
                if !self.admin {
                    completion(nil, complete)
                } else {
                    self.saveAdminPending(sponsorDescription: self.adminDescription, completion: { (completed) in
                        completion(nil, complete)
                    })
                }
            }
        }
        let algoliaWorkItem = DispatchWorkItem {
           /* self.addUserAlgolia(completion: { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    completion(error, false)
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: badgeWorkItem)
                
            })*/
           /* self.addUserFirestore(completion: {_ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: badgeWorkItem)
            }) */
        }
        
        let firebaseWorkItem = DispatchWorkItem {
            ref.setValue(self.toDictionary())
            ref.updateChildValues(["votes":self.purchasedVotes])
            //totalUserVotes.setValue(0)
            //totalUserNomes.setValue(0)
           // DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: algoliaWorkItem)
            completion(nil, true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: firebaseWorkItem)
    }
    
    func saveImage(profilePic: UIImage, completion: @escaping (NSError?) -> Void) {
        let ref = DBRef.user(uid: self.uid).reference().child("url")
        ImageSaving(image: profilePic).saveProfPic(userUID: uid, completion: { (error, url) in
            guard error == nil && url != nil else {
                let err = error! as NSError
                completion(err)
                return
            }
            ref.setValue(url!)
            completion(nil)
        })
    }
    func saveAdminPending(sponsorDescription: String, completion: @escaping (Bool?) -> Void) {
        let ref = DBRef.spec_admin_pending(region: self.region, uid: self.uid).reference()
        let userRef = DBRef.user(uid: self.uid).reference()
        
        let valueWorkItem = DispatchWorkItem {
            ref.setValue(sponsorDescription)
            //ref.setValue(self.toDictionary())
            userRef.updateChildValues(["admin" : false, "adminStage" : AdminStatus.not_accepted.status, "adminDescription": sponsorDescription])
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
        
    }
    func saveAlgolia(completion: @escaping (Bool?) -> Void) {
        
    }
    func saveAlgoliaAdmin(completion: @escaping (Bool?) -> Void) {
        
    }
    func toDictionary() -> [String : Any] {
        return [
            "uid": self.uid,
            "fullName": self.fullName,
            "region": self.region,
            "cityState": self.cityState,
            "acctType": self.acctType,
            "url": self.profilePictureURL,
            "email": self.email,
            "phone": self.phone,
            "votes": self.purchasedVotes,
            "noms": self.purchasedNoms,
            "uuid": self.uuid,
            "admin": self.admin,
            "adminStage": self.adminStage,
            "adminDescription": self.adminDescription,
            "banned": self.banned,
            "isSponsor": self.isSponsor,
            "address": self.address
        ]
    }
    
    func userAlgDict() -> [String : Any] {
        return [
            "uid": self.uid,
            "fullName": self.fullName,
            "region": self.region,
            "cityState": self.cityState,
            "phone": self.phone,
            "banned": self.banned,
            "url": self.profilePictureURL
        
        ]
    }
    class func splitName(fullName: String, first: Bool) -> String {
        let delimeter = " "
        let components = fullName.components(separatedBy: delimeter)
        if first {
            return components[0]
        } else {
            return components[1]
        }
    }
    func splitName(first: Bool) -> String {
        let delimeter = " "
        let components = self.fullName.components(separatedBy: delimeter)
        if first {
            return components[0]
        } else {
            return components[1]
        }
    }
}

extension Person {
    
    func updatePurchasedNom(){
        let remainsNom = self.purchasedNoms
        let ref = DBRef.user(uid: self.uid).reference()
        ref.updateChildValues(["noms":remainsNom])
    }
    
}

extension Person {
    class func monitorAppUpdate(completion: @escaping (String, String) -> Void) {
        let ref = DBRef.app_version.reference()
        ref.observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let url = dict["url"] as? String ?? "goldenactionawards.com"
                let value = dict["version"] as? Int ?? 0
                completion("\(value)", url)
            }
        }
    }
    // MARK: - Monitor finished nomination file path for alert --> THIS IS AFTER NOMINATION SPONSOR SENDS COIN
    func observeFinished(completion: @escaping ([Nominations]) -> Void) {
        let ref = DBRef.finishedNominations(nomineeUID: self.uid).reference()
        ref.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var noms = [Nominations]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let nomination = Nominations(dict: dict)
                        if !noms.contains(nomination) {
                            noms.append(nomination)
                        }
                    }
                }
                completion(noms)
            } else {
                completion([])
            }
        }
    }
    
    // MARK: - Get person
    class func getUser(uid: String, completion: @escaping (Person?) -> Void) {
        let ref = DBRef.user(uid: uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let person = Person(dict: dict)
                completion(person)
            } else {
                completion(nil)
            }
        }
    }
    
    
    class func getAllUsers(completion: @escaping ([Person]?) -> Void){
        let ref = DBRef.person.reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    var users = [Person]()
                    for snap in snapshot {
                        if let dict = snap.value as? [String : Any] {
                            let nomination = Person(dict: dict)
                            if !users.contains(nomination) {
                                users.append(nomination)
                            }
                        }
                    }
                    completion(users)
                } else {
                    completion([])
                }
            } else {
                completion([])
            }
        }
    }
    
    // MARK: Search Person
    class func searchUsers(query: String, ref: NSInteger, completion: @escaping ([Person]) -> Void) {
       /* var completionHandler: (([String : Any]?, Error?) -> ())!
        let que = Query(query: query)
        if query != "" {
            guard query.count >= 25 else {
                return
            }
            completionHandler = { (content: [String : Any]?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    completion([])
                    return
                }
                let hits = content!["hits"] as? [Any] ?? []
                print(hits)
                if hits.count != 0 {
                    var searches = [Person]()
                    for hit in hits {
                        let hit = hit as! [String : Any]
                        let item = Person(dict: hit)
                        if !searches.contains(item) {
                            searches.insert(item, at: 0)
                        }
                    }
                    completion(searches)
                } else {
                    completion([])
                }
                /*if let cursor = content!["cursor"] as? String {
                 cityIndex.browse(from: cursor, completionHandler: self.completionHandler)
                 print("Page 2")
                 } */
            }
            ref.browse(query: que, completionHandler: completionHandler)
            
        }*/
    }
    
    
    // MARK: - Check User Accepts for Nomination @ Signup
    func checkUserAccept(completion: @escaping ([Nominations]) -> Void) {
        let ref = DBRef.userNominatedAcceptList(phone: self.phone).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    var userNoms = [Nominations]()
                    for snap in snapshot {
                        if let dict = snap.value as? [String : Any] {
                            let nomination = Nominations(dict: dict)
                            if !userNoms.contains(nomination) {
                                userNoms.append(nomination)
                            }
                        }
                    }
                    completion(userNoms)
                } else {
                    completion([])
                }
            } else {
                completion([])
            }
        }
    }
    // MARK: - Add User to Algolia
    func addUserAlgolia(completion: @escaping (Error?) -> Void) {
//        let userAlgoliaRef = AlgoliaRef.users.reference()
//        userAlgoliaRef.addObject(self.toDictionary(), withID: self.uid, requestOptions: nil) { (user, error) in
//            completion(error)
//        }
        
    }
    
    // Sudesh
    // MARK: - Add User to Firestore
    func addUserFirestore(completion: @escaping (Error?) -> Void){
        let dbUserRef = DBRef.nominations.reference()
        dbUserRef.setValue(self.toDictionary())
        completion(nil)
    }
    
    // MARK: - Update Past User to Admin User and Put in Pending
    func updateAdminUser() {
        let adminPending = DBRef.spec_admin_pending(region: self.region, uid: self.uid).reference()
        adminPending.setValue(self.toDictionary())
    }
    
    // MARK: - Check for read legal
    class func checkLegal(uid: String, completion: @escaping (Bool) -> Void) {
        let ref = DBRef.legal(uid: uid).reference()
        ref.observe(.value) { (agreeLegal) in
            if agreeLegal.exists() {
                let bool = agreeLegal.value as? Bool ?? true
                completion(bool)
            } else {
                completion(true)
            }
        }
    }
    // MARK: - Creating Badge / Monitor
    func badgeGeneralSaveCheck(completion: @escaping (Bool) -> Void) {
        let ref = DBRef.userBadge(phone: self.phone).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                ref.setValue(0)
                completion(false)
            }
        }
    }
    class func adminBadgeSubtractBadge(region: String, completion: @escaping (Error?) -> Void) {
        let ref = DBRef.adminBadge(region: region).reference()
        ref.runTransactionBlock({ (updated) -> TransactionResult in
            let val = updated.value as? Int ?? 0
            if val != 0 {
                updated.value = val - 1
            }
            return TransactionResult.success(withValue: updated)
        }, andCompletionBlock: { (error, complete, ref) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            if complete {
                completion(nil)
            }
        }, withLocalEvents: false)
    }
    func subtractBadge(completion: @escaping (Error?) -> Void) {
        let ref = DBRef.userBadge(phone: self.phone).reference()
        ref.runTransactionBlock({ (updated) -> TransactionResult in
            let val = updated.value as? Int ?? 0
            if val != 0 {
                updated.value = val - 1
            }
            return TransactionResult.success(withValue: updated)
        }, andCompletionBlock: { (error, complete, ref) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            if complete {
                completion(nil)
            }
        }, withLocalEvents: false)
    }
    func observeBadge(completion: @escaping (Int) -> Void) {
        let ref = DBRef.userBadge(phone: self.phone).reference()
        ref.observe(.value) { (snapshot) in
            let badge = snapshot.value as? Int ?? 0
            completion(badge)
        }
    }
    // MARK: - Save Profile Picture
    func saveProfilePicture(imageClass: ImageSaving, completion: @escaping (Error?, String?) -> Void) {
        imageClass.saveProfPic(userUID: self.uid) { (error, url) in
            completion(error, url)
        }
    }
    // MARK: - Download Profile Picture
    func getProfilePicture(completion: @escaping (UIImage?, Error?) -> Void) {
        ImageSaving.downloadProfilePicture(self.uid, url: self.profilePictureURL) { (image, error) in
            completion(image, error as NSError?)
        }
    }
    class func getProfilePicture(uid: String, url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        ImageSaving.downloadProfilePicture(uid, url: url) { (image, error) in
            completion(image, error as NSError?)
        }
    }
    // MARK: - Last Viewed Nomination
    // ----> Used in the case of needed an account to Vote for a user
    // ----> Returns Nomination UID
    func observeLastViewed(completion: @escaping (String?) -> Void) {
        let ref = DBRef.userPreNomination(uid: self.uid).reference()
        ref.observe(.value) { (snapshot) in
            let lastNom = snapshot.value as? String ?? "none"
            if lastNom != "none" {
                completion(lastNom)
            } else {
                completion(nil)
            }
        }
    }
    func saveLastViewed(nomUID: String) {
        let ref = DBRef.userPreNomination(uid: self.uid).reference()
        ref.setValue(nomUID)
    }
    
    // MARK: - Nomination Category
    // Get Last Nomination Category For Filters
    func observeLastNominationCategory(completion: @escaping (String) -> Void) {
        DBRef.userLastNomCategory(uid: self.uid).reference().observe(.value) { (snapshot) in
            let snapshot = snapshot.value as? String ?? FilterStrings.all_category.id
            completion(snapshot)
        }
    }
    // Save Last Nomination Category For Filters
    func saveLastNominationCategory(category: String) {
        let ref = DBRef.userLastNomCategory(uid: self.uid).reference()
        ref.setValue(category)
    }
    
    // MARK: - Award Category
    // Get Last Award Category For Filters
    func observeLastAwardCategory(completion: @escaping (String) -> Void) {
        DBRef.userLastAwardCategory(uid: self.uid).reference().observe(.value) { (snapshot) in
            let snapshot = snapshot.value as? String ?? FilterStrings.all_category.id
            completion(snapshot)
        }
    }
    // Save Last Award Category For Filters
    func saveLastAwardCategory(category: String) {
        let ref = DBRef.userLastAwardCategory(uid: self.uid).reference()
        ref.setValue(category)
    }
    
    // MARK: - Nomination Location
    // Get Last Nomination Location For Filters
    func observeLastNominationLocation(completion: @escaping (Cities) -> Void) {
        DBRef.userLastNomLocation(uid: self.uid).reference().observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? [String : Any] {
                let city = Cities(dict: snapshot)
                completion(city)
            } else {
                let popularCity = Cities(cluster: "000", cityState: "Popular")
                completion(popularCity)
            }
        }
    }
    // Save Last Nomination Location For Filters
    func saveLastNominationLocation(city: Cities) {
        let ref = DBRef.userLastNomLocation(uid: self.uid).reference()
        ref.setValue(city.toDictionary())
    }
    
    // MARK: - Award Location
    // Get Last Award Location For Filters
    func observeLastAwardLocation(completion: @escaping (Cities) -> Void) {
        DBRef.userLastAwardLocation(uid: self.uid).reference().observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? [String : Any] {
                let city = Cities(dict: snapshot)
                completion(city)
            } else {
                let popularCity = Cities(cluster: "000", cityState: "Popular")
                completion(popularCity)
            }
        }
    }
    // Save Last Award Location For Filters
    func saveLastAwardLocation(city: Cities) {
        let ref = DBRef.userLastAwardLocation(uid: self.uid).reference()
        ref.setValue(city.toDictionary())
    }
    
    // MARK: - Receipts Saving Votes
    func saveVoteReceipt(rec: Reciepts, completion: @escaping (Error?) -> Void) {
        let ref = DBRef.userVotesReciepts(uid: self.uid).reference()
        let totalRef = DBRef.totalUserVotes(uid: self.uid).reference()
        totalRef.runTransactionBlock({ (updated) -> TransactionResult in
            let val = updated.value as? Int ?? 0
            updated.value = val + rec.amount
            return TransactionResult.success(withValue: updated)
            
        }, andCompletionBlock: { (error, complete, snapshot) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            if complete {
                ref.child(rec.uid).setValue(rec.toDictionary())
                completion(nil)
            }
        }, withLocalEvents: false)
    }
    // MARK: - Receipts Saving Nominations
    func saveNomReceipt(rec: Reciepts, completion: @escaping (Error?) -> Void) {
        let totalRef = DBRef.totalUserNoms(uid: self.uid).reference()
        let ref = DBRef.userNomReciepts(uid: self.uid).reference()
        totalRef.runTransactionBlock({ (updated) -> TransactionResult in
            let val = updated.value as? Int ?? 0
            updated.value = val + rec.amount
            return TransactionResult.success(withValue: updated)
        }, andCompletionBlock: { (error, complete, snapshot) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            if complete {
                ref.child(rec.uid).setValue(rec.toDictionary())
                completion(nil)
            }
        }, withLocalEvents: false)
    }
    // MARK: - Save User Nomination --> Completion to see if Nomination has already been created for User
    func saveUserNomination(nominatedUser: UserNominations, completion: @escaping (Bool) -> Void) {
        let nomRef = DBRef.userNom(uid: self.uid, nomUID: nominatedUser.nomineePhone).reference()
        nomRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                nomRef.setValue(nominatedUser.toDictionary())
                completion(false)
            }
        }
    }
    // MARK: - Save User Vote
    func saveUserVotes(votedUser: UserVotes, completion: @escaping (Error?, Int?) -> Void) {
        let nomRef = DBRef.userVote(uid: self.uid, nomUID: votedUser.nominationUID).reference()
        nomRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.transactUserVotes(nomRef: nomRef, voteNumber: votedUser.totalVotes, completion: { (error, votes) in
                    completion(error, votes)
                })
            } else {
                nomRef.setValue(votedUser.toDictionary())
                completion(nil, votedUser.totalVotes)
            }
        }
    }
    // If vote profile already exists this transacts information to the total
    func transactUserVotes(nomRef: DatabaseReference, voteNumber: Int, completion: @escaping (Error?, Int?) -> Void) {
        nomRef.child("total").runTransactionBlock({ (updated) -> TransactionResult in
            let val = updated.value as? Int ?? 0
            updated.value = val + voteNumber
            return TransactionResult.success(withValue: updated)
        }, andCompletionBlock: { (error, complete, snapshot) in
            guard error == nil else {
                completion(error, nil)
                print(error!.localizedDescription)
                return
            }
            if complete {
                let vote = snapshot?.value as? Int ?? 0
                completion(nil, vote)
            }
        }, withLocalEvents: false)
    }
    // MARK: - Observe Notifications
    func observeNotificatons(completion: @escaping ([GoldenNotifications]) -> Void) {
        let ref = DBRef.notifications(phone: self.phone).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [DataSnapshot] {
                var objs = [GoldenNotifications]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let obj = GoldenNotifications(dict: dict)
                        if !objs.contains(obj) {
                            objs.append(obj)
                        }
                    }
                }
                completion(objs)
            } else {
                completion([])
            }
        }
    }
    func observeAdminNotifications(completion: @escaping ([GoldenNotifications]) -> Void) {
        let ref = DBRef.admin_notifications(region: self.region).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [DataSnapshot] {
                var objs = [GoldenNotifications]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let obj = GoldenNotifications(dict: dict)
                        if !objs.contains(obj) {
                            objs.append(obj)
                        }
                    }
                }
                completion(objs)
            } else {
                completion([])
            }
        }
    }
    // MARK: - Observe User Votes
    func observeUserVotes(completion: @escaping ([UserVotes]) -> Void) {
        let ref = DBRef.userVotes(uid: self.uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [DataSnapshot] {
                var objs = [UserVotes]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let obj = UserVotes(dict: dict)
                        if !objs.contains(obj) {
                            objs.append(obj)
                        }
                    }
                }
                completion(objs)
            } else {
                completion([])
            }
        }
    }
    // MARK: - Observe User Nominations
    func observeUserNominations(completion: @escaping ([UserNominations]) -> Void) {
        let ref = DBRef.userNoms(uid: self.uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [DataSnapshot] {
                var objs = [UserNominations]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let obj = UserNominations(dict: dict)
                        if !objs.contains(obj) {
                            objs.append(obj)
                        }
                    }
                }
                completion(objs)
            } else {
                completion([])
            }
        }
    }
    // MARK: - Observe User Nominated <-- This user got nominated and appended once accepted by an admin
    func observeUserNominated(completion: @escaping ([UserNominee]) -> Void) {
        let ref = DBRef.userNominatedAcceptList(phone: self.phone).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.value as? [DataSnapshot] {
                var objs = [UserNominee]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let obj = UserNominee(dict: dict)
                        if !objs.contains(obj) {
                            objs.append(obj)
                        }
                    }
                }
                completion(objs)
            } else {
                completion([])
            }
        }
    }
    // MARK: - Save Charity Nomination with Address
    func saveCharityNomination(userNominee: UserNominee, completion: @escaping (Error?) -> Void) {
        let ref = DBRef.userNominatedCharityList(uid: self.uid).reference()
         
        ref.setValue(userNominee.toDictionary()) { (error, _) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            completion(nil)
        }
    }
    
    
    // MARK: - Check User Existence ---> Used with Phone Number because of Anonymous Authentication, if exists returns UID
    class func checkUserExist(phone: String, completion: @escaping (Bool, String?) -> Void) {
        let ref = DBRef.userPhoneNumber(phoneNumber: phone).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let uid = snapshot.value as? String ?? "none"
                completion(true, uid)
            } else {
                completion(false, nil)
            }
        }
    }
    // MARK: - Load Current Person From Firebase Based on Authed UID
    class func loadCurrentPerson(uid: String, completion: @escaping (String?, Person?) -> Void) {
        DBRef.user(uid: uid).reference().observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let person = Person(dict: dict)
                Authorize.instance.subscribe(user: person)
                completion(nil, person)
            } else {
                completion("Error Loading User", nil)
            }
        }
    }
    
    // MARK: - Save Current Person To Firebase Based on Authed UID
    
    class func saveCurrentPerson(uid: String, person: Person, completion: @escaping (Bool?, String?, Person?) -> Void) {
        let dict = ["acctType": person.acctType,
                   "admin": person.admin,
                   "adminDescription": person.adminDescription,
                   "adminStage": person.adminStage,
                   "banned": person.banned,
                   "cityState": person.cityState,
                   "email": person.email,
                   "fullName": person.fullName,
                   "isSponsor": person.isSponsor,
                   "noms": person.purchasedNoms,
                   "phone": person.phone,
                   "region": person.region,
                   "uid": person.uid,
                   "url": person.profilePictureURL,
                   "uuid": person.uuid,
                   "votes": person.purchasedVotes,
                   "address": person.address
            ] as [String : Any]
        DBRef.user(uid: uid).reference().updateChildValues(dict, withCompletionBlock: {(error, response) in
            if error == nil {
                let person = Person(dict: dict)
                Authorize.instance.subscribe(user: person)
                completion(true, "Update the address successfully.", person)
            } else {
                completion(false, error?.localizedDescription, nil)
            }
        })
    }
    
    
    
    
    
    
    
}
