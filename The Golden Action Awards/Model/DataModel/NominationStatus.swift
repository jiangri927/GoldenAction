//
//  NominationStatus.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/19/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
//import AlgoliaSearch
import SearchTextField
import Firebase
import AFDateHelper


enum NominationPhase {
    case phase_one
    case phase_two(existing: Bool)
    case phase_three(changed: Bool, charityReason: Bool, isAdmin: Bool)
    case phase_four(isNominee: Bool)
    case phase_five(awardTitle: String, moneyDonated: Int, isNominee: Bool)
    case phase_six(adminDenied: Bool)
    
    var id: Int {
        switch self {
        case .phase_one:
            return 1
        case .phase_two:
            return 2
        case .phase_three(let changed, _, _):
            if changed {
                return 3
            } else {
                return 4
            }
        case .phase_four:
            return 4
        case .phase_five:
            return 5
        case .phase_six:
            return 6
        }
    }
    
    var status: String {
        switch self {
        case .phase_one:
            return "Awaiting Admin Approval"
        case .phase_two:
            return "Awaiting Nominee Approval"
        case .phase_three(let changed, let _, let _):
            if changed {
                return "Awaiting Admin Approval"
            } else {
                return "The nomination is now live!"
            }
        case .phase_four:
            return "The nomination is now live!"
        case .phase_five(let awardTitle, let moneyDonated, _):
            return "\(awardTitle) Action Award Coin, with $\(moneyDonated) donated!"
        case .phase_six(let adminDenied):
            if adminDenied {
                return "The nomination was denied by the admin, click to take action!"
            } else {
                return "The nomiantion was denied by the user, click to take action!"
            }
        }
    }
    func generateNotificationTitle(nomination: Nominations) -> String {
        switch self {
        case .phase_one: // Sent to Admin Only!!
            return nomination.nominatedBy.fullName
        case .phase_two: // Sent to Nominee and Nominator
            return "The Golden Action Awards Sponsors"
        case .phase_three: //Sent to Admin OR Nominator
            return "The Golden Action Awards Sponsors"
        case .phase_four: // Sent to Nominee and Nominator
            return "The Golden Action Awards Sponsors"
        case .phase_five:
            return "The Golden Action Awards Sponsors"
        case .phase_six(let adminDenied):
            if adminDenied {
                return "The Golden Action Awards Sponsors"
            } else {
                return nomination.nominee.fullName
            }
        }
    }
    func generateNotificationText(nomination: Nominations) -> String {
        switch self {
        case .phase_one:
            return "There is a new nomination in your area! Click here to expedite the process of this being seen and approve the notification! - 'dynamic link'"
            
        case .phase_two(let existing):
            // False sends to nominator!!
            if existing {
                if nomination.anonoymous {
                    return "An anonymous person has nominated you for a Golden Action Award in the \(nomination.category), click here to accept the nomination and allow your golden action to keep on spreading!"
                } else {
                    return "\(nomination.nominatedBy.fullName) has nominated you for a Golden Action Award in the \(nomination.category), click here to accept the nomination and allow your golden action to keep on spreading!"
                }
            } else {
                return "Your nomination has been accepted by The Golden Action Awards Sponsors, keep up to date with what your nominee says!"
            }
        case .phase_three(let changed, let charityReason, let isAdmin):
            if !changed {
                
                return "\(nomination.nominee.fullName) has accepted your nomination and it is now live, tell your friends and your friends friends. Make sure this Golden Action is noticed!"
            } else {
                // Back to admin!
                if charityReason {
                    if isAdmin {
                        return "\(nomination.nominee.fullName) has added a new charity to their nomination, check it out in the admin panel to enter the proper EIN information for this."
                    } else {
                        return "\(nomination.nominee.fullName) has added a new charity to their nomination, it is under one last round of approval!"
                    }
                    
                } else {
                    if isAdmin {
                        return "\(nomination.nominee.fullName) has edited their nomination, check it out in the nomination sponsor panel so the action can be seen!"
                    } else {
                        return "\(nomination.nominee.fullName) has edited their nomination, it is under one last round of approval!"
                    }
                }
            }
        case .phase_four(let isNominee):
            if isNominee {
                return "\(nomination.nominee.fullName), the nomination sponsors here at The Golden Action Awards have accepted your nomination, view it on the app!"
            } else {
                return "\(nomination.nominatedBy.fullName), the nomination sponsors here at The Golden Action Awards have accepted your nomination, view it on the app!"
            }
        case .phase_five(let awardTitle, let moneyDonated, let isNominee):
            if isNominee {
                return "You have been awarded the \(awardTitle) Action Award Coin, with $\(moneyDonated) donated! Congratulations on participating in the Golden Action Awards and giving back to non-profits across the United States. Expect in the mail a coin reflecting this very award! Rememeber, the best golden actions are repeated over and over again!"
            } else {
                if nomination.anonoymous {
                    return "\(awardTitle) Action Award Coin, with $\(moneyDonated) donated to \(nomination.charity!.charityName)! Congratulations on participating in the Golden Action Awards, nominating \(nomination.nominee.fullName), and being an amazing person. The people in the world don't like to be seen, your secret is safe with us!"
                } else {
                    return "\(awardTitle) Action Award Coin, with $\(moneyDonated) donated to \(nomination.charity!.charityName)! Congratulations on participating in the Golden Action Awards, nominating \(nomination.nominee.fullName), and being an amazing person."
                }
            }
        case .phase_six( _):
            return "Has denied your nomination, please edit and resubmit or delete and make a new nomination"
        }
        
    }
    
}
enum NominationStatus {
    
    case phase_one(nomination: Nominations, userNom: UserNominations, hasAccount: Bool) // Initial Creation of Nomination --> Sends to admin_nominations && userNoms && userPhoneNumber --> Notification to Admins in region!!!
    case phase_two(nomination: Nominations, existingUser: Bool) // Admin Approves --> Sends to userNominatedAccept, updates userNoms and deletes admin_nominations --> Notification to Nominator and Nominee
    case phase_three(userNominee: UserNominee, nomination: Nominations, changed: Bool, reasonCharity: Bool) // User Approves --> if changed == true Sends to admin_nominations and userNominees, updates userNoms and deletes userNominatedAccept notification to Admin and Nominator,else executes phase_four inside here
    
    case phase_four(nomination: Nominations, userNominee: UserNominee) // writes to Firestore Path, Algolia Path, nominationCheck path w/ false, nom_count path, starts crom job on this stage and says time remaining --> Notification on nominee and nominator
    case phase_five(award: Nominations) // Finished, becomes and award saves to algolia and deleted nomination/updates userNoms, userNominees, nominationCheck
    
    case phase_six(nomination: Nominations, adminDenied: Bool)
    /*var status: String {
        switch self {
        case .phase_one:
            return "Created"
        case .phase_two:
            return "AdminApproved"
        case .phase_three:
            return "UserApproved"
        case .phase_four:
            return "AdminApproved Two"
        case .phase_five:
            return "Becomes Award"
        }
    } */
    
    func saveNomination(vc: UIViewController, completion: @escaping (Bool) -> Void) {
        switch self {
        case .phase_one(let nomination, let userNom, let hasAccount):
            // Golden Notification
            let oneText = NominationPhase.phase_one.generateNotificationText(nomination: nomination)
            let oneTitle = NominationPhase.phase_one.generateNotificationTitle(nomination: nomination)
            let goldenNotif = GoldenNotifications(notificationType: NotificationType.phase_one.typ, nominationUID: nomination.uid, targetPhone: nomination.nominee.phone, targetName: nomination.nominee.fullName, targetUID: nomination.nominee.uid, senderURL: nomination.nominatedBy.profilePictureURL, senderUID: nomination.nominatedBy.uid, senderName: nomination.nominatedBy.fullName, senderPhone: nomination.nominatedBy.phone, startTime: nomination.startDate, endDate: nomination.endDate, hasAccount: hasAccount, region: nomination.region, notifText: oneText, notifTitle: oneTitle)
            
            // The easy access nomination is created, only an object until phase four
            let nominationLink = CollectionFireRef.nominations.reference()
            //let nominationLink = DBRef.nominations.reference()

            let nominationRef = DBRef.nominationCheck(nomUID: nomination.uid).reference()
            // Admin Ref is created for the nomination
            let adminRef = DBRef.admin_nomination(region: nomination.region, uid: nomination.uid).reference()
            // User Nom is created
            let userNomRef = DBRef.userNom(uid: userNom.nominatedByUID, nomUID: userNom.nominationUID).reference()
            
            // Sends to Admin Notification Region for Approval
            let adminNotificationRef = DBRef.admin_notif_query(region: nomination.region, notifUID: goldenNotif.uid).reference()
            // Admin Algolia Ref is created
            //let adminAlgoliaNomination = AlgoliaRef.admin_nominations.reference()
            
            // sudesh
            print(nomination.toDictionary())
            nominationLink.addDocument(data: nomination.toDictionary())
           // nominationLink.setValue(nomination.toDictionary())
            completion(true)
            
            let workItem = DispatchWorkItem {
                nominationRef.setValue(nomination.toDictionary())
                adminRef.setValue(nomination.toDictionary())
                userNomRef.child(userNom.nominationUID).setValue(userNom.toDictionary())
                adminNotificationRef.setValue(goldenNotif.toDictionary())
                completion(true)
            }
            let algItem = DispatchWorkItem {
               /* adminAlgoliaNomination.addObject(nomination.toDictionary(), withID: nomination.uid, requestOptions: nil, completionHandler: { (dict, error) in
                    guard error == nil else {
                        completion(false)
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: workItem)
                }) */
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: algItem)
            
            
        case .phase_two(let nomination, let existing):
            let twoTextNominee = NominationPhase.phase_two(existing: true).generateNotificationText(nomination: nomination)
            let twoTitleNominee = NominationPhase.phase_two(existing: true).generateNotificationTitle(nomination: nomination)
            
            let twoTextNominator = NominationPhase.phase_two(existing: false).generateNotificationText(nomination: nomination)
            let twoTitleNominator = NominationPhase.phase_two(existing: false).generateNotificationTitle(nomination: nomination)
            
            // User Nominations phase and status need updated @ this phase and url if user has an account
            let userNomRef = DBRef.userNom(uid: nomination.nominatedBy.uid, nomUID: nomination.uid).reference()
            // User Nominee Obj is created for a user to access it with a new account
            let userAcceptRef = DBRef.userNominees(phone: nomination.nominee.phone).reference().child(nomination.uid)
            // Delete from Admin Ref
            let adminDeleteRef = DBRef.admin_nomination(region: nomination.region, uid: nomination.uid).reference()
            // Delete from Algolia Ref
            //let adminDeleteAlgolia = AlgoliaRef.admin_nominations.reference()
            // Update main pulling OBJ
            let nominationRef = DBRef.nominationCheck(nomUID: nomination.uid).reference()
            
           
            let userNominee = UserNominee(nomByName: nomination.nominatedBy.fullName, nomByUID: nomination.nominatedBy.uid, nominationUID: nomination.uid, status: "Awaiting your approval", category: nomination.category, charityEIN: "N/A", charityName: "N/A", charityAddress: "N/A", fullNomineeAddress: "N/A", phase: NotificationType.phase_two.typ)
            
            
            // MARK: - Check here to see if user if in userPhonePath!!
            let nomineeNotification = GoldenNotifications(notificationType: NotificationType.phase_two.typ, nominationUID: nomination.uid, targetPhone: nomination.nominee.phone, targetName: nomination.nominee.fullName, targetUID: nomination.nominee.uid, senderURL: nomination.nominatedBy.profilePictureURL, senderUID: nomination.nominatedBy.uid, senderName: nomination.nominatedBy.fullName, senderPhone: nomination.nominatedBy.phone, startTime: nomination.startDate, endDate: nomination.endDate, hasAccount: existing, region: nomination.region, notifText: twoTextNominee, notifTitle: twoTitleNominee)
            let nominatorNotification = GoldenNotifications(notificationType: NotificationType.phase_two.typ, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: 0, hasAccount: existing, region: nomination.region, notifText: twoTextNominator, notifTitle: twoTitleNominator)
    
            let notificationNomineeRef = DBRef.notification_query(phone: nomination.nominee.phone).reference()
            let notificationNominatorRef = DBRef.notification_query(phone: nomination.nominatedBy.phone).reference()
            
            
            let adminBadgeItem = DispatchWorkItem {
                // Removes badge down one from admin
                Person.adminBadgeSubtractBadge(region: nomination.region, completion: { (error) in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            
            let firebaseWorkItem = DispatchWorkItem {
                notificationNomineeRef.setValue(nomineeNotification.toDictionary())
                notificationNominatorRef.setValue(nominatorNotification.toDictionary())
                userNomRef.updateChildValues(["status" : NominationPhase.phase_two(existing: existing).status, "phase" : NotificationType.phase_two.typ])
                nominationRef.updateChildValues(["phase" : NotificationType.phase_two.typ])
                userAcceptRef.setValue(userNominee.toDictionary())
                adminDeleteRef.setValue(nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: adminBadgeItem)
            }
            let algWorkItem = DispatchWorkItem {
               /* adminDeleteAlgolia.deleteObject(withID: nomination.uid, requestOptions: nil) { (dict, error) in
                    guard error == nil else {
                        vc.goldenAlert(title: "Error", message: "There was an error sending the notification!", view: vc)
                        print(error!.localizedDescription)
                        completion(false)
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: firebaseWorkItem)
                } */
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3), execute: algWorkItem)
            
            
        // MARK: - Phase three for the Nominations --> Already have updated nomination
        case .phase_three(let userNominee, let nomination, let changed, let reasonCharity):
            let userNomineeRef = DBRef.userNominees(phone: nomination.nominee.phone).reference().child(nomination.uid)
            let nominationRef = DBRef.nominationCheck(nomUID: nomination.uid).reference()
            
            userNomineeRef.setValue(userNominee.toDictionary())
            if changed {
                let userNomRef = DBRef.userNom(uid: nomination.nominatedBy.uid, nomUID: nomination.uid).reference()
                let adminRef = DBRef.admin_nomination(region: nomination.region, uid: nomination.uid).reference()
                
                let adminNotificationText = NominationPhase.phase_three(changed: changed, charityReason: reasonCharity, isAdmin: true).generateNotificationText(nomination: nomination)
                let adminNotificationTitle = NominationPhase.phase_three(changed: changed, charityReason: reasonCharity, isAdmin: true).generateNotificationTitle(nomination: nomination)
                
                let nominatorTitle = NominationPhase.phase_three(changed: changed, charityReason: reasonCharity, isAdmin: false).generateNotificationTitle(nomination: nomination)
                let nominatorText = NominationPhase.phase_three(changed: changed, charityReason: reasonCharity, isAdmin: false).generateNotificationText(nomination: nomination)
                
                
                
                let notificationAdmin = GoldenNotifications(notificationType: NotificationType.phase_three.typ, nominationUID: nomination.uid, targetPhone: nomination.nominee.phone, targetName: nomination.nominee.fullName, targetUID: nomination.nominee.uid, senderURL: nomination.nominatedBy.profilePictureURL, senderUID: nomination.nominatedBy.uid, senderName: nomination.nominatedBy.fullName, senderPhone: nomination.nominatedBy.phone, startTime: nomination.startDate, endDate: nomination.endDate, hasAccount: true, region: nomination.region, notifText: adminNotificationText, notifTitle: adminNotificationTitle)
                let notificationNominator = GoldenNotifications(notificationType: NotificationType.phase_three.typ, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: 0, hasAccount: true, region: nomination.region, notifText: nominatorText, notifTitle: nominatorTitle)
                
                
                let nominatorNotificationRef = DBRef.notification_query(phone: nomination.nominatedBy.phone).reference().child(notificationNominator.uid)
                let adminNotificationRef = DBRef.admin_notif_query(region: nomination.region, notifUID: notificationAdmin.uid).reference()
                //let algoliaAdminRef = AlgoliaRef.admin_nominations.reference()
            
                let nomineeBadge = DBRef.userBadge(phone: nomination.nominee.phone).reference()
                let nominatorBadge = DBRef.userBadge(phone: nomination.nominatedBy.phone).reference()
                
                
                let updateNominatorBadge = DispatchWorkItem {
                    nomination.nominatedBy.subtractBadge(completion: { (error) in
                        guard error == nil else {
                            completion(false)
                            print(error!.localizedDescription)
                            return
                        }
                        completion(true)
                    })
                }
                
                let updateNomineeBadge = DispatchWorkItem {
                    nomination.nominee.subtractBadge(completion: { (error) in
                        guard error == nil else {
                            completion(false)
                            print(error!.localizedDescription)
                            return
                        }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: updateNominatorBadge)
                    })
                }
                
                
                let updateItem = DispatchWorkItem {
                    
                    adminNotificationRef.updateChildValues(["\(notificationAdmin.uid)" : notificationAdmin.toDictionary()]) { (error, ref) in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            vc.goldenAlert(title: "Error", message: "Error sending the notification", view: vc)
                            completion(false)
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: updateNomineeBadge)
                        
                    }

                }
                let firebaseBeforeQuery = DispatchWorkItem {
                    nominatorNotificationRef.setValue(notificationNominator.toDictionary())
                    adminRef.setValue(nomination.toDictionary())
                    let charity = Charity(charityName: userNominee.charityName, address: userNominee.charityAddress, ein: userNominee.charityEIN, uid:userNominee.nominationUID)
                    nominationRef.updateChildValues(["phase" : NotificationType.phase_three.typ, "charity" : charity.toDictionary(), "nomineeAddress": userNominee.fullNomineeAddress, "status" : NominationPhase.phase_three(changed: changed, charityReason: reasonCharity, isAdmin: false).status])
                    userNomRef.updateChildValues(["phase" : NotificationType.phase_three.typ])
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: updateItem)
                }
                let algoliaItem = DispatchWorkItem {
                
                  /*  algoliaAdminRef.addObject(nomination.toAlgDictionary(), withID: nomination.uid, requestOptions: nil, completionHandler: { (dict, error) in
                        guard error == nil else {
                            vc.goldenAlert(title: "Error", message: "There was an error saving your nomination, please check your internet connection and try again", view: vc)
                            completion(false)
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: firebaseBeforeQuery)
                    }) */
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: algoliaItem)
                
            } else {
                let objText = NominationPhase.phase_three(changed: false, charityReason: false, isAdmin: false).status
                self.nominationLive(phaseNumber: NotificationType.phase_three.typ, objText: objText, nomination: nomination, isAdmin: false) { (error) in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        vc.goldenAlert(title: "Error", message: "There was an error saving your nomination, please check your internet connection and try again", view: vc)
                        completion(false)
                        return
                    }
                    let notificationNominator = GoldenNotifications(notificationType: NotificationType.phase_three.typ, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: nomination.endDate, hasAccount: true, region: nomination.region, notifText: NominationPhase.phase_three(changed: changed, charityReason: reasonCharity, isAdmin: false).generateNotificationText(nomination: nomination), notifTitle: "")
                    let nominatorNotifRef = DBRef.notification_query(phone: nomination.nominatedBy.phone).reference().child(notificationNominator.uid)
                    nominatorNotifRef.setValue(notificationNominator.toDictionary())
                   
                }
            }
            
            
        case .phase_four(let nomination, let userNominee):
            let objText = NominationPhase.phase_four(isNominee: false).status
            self.nominationLive(phaseNumber: NotificationType.phase_four.typ, objText: objText, nomination: nomination, isAdmin: false) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    vc.goldenAlert(title: "Error", message: "There was an error saving your nomination, please check your internet connection and try again", view: vc)
                    completion(false)
                    return
                }
                let nominatorTitle = NominationPhase.phase_four(isNominee: false).generateNotificationTitle(nomination: nomination)
                let nominatorText = NominationPhase.phase_four(isNominee: false).generateNotificationTitle(nomination: nomination)
                let nomineeTitle = NominationPhase.phase_four(isNominee: true).generateNotificationTitle(nomination: nomination)
                let nomineeText = NominationPhase.phase_four(isNominee: true).generateNotificationText(nomination: nomination)
                
                
                
                let notificationNominator = GoldenNotifications(notificationType: NotificationType.phase_three.typ, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: nomination.endDate, hasAccount: true, region: nomination.region, notifText: nominatorText, notifTitle: nominatorTitle)
                
                let notificationNominee = GoldenNotifications(notificationType: NotificationType.phase_three.typ, nominationUID: nomination.uid, targetPhone: nomination.nominee.phone, targetName: nomination.nominee.fullName, targetUID: nomination.nominee.uid, senderURL: nomination.nominatedBy.profilePictureURL, senderUID: nomination.nominatedBy.uid, senderName: nomination.nominatedBy.fullName, senderPhone: nomination.nominatedBy.phone, startTime: nomination.startDate, endDate: nomination.endDate, hasAccount: true, region: nomination.region, notifText: nomineeText, notifTitle: nomineeTitle)
                
                let updateAdminBadge = DispatchWorkItem {
                    Person.adminBadgeSubtractBadge(region: nomination.region, completion: { (error) in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                
                let nominatorWorkItem = DispatchWorkItem {
                    let ref = DBRef.notification_query(phone: notificationNominator.targetPhone).reference()
                    ref.updateChildValues(["\(notificationNominator.uid)" : notificationNominator.toDictionary()], withCompletionBlock: { (error, ref) in
                        guard error == nil else {
                            vc.goldenAlert(title: "Error", message: "Error sending the notification", view: vc)
                            completion(false)
                            print(error!.localizedDescription)
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: updateAdminBadge)
                    })
                }
                let nomineeRef = DBRef.notification_query(phone: notificationNominee.targetPhone).reference()
                nomineeRef.updateChildValues(["\(notificationNominee.uid)" : notificationNominee.toDictionary()], withCompletionBlock: { (error, ref) in
                    guard error == nil else {
                        vc.goldenAlert(title: "Error", message: "Error sending the notification", view: vc)
                        completion(false)
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: nominatorWorkItem)
                })
                
            }
            
        case .phase_five(let nomination):
            // MARK: - All of this is executed in the Functions
           // let userNomineePath = DBRef.userNominees(phone: nomination.nominee.phone).reference().child(nomination.uid)
          //  let userNomPath = DBRef.userNom(uid: nomination.nominatedBy.uid, nomUID: nomination.uid).reference()
          //  let adminAwardAlgolia = AlgoliaRef.admin_awards.reference() // Added
          //  let nominationAlgolia = AlgoliaRef.nominations.reference() // Deleted
            
            
            completion(true)
            
            
        case .phase_six(let nomination, let adminDenied):
            let userNomRef = DBRef.userNom(uid: nomination.uid, nomUID: nomination.uid).reference()
            let userNomineesRef = DBRef.userNominees(phone: nomination.nominee.phone).reference().child(nomination.uid)
            let nominationCheckRef = DBRef.nominationCheck(nomUID: nomination.uid).reference()
            
        
            if adminDenied {
                if nomination.userApproved {
                    // Using Two notification paths
                    let goldenNomineeNotification = GoldenNotifications(notificationType: NotificationType.phase_six.typ, nominationUID: nomination.uid, targetPhone: nomination.nominee.phone, targetName: nomination.nominee.fullName, targetUID: nomination.nominee.uid, senderURL: nomination.nominatedBy.profilePictureURL, senderUID: nomination.nominatedBy.uid, senderName: nomination.nominatedBy.fullName, senderPhone: nomination.nominatedBy.phone, startTime: nomination.startDate, endDate: 0, hasAccount: true, region: nomination.region, notifText: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationText(nomination: nomination), notifTitle: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationTitle(nomination: nomination))
                    let goldenNotification = GoldenNotifications(notificationType: NotificationType.phase_six.typ, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: 0, hasAccount: true, region: nomination.region, notifText: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationText(nomination: nomination), notifTitle: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationTitle(nomination: nomination))
                    let userNominee = DBRef.notification_query(phone: nomination.nominee.phone).reference().child(goldenNomineeNotification.uid)
                    let userNominator = DBRef.notification_query(phone: nomination.nominatedBy.phone).reference().child(goldenNotification.uid)
                    userNominee.setValue(goldenNomineeNotification.toDictionary())
                    userNominator.setValue(goldenNotification.toDictionary())
                    userNomRef.updateChildValues(["phase":NotificationType.phase_six.typ, "status": NominationPhase.phase_six(adminDenied: adminDenied).status])
                    userNomineesRef.updateChildValues(["phase":NotificationType.phase_six.typ, "status":NominationPhase.phase_six(adminDenied: adminDenied).status])
                    nominationCheckRef.setValue(nomination.toDictionary())
                    
                } else {
                    let goldenNotification = GoldenNotifications(notificationType: NotificationType.phase_six.typ, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: 0, hasAccount: false, region: nomination.region, notifText: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationText(nomination: nomination), notifTitle: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationTitle(nomination: nomination))
                    let ref = DBRef.notification_query(phone: nomination.nominatedBy.phone).reference().child(goldenNotification.uid)
                    ref.setValue(goldenNotification.toDictionary())
                    userNomRef.updateChildValues(["phase":NotificationType.phase_six.typ, "status": NominationPhase.phase_six(adminDenied: adminDenied).status])
                    nominationCheckRef.setValue(nomination.toDictionary())
                }
            } else {
                let goldenNotification = GoldenNotifications(notificationType: NominationPhase.phase_six(adminDenied: adminDenied).id, nominationUID: nomination.uid, targetPhone: nomination.nominatedBy.phone, targetName: nomination.nominatedBy.fullName, targetUID: nomination.nominatedBy.uid, senderURL: nomination.nominee.profilePictureURL, senderUID: nomination.nominee.uid, senderName: nomination.nominee.fullName, senderPhone: nomination.nominee.phone, startTime: nomination.startDate, endDate: 0, hasAccount: true, region: nomination.region, notifText: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationText(nomination: nomination), notifTitle: NominationPhase.phase_six(adminDenied: adminDenied).generateNotificationTitle(nomination: nomination))
                let ref = DBRef.notification_query(phone: nomination.nominatedBy.phone).reference().child(goldenNotification.uid)
                
                ref.setValue(goldenNotification.toDictionary())
                userNomRef.updateChildValues(["phase":NotificationType.phase_six.typ, "status": NominationPhase.phase_six(adminDenied: adminDenied).status])
                userNomineesRef.updateChildValues(["phase":NotificationType.phase_six.typ, "status":NominationPhase.phase_six(adminDenied: adminDenied).status])
                nominationCheckRef.setValue(nomination.toDictionary())
                
            }

        }
        
        
    }
    
    func nominationLive(phaseNumber: Int, objText: String, nomination: Nominations, isAdmin: Bool, completion: @escaping (Error?) -> Void) {
        let mainNomRef = FireRef.spec_nomination(uid: nomination.uid).reference()
       // let algoliaRef = AlgoliaRef.nominations.reference()
       // let adminAlgolia = AlgoliaRef.admin_nominations.reference()
        
        
        // Firebase Paths
        let nomCount = DBRef.nom_count(uid: nomination.uid).reference()
        let userNomRef = DBRef.userNom(uid: nomination.nominatedBy.uid, nomUID: nomination.uid).reference()
        let userAcceptRef = DBRef.userNominees(phone: nomination.nominee.phone).reference().child(nomination.uid)
        let userCheck = DBRef.user(uid: nomination.nominee.uid).reference().child("nominee")
        let checkRef = DBRef.nominationCheck(nomUID: nomination.uid).reference()
        
        let saveTimes = DBRef.nomination_date(uid: nomination.uid).reference()
        
        let startDate = Date()
        nomination.startDate = startDate.timeIntervalSince1970
        nomination.endDate = 0//startDate.adjust(.month, offset: 1).toString(style: .long)
        let nominationTimeObj = NomTimes(date: startDate)
        
        let firebaseWorkItem = DispatchWorkItem {
            saveTimes.setValue(nominationTimeObj.toDictionary())
            userCheck.setValue(true)
            nomCount.setValue(0)
            userNomRef.updateChildValues(["phase" : phaseNumber, "status": objText])
            userAcceptRef.updateChildValues(["phase" : phaseNumber, "status" : objText])
            checkRef.setValue(true)
            completion(nil)
        }
        let algoliaAdminWorkItem = DispatchWorkItem {
//            adminAlgolia.deleteObject(withID: nomination.uid, requestOptions: nil) { (dict, error) in
//                guard error == nil else {
//                    print(error!.localizedDescription)
//                    completion(error)
//                    return
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: firebaseWorkItem)
//            }
        }
        let algoliaUserWorkItem = DispatchWorkItem {
//            self.writeAlgolia(ref: algoliaRef, nomination: nomination, workItem: algoliaAdminWorkItem, completion: { (error) in
//                completion(error)
//            })
        }
        let firestoreRef = DispatchWorkItem {
            mainNomRef.setData(nomination.toDictionary(), completion: { (error) in
                guard error == nil else {
                    completion(error)
                    print(error!.localizedDescription)
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: algoliaUserWorkItem)
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: firestoreRef)
    }
    func writeAlgolia(ref: NSInteger, nomination: Nominations, workItem: DispatchWorkItem, completion: @escaping (Error?) -> Void) {
//        ref.addObject(nomination.toDictionary(), withID: nomination.uid, requestOptions: nil, completionHandler: { (nomin, error) in
//            completion(error)
//            print(error?.localizedDescription)
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: workItem)
//            print(nomin)
//            print("Big file")
//        })
    }
    
    
}
