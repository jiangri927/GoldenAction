//
//  DBRef.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/13/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

enum DBRef {
    
    case person
    case cityCluster
    
    case feedback(uid: String)
    case notifications(phone: String)
    case spec_notification(phone: String, notifUID: String)
    case notification_query(phone: String) // The user who nominated the individuals UID
    
    // MARK: - User Firebase Paths
    // Main User Path
    case user(uid: String)
    // Legal Agreement ----> legal/{uid}/Bool <--- True or False
    case legal(uid: String)
    // Total Badge for Application
    case userBadge(phone: String)
    case adminBadge(region: String)
    
    // Saved Paths for App Navigation and Experience
    case userLastNomCategory(uid: String)
    case userLastNomLocation(uid: String)
    case userLastAwardCategory(uid: String)
    case userLastAwardLocation(uid: String)
    case userPreNomination(uid: String) // ---> This value is either the nomination UID or "none" to mark it already segued back
    
    // Check if fully signed up user exists
    case userPhoneNumber(phoneNumber: String)
    
    // Reciept and Amount of Vote Paths
    case userVotesReciepts(uid: String)
    case totalUserVotes(uid: String)
    case userNomReciepts(uid: String)
    case totalUserNoms(uid: String)
    
    // Specific User Nominations with User UID of who they nominated
    case userNoms(uid: String) // --> All path
    case userNom(uid: String, nomUID: String) // --> Returns Nomination Object with extra Info
    case userNominees(phone: String)
    // Specific User Votes with Nomination UID
    case userVotes(uid: String) // ---> All Path
    case userVote(uid: String, nomUID: String) // ---> Returns Amount Given, Vote Number, NomUID
    
    
    // MARK: - Nomination Acceptance and Charity Process
    // Constantly monitored by users and notifications to see if they have been nominated
    // Nominee Path --> Just the UID of the User who has been nominated to accept or not
    // ------> Accept is appended to from admin panel and if user accepts it updates firestore nomination
    // ------> to become active. If not it deletes it.
    case userNominatedAcceptList(phone: String)
    case userNominatedAccept(phone: String, nomUID: String)
    // -----> Charity is appended by the Nominee along with address and the nomination UID to be seen by the admins to take the necessary actions --> Charity EIN!
    // This also contains the Address of the Nominee, the Award Recieved and the money attained
    case userNominatedCharityList(uid: String)
    case userNominatedCharity(uid: String, nomUID: String)
    
    case finishedNominations(nomineeUID: String)
    // Check for nomination --> This intially holds the nomination value for everyone to access it and then is turned to true if posted and false if not 
    case nominationCheck(nomUID: String)
    case nominations
    
    // VOTES for nomination and awards with enough user data to load a small screen for them
    // eg: ---> voter uid, name, pic url
    // ---> This is where the coin awards come through
    case nom_votes(uid: String, voterUID: String)
    // Actual Count of these objects
    case nom_count(uid: String)
    // Money Attained
    case nom_donated(uid: String)
    
    case verification_notif(phone: String)
    
    case admins
    case admin(uid: String)
    
    case admin_notifications_query(region: String)
    case admin_notif_query(region: String, notifUID: String)
    case admin_notifications(region: String)
    
    
    
    // Admin Pending -- Super Admin Data
    case banned_user(region: String, uid: String)
    case banned_users(region: String)
    
    case admin_pending(region: String)
    case spec_admin_pending(region: String, uid: String)
    case admin_pending_query
    
    case admin_reciepts_nom
    case admin_reciepts_votes
    
    case admin_nominations(region: String)
    case admin_nomination(region: String, uid: String)
    
    case nomination_coupons
    case nomination_coupon(uid: String)
    case votes_coupons
    case votes_coupon(uid: String)
    
    case free_nominations
    case free_votes
    
    case app_version
    
    case nomination_dates
    case nomination_date(uid: String)
    
    case charities
    case charity(ein: String)
    
    case create_nom_segue_page(uid: String)
    case create_nom_segue_data(uid: String)
    
    func reference() -> DatabaseReference {
        return rootRef.child(path)
    }
    
    private var rootRef: DatabaseReference {
        return Database.database().reference()
    }
    
    private var path: String {
        switch self {
            
        case .person:
            return "person"
        case .cityCluster:
            return "cityCluster"
        case .feedback(let uid):
            return "feedback/\(uid)"
        // Nomination Notification Process
        // STEP ONE ---> When User Submits Nomination one Notification is saved immediately here to say it is under review by admins and (can check status in profile)!!!
        // STEP TWO ---> (CASE IF USER HAS ACCOUNT WITH APP) When admin accepts another notification is sent here for the user to ask if they would like to accept
        // STEP TWO ---> (CASE IF USER DOES NOT HAVE ACCOUNT WITH APP) When admin accepts a text message notification is sent to user to download and accept nomination
        // STEP THREE ---> Using PubSub and AppEngine Functions Checks Firestore for nomination date ending to send notification for award type, to both nominee and nominated by
        // --------------> Change award in nomination to true, delete this record out of the time table. (Database checks every hour in beta)
        // STEP FOUR ---> Notification is sent through Query, SENT and then added to actual notifications path for nominee to choose charity and address for postcard to be sent
        case .notification_query(let phone):
            return "notificationQuery/\(phone)"
        case .notifications(let phone):
            return "notifications/\(phone)"
        case .spec_notification(let phone, let notifUID):
            return "notifications/\(phone)/\(notifUID)"
        
        
            
        case .user(let uid):
            return "person/\(uid)"
        case .legal(let uid):
            return "legal/\(uid)"
        case .userBadge(let phone):
            return "badge/\(phone)"
        case .adminBadge(let region):
            return "adminBadge/\(region)"
        
        case .userLastNomCategory(let uid):
            return "categorySave/\(uid)/nomination"
        case .userLastNomLocation(let uid):
            return "locationSave/\(uid)/nomination"
        case .userLastAwardCategory(let uid):
            return "categorySave/\(uid)/award"
        case .userLastAwardLocation(let uid):
            return "locationSave/\(uid)/award"
        case .userPreNomination(let uid):
            return "lastNomination/\(uid)" // ---> Will be set to false if user has already segued back or pressed back to get there
        case .create_nom_segue_page(let uid):
            return "createNominationSegue/\(uid)/page"
        case .create_nom_segue_data(let uid):
            return "createNominationSegue/\(uid)/data"
        case .finishedNominations(let uid):
            return "finishedNominations/\(uid)"
            
        // MARK: Check here for when creating account to see if they have precious nomination
        case .userPhoneNumber(let phone):
            return "userPhone/\(phone)"
            
            
        // MARK: - Delete
        case .userVotesReciepts(let uid):
            return "votesReciepts/\(uid)/objs"
        case .totalUserVotes(let uid):
            return "votesReciepts/\(uid)/total"
        case .userNomReciepts(let uid):
            return "nomReciepts/\(uid)/objs"
        case .totalUserNoms(let uid):
            return "nomReciepts/\(uid)/total"
            
            
        // MARK: - Profile Pull Location
        case .userNoms(let uid): // User they nominated for
            return "userNoms/\(uid)"
        case .userNom(let uid, let nomUID):
            return "userNoms/\(uid)/\(nomUID)"
        case .userNominees(let phone):
            return "userNominees/\(phone)"
        case .userVotes(let uid): // Nomination the user voted for says how many votes they put into one nomination
            return "userVotes/\(uid)"
        case .userVote(let uid, let nomUID):
            return "userVotes/\(uid)/\(nomUID)"
            
            
        case .userNominatedAcceptList(let phone):
            return "userAccepts/\(phone)"
        case .userNominatedAccept(let phone, let nomUID):
            return "userAccepts/\(phone)/\(nomUID)"
        case .userNominatedCharityList(let uid):
            return "userCharity/\(uid)"
        case .userNominatedCharity(let uid, let nomUID):
            return "userCharity/\(uid)/\(nomUID)"
            
            
        // ALL NOMINATION AND AWARD OBJECT STAY IN FIRESTORE
        case .nominationCheck(let uid):
            return "nominationCheck/\(uid)"
        case .nominations:
            return "nominations" //nominationCheck
        case .nomination_dates:
            return "nominationDates"
        case .nomination_date(let uid):
            return "nominationDates/\(uid)"
            
        case .nom_votes(let uid, let voterUID):
            return "nomVotes/\(uid)/users/\(voterUID)"
        case .nom_count(let uid):
            return "nomVotes/\(uid)/count"
        case .nom_donated(let uid):
            return "nomVotes/\(uid)/donated"
            
        case .verification_notif(let phone):
            return "verificationNotif/\(phone)"
            
        case .admin(let uid):
            return "admins/\(uid)"
        case .admins:
            return "admins"
        case .admin_nominations(let region):
            return "adminNominations/\(region)"
        case .admin_nomination(let region, let uid):
            return "adminNominations/\(region)/\(uid)"
            
        case .admin_notifications_query(let region):
            return "adminNotificationsQuery/\(region)"
        case .admin_notif_query(let region, let notifUID):
            return "adminNotificationsQuery/\(region)/\(notifUID)"
        case .admin_notifications(let region):
            return "adminNotifications/\(region)"
            
        // MARK: - Super Admin Paths -- (Only viewable by them)
        case .admin_pending(let region):
            return "adminPending/\(region)"
        case .spec_admin_pending(let region, let uid):
            return "adminPending/\(region)/\(uid)"
        case .admin_pending_query:
            return "adminPendingQuery"
            
        case .app_version:
            return "appVersion"
            
        case .admin_reciepts_nom:
            return "adminRecieptsNom"
        case .admin_reciepts_votes:
            return "adminRecieptsVotes"
       
        case .free_nominations:
            return "freeNoms"
        case .free_votes:
            return "freeVotes"
       
        case .nomination_coupons:
            return "coupons/nominations"
        case .nomination_coupon(let uid):
            return "coupons/nominations/\(uid)"
        case .votes_coupons:
            return "coupons/votes"
        case .votes_coupon(let uid):
            return "coupons/votes/\(uid)"
            
        case .banned_users(let region):
            return "bannedUsers/\(region)"
        case .banned_user(let region, let uid):
            return "bannedUsers/\(region)/\(uid)"
            
            
        case .charities:
            return "charity"
        case .charity(let ein):
            return "charity/\(ein)"
        }
    }
}

