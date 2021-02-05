//
//  Nominations.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftKeychainWrapper
//import AlgoliaSearch
import AFDateHelper


var globleDocumentID : String?


extension Int {
    
    var seconds: Int {
        return self
    }
    
    var minutes: Int {
        return self.seconds * 60
    }
    
    var hours: Int {
        return self.minutes * 60
    }
    
    var days: Int {
        return self.hours * 24
    }
    
    var weeks: Int {
        return self.days * 7
    }
    
    var months: Int {
        return self.weeks * 4
    }
    
    var years: Int {
        return self.months * 12
    }
}


enum VotesAction{
    case delete
    case get
    case set
    
    public var id:String{
        switch self {
        case .delete:
            return "delete"
        case .get:
            return "get"
        case .set:
            return "set"
        }
    }
}

class Nominations {
    
    let uid: String
    var nominee: Person
    var anonoymous: Bool
    var nominatedBy: Person
    var numberOfVotes: Int
    var region: String
    var cityState: String
    var endDate: Double // This is a formatted date EX) xx/xx/xxxx:0-24 <--- This is military time for the hour it ends
    var startDate: Double
    var finished: Bool
    var category: String
    var story: String
    var urls: [String]
    var imgUIDS: [String]
    var adminApproved: Bool
    var userApproved: Bool
    var phase: Int
    
    var edited: Bool
    var charityAdded: Bool
    var charityDone: Bool!
    
    var nomineeAddress: String!
    var charity: Charity!
    
    var amountDonated: Int!
    var awardType: String!
    
    var keychain = KeychainWrapper.standard
    
    var searchCode: String
    
    init(nominee: Person, anon: Bool, nominatedBy: Person, endDate: Double, urls: [String], category: String, region: String, cityState: String, story: String, imgUIDS: [String], phase: Int, edited: Bool, charityAdded: Bool, charity: Charity, uid : String, searchCode: String) {
        self.nominee = nominee
        self.anonoymous = anon
        self.nominatedBy = nominatedBy
        self.endDate = endDate
        self.category = category
        self.story = story
        self.numberOfVotes = 0
        self.finished = false
        self.urls = urls
        self.startDate = Date().timeIntervalSince1970
        self.region = region
        self.imgUIDS = imgUIDS
        self.cityState = cityState
        let id = DBRef.nominations.reference().childByAutoId().key
        self.uid = id ?? "N/A"
        self.adminApproved = false
        self.userApproved = false
        self.phase = phase
        self.edited = edited
        self.charityAdded = charityAdded
        self.charity = charity
        self.searchCode = searchCode
    }
    
    init(dict: [String : Any]) {
        self.uid = dict["uid"] as? String ?? "N/A"
        self.anonoymous = dict["anon"] as? Bool ?? false
        self.region = dict["region"] as? String ?? "000"
        self.cityState = dict["cityState"] as? String ?? "N/A"
        self.imgUIDS = dict["imgUIDS"] as? [String] ?? []
        if let nominatedByDict = dict["nominatedBy"] as? [String : Any] {
            self.nominatedBy = Person(dict: nominatedByDict)
        } else {
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
            self.nominatedBy = Person(uid: NSUUID().uuidString, fullName: "Anonymous", acctType: "anon", profilePic: "N/A", email: "N/A", phone: "N/A", region: "000", cityState: "N/A", uuid: uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false, address: "")
        }
        if let nom = dict["nominee"] as? [String : Any] {
            self.nominee = Person(dict: nom)
        } else {
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
            self.nominee = Person(uid: NSUUID().uuidString, fullName: "Anonymous", acctType: "anon", profilePic: "N/A", email: "N/A", phone: "N/A", region: "000", cityState: "N/A", uuid: uuid, admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false, address: "")
        }
        self.category = dict["category"] as? String ?? ""
        self.urls = dict["urls"] as? [String] ?? []
        self.finished = dict["finished"] as? Bool ?? false
        self.endDate = dict["endDate"] as? Double ?? 0
        self.numberOfVotes = dict["votes"] as? Int ?? 0
        self.startDate = dict["startDate"] as? Double ?? 0
        self.adminApproved = dict["adminApproved"] as? Bool ?? false
        self.userApproved = dict["userApproved"] as? Bool ?? false
        self.story = dict["story"] as? String ?? "N/A"
        self.phase = dict["phase"] as? Int ?? 0
        
        if let charDict = dict["charity"] as? [String : Any] {
            self.charity = Charity(parsedDict: charDict)
        }
        self.nomineeAddress = dict["nomineeAddress"] as? String ?? "N/A"
        self.edited = dict["edited"] as? Bool ?? false
        self.charityAdded = dict["charityAdded"] as? Bool ?? false
        
        self.amountDonated = dict["amountDonated"] as? Int ?? 0
        self.awardType = dict["awardType"] as? String ?? "N/A"
        self.charityDone = dict["charityDone"] as? Bool ?? false
        self.searchCode = dict["searchCode"] as? String ?? ""
    }

    
    func toDictionary() -> [String : Any] {
        return [
            "uid": self.uid,
            "anon": self.anonoymous,
            "nominee": self.nominee.toDictionary(),
            "nominatedBy": self.nominatedBy.toDictionary(),
            "urls": self.urls,
            "imgUIDS": self.imgUIDS,
            "endDate": self.endDate,
            "startDate": self.startDate,
            "finished": self.finished,
            "category": self.category,
            "region": self.region,
            "cityState": self.cityState,
            "adminApproved": self.adminApproved,
            "userApproved": self.userApproved,
            "story": self.story,
            "votes": self.numberOfVotes,
            "phase": self.phase,
            "charity":self.charity.toDictionary(),
            "searchCode": self.searchCode
        ]
    }
    func toAlgDictionary() -> [String : Any] {
        if NominationPhase.phase_one.id == self.phase || NominationPhase.phase_three(changed: self.edited, charityReason: self.charityAdded, isAdmin: true).id == self.phase || NominationPhase.phase_four(isNominee: false).id == self.phase || NominationPhase.phase_six(adminDenied: true).id == self.phase {
            return [
                "uid": self.uid,
                "nominee": self.nominee.userAlgDict(),
                "region": self.region,
                "cityState": self.cityState,
                "startDate": self.startDate,
                "urls": self.urls,
                "category": self.category
                
            ]
        } else {
            return [
                "uid": self.uid,
                "nominee": self.nominee.userAlgDict(),
                "amountDonated": self.amountDonated ?? 0,
                "charity": self.charity.toDictionary(),
                "region": self.region,
                "cityState": self.cityState,
                "startDate": self.startDate,
                "category": self.category,
                "nomineeAddress": self.nomineeAddress
            ]
        }
    }
    // MARK: - TO BE USED WHEN NOMINATION IS CREATED FOR NOMINATION SPONSORS
    func save(notification: GoldenNotifications, completion: @escaping (Error?) -> Void) {
        //let firebaseCheckRef = DBRef.nominationCheck(nomUID: self.uid).reference()
        let firebaseCountRef = DBRef.nom_count(uid: self.uid).reference()
        let notificationQueryRef = DBRef.notification_query(phone: notification.targetPhone).reference()
        let firestoreRef = FireRef.admin_nominations(uid: self.uid).reference()
        firestoreRef.setData(self.toDictionary()) { (error) in
            guard error == nil else {
                completion(error)
                return
            }
            firebaseCountRef.setValue(0)
            //firebaseCheckRef.setValue(true)
            notificationQueryRef.setValue(notification.toDictionary())
            completion(nil)
        }
    }
}
enum AwardType {
    
    case bronze
    case silver
    case gold
    
    
    var str: String {
        switch self {
        case .bronze:
            return "bronze"
        case .silver:
            return "silver"
        case .gold:
            return "gold"
        }
    }
    
    
}
class UserAcceptNominee {
    
}
class UserNominee {
    
    var nominatedByName: String
    var nominatedByUID: String
    var nominationUID: String
    var status: String
    var phase: Int
    var category: String
    var charityEIN: String
    var charityName: String
    var charityAddress: String
    var fullNomineeAddress: String
    
    init(nomByName: String, nomByUID: String, nominationUID: String, status: String, category: String, charityEIN: String, charityName: String, charityAddress: String, fullNomineeAddress: String, phase: Int) {
        self.nominatedByName = nomByName
        self.nominatedByUID = nomByUID
        self.nominationUID = nominationUID
        self.status = status
        self.category = category
        self.charityEIN = charityEIN
        self.charityName = charityName
        self.charityAddress = charityAddress
        self.fullNomineeAddress = fullNomineeAddress
        self.phase = phase
    }
    
    init(dict: [String : Any]) {
        self.nominatedByName = dict["nomByName"] as? String ?? "N/A"
        self.nominatedByUID = dict["nomByUID"] as? String ?? "N/A"
        self.nominationUID = dict["nomUID"] as? String ?? "N/A"
        self.status = dict["status"] as? String ?? "N/A"
        self.category = dict["category"] as? String ?? FilterStrings.all_category.id
        self.charityEIN = dict["charityEIN"] as? String ?? "N/A"
        self.fullNomineeAddress = dict["nomineeAddress"] as? String ?? "N/A"
        self.charityName = dict["charityName"] as? String ?? "N/A"
        self.charityAddress = dict["charityAddress"] as? String ?? "N/A"
        self.phase = dict["phase"] as? Int ?? 0
    }
    func toDictionary() -> [String : Any] {
        return [
            "nomByName": self.nominatedByName,
            "nomByUID": self.nominatedByUID,
            "nomUID": self.nominationUID,
            "status": self.status,
            "category": self.category,
            "charityEIN": self.charityEIN,
            "nomineeAddress": self.fullNomineeAddress,
            "charityName": self.charityName,
            "charityAddress": self.charityAddress,
            "phase": self.phase
        ]
    }
    
    func save(phone: String) {
        let ref = DBRef.userNominatedAcceptList(phone: phone).reference()
        ref.setValue(self.toDictionary())
    }
    func generateAwardType() {
        
    }
    func generateAmountDonated() {
        
    }
    class func observeNoms(phone: String, completion: @escaping ([UserNominee]) -> Void) {
        let ref = DBRef.userNominees(phone: phone).reference()
        ref.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var noms = [UserNominee]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let nom = UserNominee(dict: dict)
                        if !noms.contains(nom) {
                            noms.append(nom)
                        }
                    }
                }
                completion(noms)
            } else {
                completion([])
            }
        }
    }
    class func fetch(phone: String, completion: @escaping ([UserNominee]) -> Void) {
        let ref = DBRef.userNominees(phone: phone).reference()
        ref.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var nominees = [UserNominee]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let nomin = UserNominee(dict: dict)
                        if !nominees.contains(nomin) {
                            nominees.append(nomin)
                        }
                    }
                }
                completion(nominees)
                
            } else {
                completion([])
            }
        }
    }
    class func getOne(phone: String, nomUID: String, completion: @escaping (UserNominee?) -> Void) {
        let ref = DBRef.userNominees(phone: phone).reference().child(nomUID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let userNomineee = UserNominee(dict: dict)
                completion(userNomineee)
            } else {
                completion(nil)
            }
        }
    }
}
extension UserNominee: Equatable { }

func ==(lhs: UserNominee, rhs: UserNominee) -> Bool {
    return lhs.nominationUID == rhs.nominationUID
}
class UserNominations {
    
    var nomineePhone: String
    var nomineeEmail: String
    var nomineeName: String
    var nomineeUID: String
    var nomineeURL: String
    var nominationUID: String
    var nominatedByUID: String
    var status: String // "Pending" "Live"
    var category: String
    var phase: Int
    
    init(nomineePhone: String, nomineeName: String, nomineeEmail: String, nomUID: String, status: String, nominatedByUID: String, nomineeUID: String, nomineeURL: String, category: String, phase: Int) {
        self.nomineePhone = nomineePhone
        self.nomineeName = nomineeName
        self.nomineeEmail = nomineeEmail
        self.nominationUID = nomUID
        self.status = status
        self.nominatedByUID = nominatedByUID
        self.nomineeUID = nomineeUID
        self.nomineeURL = nomineeURL
        self.category = category
        self.phase = phase
    }
    
    init(dict: [String : Any]) {
        self.nomineePhone = dict["nomineePhone"] as? String ?? "N/A"
        self.nomineeName = dict["nomineeName"] as? String ?? "N/A"
        self.nomineeEmail = dict["nomineeEmail"] as? String ?? "N/A"
        self.nominationUID = dict["nomUID"] as? String ?? "N/A"
        self.status = dict["status"] as? String ?? "pending"
        self.nominatedByUID = dict["nominatedByUID"] as? String ?? "N/A"
        self.nomineeURL = dict["nomineeURL"] as? String ?? "N/A"
        self.nomineeUID = dict["nomineeUID"] as? String ?? "N/A"
        self.category = dict["category"] as? String ?? FilterStrings.head_category.id
        self.phase = dict["phase"] as? Int ?? 0
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "nomineePhone": self.nomineePhone,
            "nomineeName": self.nomineeName,
            "nomineeEmail": self.nomineeEmail,
            "nomUID": self.nominationUID,
            "status": self.status,
            "nominatedByUID": self.nominatedByUID,
            "nomineeURL": self.nomineeURL,
            "nomineeUID": self.nomineeUID,
            "category": self.category,
            "phase": self.phase
        ]
    }
    func save(completion: @escaping (Error?) -> Void) {
        let userNomRef = DBRef.userNom(uid: self.nominatedByUID, nomUID: self.nomineePhone).reference()
        let adminRef = FireRef.spec_nomination(uid: self.nominationUID).reference()
        userNomRef.setValue(self.toDictionary())
        adminRef.setData(self.toDictionary()) { (error) in
            completion(error)
        }
    }
    
    class func fetch(uid: String, completion: @escaping ([UserNominations]) -> Void) {
        let ref = DBRef.userNoms(uid: uid).reference()
        ref.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var userNoms = [UserNominations]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let userNom = UserNominations(dict: dict)
                        if !userNoms.contains(userNom) {
                            userNoms.append(userNom)
                        }
                    }
                }
                completion(userNoms)
            } else {
                completion([])
            }
        }
    }
    
}

extension UserNominations: Equatable { }

func ==(lhs: UserNominations, rhs: UserNominations) -> Bool {
    return lhs.nominationUID == rhs.nominationUID
}
class Votes {
    
    var nomUID: String
    var nomineeName: String
    var nomineeUID: String
    var nomineeURL: String
    var charityName: String
    var category: String
    var numberOfVotes: Int
    var endDate: Double
    var isNomRef: DatabaseReference
    
    init(nomUID: String, nomName: String, nomineeUID: String, nomineeURL: String, charityName: String, category: String, numberOfVotes: Int, endDate: Double) {
        self.nomUID = nomUID
        self.nomineeName = nomName
        self.nomineeURL = nomineeURL
        self.charityName = charityName
        self.category = category
        self.numberOfVotes = numberOfVotes
        self.nomineeUID = nomineeUID
        self.isNomRef = DBRef.nominationCheck(nomUID: self.nomUID).reference() // false nom, award true
        self.endDate = endDate
    }
    
    init(dict: [String : Any]) {
        self.nomUID = dict["nomUID"] as? String ?? "N/A"
        self.nomineeName = dict["nomineeName"] as? String ?? "N/A"
        self.nomineeUID = dict["nomineeUID"] as? String ?? "N/A"
        self.nomineeURL = dict["nomineeURL"] as? String ?? "N/A"
        self.charityName = dict["chartiyName"] as? String ?? "N/A"
        self.category = dict["category"] as? String ?? "N/A"
        self.numberOfVotes = dict["votesFor"] as? Int ?? 1
        self.endDate = dict["endDate"] as? Double ?? 0
        self.isNomRef = DBRef.nominationCheck(nomUID: self.nomUID).reference()
    }
    
    
    func toDictionary() -> [String : Any] {
        return [
            "nomUID": self.nomUID,
            "nomineeName": self.nomineeName,
            "nomineeUID": self.nomineeUID,
            "nomineeURL": self.nomineeURL,
            "charityName": self.charityName,
            "category": self.category,
            "votesFor": self.numberOfVotes,
            "endDate": self.endDate
        ]
    }
    
    func findIfAward(completion: @escaping (Bool) -> Void) {
        self.isNomRef.observeSingleEvent(of: .value) { (snapshot) in
            let isAward = snapshot.value as? Bool ?? false
            completion(isAward)
        }
    }
    class func observeVotes(uid: String, completion: @escaping ([Votes]) -> Void) {
        let ref = DBRef.userVotes(uid: uid).reference()
        ref.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var votes = [Votes]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let vote = Votes(dict: dict)
                        if !votes.contains(vote) {
                            votes.append(vote)
                        }
                    }
                }
                completion(votes)
            } else {
                completion([])
            }
        }
    }
}
extension Votes: Equatable { }

func ==(lhs: Votes, rhs: Votes) -> Bool {
    return lhs.nomUID == rhs.nomUID
}

extension Nominations {
    
    // MARK: - Save Nomination Photo
    func saveNominationPhoto(imageSaver: ImageSaving, pictureNumber: Int, completion: @escaping (Error?, String?, String?) -> Void) {
        
    }
    // MARK: - Load Donated Nomination
    class func loadDonatedNom(uid: String, completion: @escaping (Int) -> Void) {
        let ref = DBRef.nom_donated(uid: uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let amount = snapshot.value as? Int ?? 0
            completion(amount)
        }
    }
    // MARK: - Load Votes Count
    class func loadVotesNom(uid: String, completion: @escaping (Int) -> Void) {
        let ref = DBRef.nom_count(uid: uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let amount = snapshot.value as? Int ?? 0
            completion(amount)
        }
    }
    //=====Loading nomination or say campaign votes count
    
    func getAndSetVotesForParticulerNomination(action:String, uid: String , vote:Int, completion: @escaping (Int) -> Void){
        
       // let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            
                            let nom = Nominations(dict: d.data())
                            var totalVotes = nom.numberOfVotes
                            
                            if action == VotesAction.get.id {
                                completion(totalVotes)
                            }else{
                                totalVotes += vote
                                docRef.updateData(["votes": totalVotes])
                                completion(totalVotes)
                            }
                        }
                    }
                }
            }
            //completion(totalVotes)
            //completion(0)
        //}
        //DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
    }

//    func loadPhotos(imgUID: String, completion: @escaping (Error?, UIImage?) -> Void) {
//        let key = Keys.nom_pics(url: imgUID).key
//        if let data = keychain.data(forKey: key) {
//            let img = UIImage(data: data)
//            completion(nil, img)
//        } else {
//            ImageSaving.downloadNominationPicture(imgUID) { (image, error) in
//                guard error == nil else {
//                    completion(error, nil)
//                    print(error!.localizedDescription)
//                    return
//                }
//                completion(nil, image)
//            }
//        }
//
//    }
    // MARK: - Load Specific Nomination
    class func loadSpecNom(uid: String, completion: @escaping (Nominations?, Error?) -> Void) {
        let ref = FireRef.spec_nomination(uid: uid).reference()
        ref.getDocument { (snapshot, error) in
            guard error == nil else {
                completion(nil, error)
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot?.data() {
                let nomin = Nominations(dict: snapshot)
                completion(nomin, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    class func loadSpecAdminNom(uid: String, completion: @escaping (Nominations?, Error?) -> Void) {
        let ref = FireRef.admin_nominations(uid: uid).reference()
        ref.getDocument { (snapshot, error) in
            guard error == nil else {
                completion(nil, error)
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot?.data() {
                let nomin = Nominations(dict: snapshot)
                completion(nomin, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    // MARK: - Finish when inAPP purchase is finished
    func saveVote(user: Person, votes: Int, completion: @escaping (Error?) -> Void) {
        let userVotes = UserVotes(nomUID: self.uid, nomineeName: self.nominee.fullName, nomineeCategory: self.category, totalVotes: votes)
        let ref = DBRef.nom_votes(uid: self.uid, voterUID: user.uid).reference()
        let countRef = DBRef.nom_count(uid: self.uid).reference()
        countRef.runTransactionBlock({ (updated) -> TransactionResult in
            let val = updated.value as? Int ?? 0
            updated.value = val + votes
            return TransactionResult.success(withValue: updated)
        }, andCompletionBlock: { (error, complete, snapshot) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            if complete {
                user.saveUserVotes(votedUser: userVotes, completion: { (error, userVotes) in
                    guard error == nil else {
                        completion(error)
                        print(error!.localizedDescription)
                        return
                    }
                    if userVotes != nil {
                        ref.setValue(userVotes)
                        completion(nil)
                    } else {
                        ref.setValue(votes)
                        completion(nil)
                    }
                })
            }
        }, withLocalEvents: false)
    }
    // MARK: - Check if nomination exists
    func checkNominationExist(completion: @escaping (Bool) -> Void) {
        let ref = DBRef.nominationCheck(nomUID: self.uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Sudesh Get firestore nomination region
    class func getNominationsRegionFromDB(region: String, awards: Bool, category: String, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = DBRef.nominations.reference()
        if category == FilterStrings.all_category.id {
            ref.queryOrdered(byChild: "userApproved")
                .queryEqual(toValue: true)
                .observe(.value, with: { (snapshot: DataSnapshot) in
                    print(snapshot.childrenCount)
                    for snap in snapshot.children {
                        print((snap as! DataSnapshot).key)
                    }
                })
        } else {
           
        }
        
    }
    
    class func getPendingListWhereImNomineeWithEmail(email:String, phone:String, completion: @escaping (Error?, [Nominations]) -> Void){
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("userApproved", isEqualTo: false).getDocuments { (snapshot, error) in
            guard error == nil else {
                completion(error, [])
                print(error!.localizedDescription)
                return
            }
            if let data = snapshot?.documents {
                var nominations = [Nominations]()
                for d in data {
                    let nomination = Nominations(dict: d.data())
                    let nomineeEmail = nomination.nominee.email
                    let nominatorEmail = nomination.nominatedBy.email
                   
                    if nomineeEmail == email || nominatorEmail == email {
//                        if !nominations.contains(nomination) {
                            nominations.append(nomination)
//                        }
                    } else {
                        let nomineePhone = nomination.nominee.phone
                        let nominatorPhone = nomination.nominatedBy.phone

                        if nomineePhone == phone || nominatorPhone == phone {
                            if !nominations.contains(nomination) {
                                nominations.append(nomination)
                            }
                        }
                    }
                    
                }
            
                completion(nil, nominations)
            } else {
                completion(nil, [])
            }
        }
        
    }
    class func getPendingListWhereImNominee(uid:String, completion: @escaping (Error?, [Nominations]) -> Void){
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("userApproved", isEqualTo: false).getDocuments { (snapshot, error) in
            guard error == nil else {
                completion(error, [])
                print(error!.localizedDescription)
                return
            }
            if let data = snapshot?.documents {
                var nominations = [Nominations]()
                for d in data {
                    let nomination = Nominations(dict: d.data())
                    let nomineeUid = nomination.nominee.uid
                    if nomineeUid == uid {
                        if !nominations.contains(nomination) {
                            nominations.append(nomination)
                        }
                    }
                }
                completion(nil, nominations)
            } else {
                completion(nil, [])
            }
        }
        
    }
    
    class func getAllAdminPendingNomination(completion: @escaping (Error?, [Nominations]) -> Void){
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("adminApproved", isEqualTo: false).whereField("userApproved", isEqualTo: true).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                print(noms.count)
                completion(error, noms)
            })
        }
    }
    
    class func getAllPendingNomination(completion: @escaping (Error?, [Nominations]) -> Void){
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("userApproved", isEqualTo: false).whereField("adminApproved", isEqualTo: false).whereField("finished", isEqualTo: false).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
    
    class func getAllNomination(completion: @escaping (Error?, [Nominations]) -> Void){
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: false).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
    class func getAllNominations(region: String, awards: Bool, category: String, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        if category == FilterStrings.all.id || category == "Categories"{
            ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: awards).getDocuments { (snapshot, error) in
                Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                    completion(error, noms)
                })
            }
        }else{
            ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: awards).whereField("category", isEqualTo: category).getDocuments { (snapshot, error) in
                Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                    completion(error, noms)
                })
            }
        }
        
    }
    
    class func getNominationsRegion(region: String, awards: Bool, category: String, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        if category == FilterStrings.all_category.id {
            ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: awards).getDocuments { (snapshot, error) in
                Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                    completion(error, noms)
                })
            }
        } else {
            ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: awards).whereField("category", isEqualTo: category).getDocuments { (snapshot, error) in
                
                Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                    completion(error, noms)
                })
            }
        }
        
    }
    
    class func getNominationsHigh(awards: Bool, category: String, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()

        if category == FilterStrings.all_category.id {
            ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: awards).getDocuments { (snapshot, error) in
                Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                    completion(error, noms)
                })
            }
        } else {
            ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: awards).whereField("category", isEqualTo: category).getDocuments { (snapshot, error) in
                Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                    completion(error, noms)
                })
            }
        }
    }
    
    //get all charity done/pending nomination
    // get all finished nomination
    class func getAllCharityNomination(status:Bool, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        
        ref.whereField("charityDone", isEqualTo: status).whereField("finished", isEqualTo: status).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
    
    class func getAllCharityNominationWithCharityDoneFalse(status:Bool, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        
        ref.whereField("charityDone", isEqualTo: false).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
    class func getAllCharityNominationWithCharityDoneTrue(status:Bool, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("charityDone", isEqualTo: true).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
    // get all finished nomination
    class func getAllFinishedNomination(completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).whereField("finished", isEqualTo: true).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
    
    // MARK: - Will use Algolia
    class func runSearch(predicate: NSPredicate, completion: @escaping (Error?, [Nominations]) -> Void) {
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("userApproved", isEqualTo: true).whereField("adminApproved", isEqualTo: true).filter(using: predicate).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    class func handleInnerSnapshot(snapshot: QuerySnapshot?, error: Error?, completion: @escaping (Error?, [Nominations]) -> Void) {
        guard error == nil else {
            completion(error, [])
            print(error!.localizedDescription)
            return
        }
        if let data = snapshot?.documents {
            
            var nominations = [Nominations]()
            for d in data {
                
                globleDocumentID = d.documentID
                
                let nomination = Nominations(dict: d.data())
                print(nomination.category)
                if !nominations.contains(nomination) {
//                    if nomination.endDate > 0 {
                        nominations.append(nomination)
//                    }
                }
            }

            nominations.sort(by: {$0.nominee.fullName < $1.nominee.fullName})
            completion(nil, nominations)
        } else {
            completion(nil, [])
        }
    }
    class func filterNominationsHighToLow(nominations: [Nominations], completion: @escaping ([Nominations]) -> Void) {
        var noms: [Nominations] = nominations
        noms.sort { $0.numberOfVotes > $1.numberOfVotes }
        completion(noms)
    }
    
    func loadNomVotes(completion: @escaping (Int) -> Void) {
       // DBRef.nom_count(uid: self.uid).reference().observe(.value) { (snapshot) in
       //     let count = snapshot.value as? Int ?? 0
        //    completion(count)
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("uid", isEqualTo: self.uid).getDocuments { (snapshot, error) in
            if error == nil{
                if let vote = snapshot?.documents{
                    var singleRecord = vote[0]
                    let totalVote = singleRecord.get("votes") as! NSInteger
                    print(totalVote)
                    completion(totalVote)
                }
            }
        }
        
    }
    
    
    
    
    
    
}
extension Nominations {
    // MARK: Search Nominations and Awards
    class func searchNominationsAwards(query: String, ref: NSNumber, completion: @escaping ([Nominations]) -> Void) {
       /* var completionHandler: (([String : Any]?, Error?) -> ())!
        let que = Query(query: query)
        if query != "" {
            guard query.count <= 15 else {
                completion([])
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
                    var searches = [Nominations]()
                    for hit in hits {
                        let hit = hit as! [String : Any]
                        let item = Nominations(dict: hit)
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
            
        } */
    }
    
    
}
extension Nominations: Equatable { }

func ==(lhs: Nominations, rhs: Nominations) -> Bool {
    return lhs.uid == rhs.uid
}
extension Nominations: Comparable {
    static func <(lhs: Nominations, rhs: Nominations) -> Bool {
        return (lhs.startDate) > (rhs.startDate)
    }
}
class NomTimes {
    
    var ten: String
    var twenty: String
    var twentyFive: String
    var twentyNine: String
    var month: String
    
    init(date: Date) {
        self.ten = NominationTimes.ten_days.generateTime(trueStart: date)
        self.twenty = NominationTimes.twenty_days.generateTime(trueStart: date)
        self.twentyFive = NominationTimes.twenty_five_days.generateTime(trueStart: date)
        self.twentyNine = NominationTimes.twenty_nine_days.generateTime(trueStart: date)
        self.month = NominationTimes.one_month.generateTime(trueStart: date)
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "ten": ten,
            "twenty": twenty,
            "twentyFive": twentyFive,
            "twentyNine": twentyNine,
            "month": month
        ]
        
    }
    
}

enum NominationTimes {
    
    case ten_days
    case twenty_days
    case twenty_five_days
    case twenty_nine_days
    case one_month
    
    func generateTime(trueStart: Date) -> String {
        switch self {
        case .ten_days:
            let tenDays = trueStart.adjust(.day, offset: 10)
            let strTen = tenDays.toString(format: .standard)
            return strTen
        case .twenty_days:
            let twentyDays = trueStart.adjust(.day, offset: 20)
            print(twentyDays)
            let strTwenty = twentyDays.toString(format: .standard)
            return strTwenty
        case .twenty_five_days:
            let twentyFive = trueStart.adjust(.day, offset: 25)
            let strTwentyFive = twentyFive.toString(format: .standard)
            return strTwentyFive
        case .twenty_nine_days:
            let twentyNine = trueStart.adjust(.day, offset: 29)
            let strTwentyNine = twentyNine.toString(format: .standard)
            return strTwentyNine
        case .one_month:
            let one_month = trueStart.adjust(.month, offset: 1)
            let strMonth = one_month.toString(format: .standard) // ---> Becomes End Date!!!
            return strMonth
        }
        
        
        
        
    }
    
    
}




























