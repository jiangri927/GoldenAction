//
//  VCID.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation

// Used for Instaniating View Controller 
enum VCID {
    
    case tutorial_one
    case tutorial_two
    case welcome_screen
    case welcome_sponsorinfo
    case sponsorinfo_description
    case home_tab_bar
    case nominee_screen
    case nominee_detail
    case awards_detail
    case reusable_screen
    case notification_screen
    case cart_screen
    case loading_screen
    case settings_screen
    case signup_email
    case signup_password
    case signup_detail
    case signup_legal
    case google_login
    case facebook_login
    case search
    case create_nomination
    // Filter Location
    case filter_location
    
    // Admin Screeens
    case admin_welcome
    case admin_profile
    case admin_notifications
    case admin_users
    case admin_users_spec
    case admin_nom
    case admin_nom_spec
    case admin_donations
    case admin_donations_spec
    case admin_settings
    // Profile
    case profile
    case personal_nomination
    case personal_award
    
    // Admin Welcome
    case sponsor_info
    case sponsor_description
    case sponsor_congrats
    
    // Golden Tutorial
    case golden_tutorial
    case golden_tutorial_one
    case golden_tutorial_two
    case golden_tutorial_three
    case golden_tutorial_four
    case golden_tutorial_five
    
    case golden_award_screen
    
    case share_vc

    
    case admin_address
    
    case side_table
    case side_nav
    
    case message_vc
    case admin_tutorial
    case admin_tutorial_one
    case admin_tutorial_two
    case admin_tutorial_three
    case admin_tutorial_four
    case admin_tutorial_five
    
    case one_create_nom
    case two_create_nom
    case three_create_nom
    case confirm_create_nom
    case custom_swipe_vc
    
    case rater_the_app
    case send_feedback_settings
    
    case delete_account_settings
    
    
    public var id: String {
        switch self {
        case .send_feedback_settings:
            return "SendFeedbackPopupViewController"
        case .delete_account_settings:
            return "DeleteAccountViewController"
        case .tutorial_one:
            return "TutorialOne"
        case .tutorial_two:
            return "TutorialTwo"
        case .welcome_screen:
            return "Welcome"
        case .welcome_sponsorinfo:
            return "Welcome2SponsorInfo"
        case .sponsorinfo_description:
            return "Info2SponsorDescription"
        case .home_tab_bar:
            return "Home"
        case .nominee_screen:
            return "Nominee"
        case .nominee_detail:
            return "NomineeDetail"
        case .awards_detail:
            return "AwardsDetail"
        case .reusable_screen:
            return "Reusable"
        case .notification_screen:
            return "NotifMain"
        case .cart_screen:
            return "CartMain"
        case .loading_screen:
            return "Loading"
        case .settings_screen:
            return "Settings"
            
        case .signup_email:
            return "EmailSignup"
        case .signup_password:
            return "PasswordSignup"
        case .signup_detail:
            return "DetailSignup"
        case .signup_legal:
            return "SignupLegalViewController"
            
        case .google_login:
            return "GoogleLogin"
        case .facebook_login:
            return "FacebookLogin"
            
        case .profile:
            return "ProfileVC"
        case .personal_nomination:
            return "PersonalNom"
        case .personal_award:
            return "PersonalAward"
            
        case .search:
            return "SearchVC"
        case .create_nomination:
            return "CreateNomVC"
            
        case .admin_welcome:
            return "AdminWelcome"
        case .admin_profile:
            return "AdminProfile"
        case .admin_notifications:
            return "AdminNotifications"
        case .admin_users:
            return "AdminUsers"
        case .admin_users_spec:
            return "AdminUserSpec"
        case .admin_nom:
            return "AdminNominations"
        case .admin_nom_spec:
            return "AdminNominationsSpec"
        case .admin_donations:
            return "AdminDonations"
        case .admin_donations_spec:
            return "AdminDonationsSpec"
        case .admin_settings:
            return "AdminSettings"
            
        case .sponsor_info:
            return "SponsorInfo"
        case .sponsor_congrats:
            return "SponsorCongrats"
        case .sponsor_description:
            return "SponsorDescription"
            
        case .filter_location:
            return "FilterLocationVC"
            
        case .golden_tutorial:
            return "GoldenTutorial"
        case .golden_tutorial_one:
            return "golden-tutorial-one"
        case .golden_tutorial_two:
            return "golden-tutorial-two"
        case .golden_tutorial_three:
            return "golden-tutorial-three"
        case .golden_tutorial_four:
            return "golden-tutorial-four"
        case .golden_tutorial_five:
            return "golden-tutorial-five"
            
        case .admin_tutorial:
            return "admin_tutorial"
        case .admin_tutorial_one:
            return "admin_tutorial_one"
        case .admin_tutorial_two:
            return "admin_tutorial_two"
        case .admin_tutorial_three:
            return "admin_tutorial_three"
        case .admin_tutorial_four:
            return "admin_tutorial_four"
        case .admin_tutorial_five:
            return "admin_tutorial_five"
            
        case .message_vc:
            return "message_vc"
            
        case .golden_award_screen:
            return "GoldenAwardScreen"
        case .share_vc:
            return "ShareVC"
            
            
        case .admin_address:
            return "AdminAddressVC"
            
        case .side_nav:
            return "side_nav"
        case .side_table:
            return "side_table"
            
        case .one_create_nom:
            return "one_create_nom"
        case .two_create_nom:
            return "two_create_nom"
        case .three_create_nom:
            return "three_create_nom"
        case .confirm_create_nom:
            return "confirm_create_nom"
        case .custom_swipe_vc:
            return "custom_swipe_vc"
            
        case .rater_the_app:
            return "RatertheAppViewController"
            
            
            
        }
    }
}
enum SegueId {
    case welcome_signupEmail
    case signupEmail_signupPassword
    case signupPasword_signupDetail
    case signupDetail_signupLegal
    case signupGoogle_signupDetail
    case signupPhone_signupDetail
    case nom_create
    case nom_profile
    case awards_profile
    case settings_profile
    case nom_notif
    case nom_cart
    case awards_notif
    case awards_cart
    case settings_notif
    case settings_cart
    case nom_search
    case awards_search
    
    case nomination_tutorialone
    case tutorialone_two
    
    case welcome_sponsorinfo
    case sponsorinfo_description
    case sponsordescription_create
    case sponsordescription_congrats
    case sponsorlegal_congrats
    case sponsordescription_address
    case sponsoraddress_create
    case sponsoraddress_congrats
    
    case profile_admin
    
    case admin_settings_profile
    case admin_settings_notifications
    case admin_settings_home
    
    case profile_notifications
    case profile_checkout
    
    case settings_to_rate
    
    
    public var id: String {
        switch self {
        case .nomination_tutorialone:
            return "Nom2Tutorial"
        case .tutorialone_two:
            return "Tut2Second"
        case .welcome_signupEmail:
            return "Welcome2Email"
        case .signupEmail_signupPassword:
            return "Email2Password"
        case .signupPasword_signupDetail:
            return "Password2Detail"
        case .signupDetail_signupLegal:
            return "Detail2Legal"
        case .signupGoogle_signupDetail:
            return "GoogleCreate"
        case .signupPhone_signupDetail:
            return "PhoneCreate"
        case .nom_create:
            return "Nom2Create"
        case .nom_profile:
            return "NomProfile"
        case .awards_profile:
            return "AwardsProfile"
        case .settings_profile:
            return "SettingsProfile"
        case .nom_notif:
            return "NomNotif"
        case .nom_cart:
            return "NomCart"
        case .awards_notif:
            return "AwardsNotif"
        case .awards_cart:
            return "AwardsCart"
        case .settings_notif:
            return "SettingsNotif"
        case .settings_cart:
            return "SettingsCart"
        case .nom_search:
            return "NomSearch"
        case .awards_search:
            return "AwardsSearch"
        case .welcome_sponsorinfo:
            return "Welcome2SponsorInfo"
        case .sponsorinfo_description:
            return "Info2SponsorDescription"
        case .sponsordescription_create:
            return "SponsorDescription2Create"
        case .sponsordescription_congrats:
            return "SponsorDescription2Congrats"
        case .sponsordescription_address:
            return "AdminDescription2Address"
        case .sponsoraddress_create:
            return "AdminAddress2Create"
        case .sponsoraddress_congrats:
            return "SponsorAddress2Congrats"
        case .sponsorlegal_congrats:
            return "Legal2SponsorCongrats"
        case .profile_admin:
            return "ProfileToAdmin"
            
        case .admin_settings_home:
            return "AdminSettings2Home"
        case .admin_settings_profile:
            return "AdminSettings2AdminProfile"
        case .admin_settings_notifications:
            return "AdminSettings2AdminNotifications"
            
            
        case .profile_notifications:
            return "Profile2Notifications"
        case .profile_checkout:
            return "Profile2Checkout"
        case .settings_to_rate:
            return "Settings2\(VCID.rater_the_app.id)"
        }
    }
}
enum CellId {
    case nominees_cell_not_found
    case nominees_cell
    case award_cell
    case search_results
    case settings_cell
    case notification_cell
    case checkout_cell
    case nominee_detail_collection
    case awardee_detail_collection
    case profile_cell
    case create_nom_collection
    case addPhoto_cell
    // Profile Cells
    case user_noms_cell
    case user_votes_cell
    case user_golden_cell
    
    // Admin Cells
    case admin_users
    case admin_noms
    case admin_donations
    case admin_notifications
    case admin_settings
    
    public var id: String {
        switch self {
        case .nominees_cell_not_found:
            return "AwardNotFoundTableCell"
        case .nominees_cell:
            return "Nominees"
        case .award_cell:
            return "Awards"
        case .search_results:
            return "SearchResults"
        case .settings_cell:
            return "SettingsCell"
        case .notification_cell:
            return "NotificationCell"
        case .checkout_cell:
            return "CheckoutCell"
        case .nominee_detail_collection:
            return "NomineeCollection"
        case .awardee_detail_collection:
            return "AwardCollection"
        case .profile_cell:
            return "ProfileCell"
        case .create_nom_collection:
            return "CreateNomCell"
        case .admin_users:
            return "AdminUsersCell"
        case .admin_noms:
            return "AdminNominationsCell"
        case .admin_donations:
            return "AdminDonationsCell"
        case .admin_notifications:
            return "AdminNotificationsCell"
        case .admin_settings:
            return "AdminSettingsCell"
        case .user_noms_cell:
            return "UserNomsCell"
        case .user_votes_cell:
            return "UserVotesCell"
        case .user_golden_cell:
            return "UserGoldenCell"
        case .addPhoto_cell:
            return "Add_Photo_Identifier"
        
        }
    }
}
