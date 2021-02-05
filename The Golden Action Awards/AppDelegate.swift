//
//  AppDelegate.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/2/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import SwiftKeychainWrapper
import UserNotifications
import SwiftyStoreKit
import EZSwipeController
import FacebookShare
import FacebookCore
import TwitterKit
import FacebookLogin
import FBSDKCoreKit
import FirebaseMessaging
import FirebaseAuth
import Fabric
import Crashlytics
import Stripe
import IQKeyboardManager

// Production firebase storage
let firebaseStorageUrl = "gs://golden-test-app.appspot.com/"

// Development firebase storage
//let firebaseStorageUrl = "gs://golden-action-dev.appspot.com/"

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    let notifCenter = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var badge = 0
    
    var nomineeController:NomineesViewController?
    var isAdminLoggedIn:Bool?
    
    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("amit.garg@subcodevs.com")
        Crashlytics.sharedInstance().setUserIdentifier("12345")
        Crashlytics.sharedInstance().setUserName("Test User")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
        
        //pk_test_Ggw24Zp9LLUXPXg0Aj9NCdVl00luVj0k0w
        
        STPPaymentConfiguration.shared().publishableKey = "pk_live_6RFRUzBWJvnXThGf56Dgeybo"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.golden-action-awards"        
        
        registerForPushNotifications(application: application)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        if let adminLoggedIn = KeychainWrapper.standard.data(forKey: Keys.isAdminLogin.key) {
            isAdminLoggedIn = true
        }else{
            isAdminLoggedIn = false
        }
        
        notifCenter.requestAuthorization(options: options) { (granted, ermror) in
            if !granted {
                // Put Alert are you sure
                
            } else {
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    Messaging.messaging().delegate = self
                    if Auth.auth().currentUser != nil {
                        Messaging.messaging().subscribe(toTopic: "77F4618DF6D8F0640C0D12A6A321DDEBE816F688A51018716827EAA2017FA4FE")//Auth.auth().currentUser!.uid)
                        Messaging.messaging().subscribe(toTopic: "000")
                        print("Subscribed")
                    }
                    UNUserNotificationCenter.current().delegate = self
                }
            }
        }
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            // true because content is delivered via the application
            print(payment)
            print(product)
            return true
        }
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            print("Fuck")
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    print(purchase)
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    print("Failed!!")
                    break // do nothing
                }
            }
        }
        
        self.logUser()
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)


        return true

        // return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "The_Golden_Action_Awards")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - GIDSignInDelegate
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if (extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard) {
            return false
        }
        return true
    }
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        //return handled
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
     /*   let valueTwitter =  TWTRTwitter.sharedInstance().application(app, open: url, options: options)

        let sourceApplication =  options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        
        let facebookDidHandle = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])

        return googleDidHandle || facebookDidHandle || valueTwitter */
       // return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)

        return handled
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        print("App Delegate")
        print("------------->")
        print(user.description)
        print(user.profile)
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        print(credential)
        let googleKey = Keys.google_creation.key
        let welcomeVC: WelcomeViewController = self.storyboard.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
        KeychainWrapper.standard.removeObject(forKey: googleKey)
        if KeychainWrapper.standard.hasValue(forKey: googleKey) {
            
        } else {
            Authorize.instance.createGoogleUser(credential: credential, view: welcomeVC) { (error, complete) in
                guard error == nil && !complete else {
                    print(error!.localizedDescription)
                    return
                }
                
            }
        }
        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}
extension AppDelegate {
    func registerForPushNotifications(application: UIApplication) {
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
        }
    }
    
    // MARK: Connecting to Firebase Notification (Cloud Messaging)
    @available(iOS 10.0, *)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let state = UIApplication.shared.applicationState
        
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
            self.badge += 1
            let content = UNMutableNotificationContent()
            content.badge = self.badge as NSNumber // your badge count
        }
        
        print("Push notifications recieved \(userInfo)")
        /*if state == .background {
         Messaging.messaging().appDidReceiveMessage(userInfo)
         completionHandler(UIBackgroundFetchResult.newData)
         } else {
         completionHandler(UIBackgroundFetchResult.noData)
         } */
        if state == .active || state == .background {
            Messaging.messaging().appDidReceiveMessage(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APN device token: \(deviceTokenString)")
        guard Messaging.messaging().apnsToken != nil else {
            print("Did not register for push notifications")
            return
        }
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APN Failed To Register \(error)")
    }
    
    func tokenRefreshNotif(_ notification: Notification) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                NotificationHelper.instance.currentUUID = result.token

            }
        }
        
//        if let refreshedTkn = InstanceID.instanceID().token() {
//            NotificationHelper.instance.currentUUID = refreshedTkn
//
//            print("InstanceID token: \(refreshedTkn)")
//
//        }
        connectToFIRMessage()
    }
    
    func refreshToken() {
        if let remeberedUUID = NotificationHelper.instance.currentUUID, remeberedUUID != "" {
            NotificationHelper.instance.checkRememberedUID(uuid: remeberedUUID, completion: { (success) in
                if success {
                    print("Refreshed Token Successfully")
                }
            })
        }
    }
    
    func connectToFIRMessage() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
                return
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }

//        guard InstanceID.instanceID().token() != nil else {
//            return
//        }
        Messaging.messaging().shouldEstablishDirectChannel = true
        //Messaging.messaging().disconnect()
        /* Messaging.messaging().connect { (error) in
         guard error == nil else {
         // print("Unable to connect to FIRMessanger \(error?.localizedDescription)")
         return
         }
         //print("Subscribed")
         //print("Connected to FIRMessanger")
         } */
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    internal func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge, .sound])
    }
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NotificationHelper.instance.currentUUID = fcmToken
        connectToFIRMessage()
    }
    
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("\(remoteMessage.appData)$$$$$$$$$$$$$$$$$$$$$$$")
        let message = remoteMessage.appData
        let title = message["title"] as? String ?? "N/A"
        print(title)
    }
    
  /*  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    } */

    
}

@available(iOS 10, *)
extension AppDelegate{
        
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            // Print message ID.
            //if let messageID = userInfo[gcmMessageIDKey] {
               // print("Message ID: \(messageID)")
           // }
            
            // Print full message.
            print(userInfo)
            
            completionHandler()
        }
    }


extension AppDelegate{
    
    func getTimePeriodFromFirebase(){
        
        var ref = CollectionFireRef.nominationPeriod.reference()
        ref.getDocuments(completion: { (snapshot, error) in
            if error == nil {
                if let data = snapshot?.documents {
                    
                }
            }
            
        })
        
    }
}
















