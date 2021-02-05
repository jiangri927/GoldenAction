//
//  SettingsTableViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import NYAlertViewController
import BWWalkthrough
import SAConfettiView
import FirebaseStorage
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    // MARK: Bar Button Declaration
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var checkoutButton: UIBarButtonItem!
    
    var currentUser: Person!
    
    var walkthrough: BWWalkthroughViewController!
    var page_one: FirstGoldenTutorialViewController!
    
    var settingsSelection1: [[String : Any]] {
        return [
            //["title": "Rate the app", "description": "If you like The Golden Action Awards, please allow support by rating us"],
            ["title": "Send Feedback", "description": "If you found an issue in this app, let us know right away"],
            ["title": "FAQ's", "description": " FAQ is an online document that poses a series of common questions and answers on a specific topic."],
            ["title": "About the app", "description": "Get to know the application, the creators and the new updates of this app!"],
            ["title": "Privacy Policy", "description": "Our protocols of confidentiality"],
        ]
    }
    
    var settingsSelection2: [[String : Any]] {
        return [
            ["title": "Sponsor Login", "description": "Nomination Sponsor Login Here"],
            ["title": "Logout", "description": "You will still be able to view content, but will lose all data from before!"]
        ]
    }
    
    
    var settingsSelection3: [[String : Any]] {
        return [
            ["title": "Sponsor Login", "description": "Nomination Sponsor Login Here"],
            ["title": "Login", "description": "You will still be able to view content, but will lose all data from before!"]
        ]
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNav()
        NotificationCenter.default.addObserver(self, selector: #selector(self.nameOfFunction), name: NSNotification.Name(rawValue: "logoutNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNav()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func nameOfFunction(notif: NSNotification) {
        self.profileButton.customView?.removeFromSuperview()
        self.profileButton.customView = nil
        self.profileButton.image = UIImage(named: "profileicon")
        self.tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Navigation Controller Setup
    func setUpNav() {
        // Navigation Bar Color
        self.setBarTint()
        self.setBarButtonTint()
        self.designTableView()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : Colors.settings_title.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)]
        self.checkoutButton.action = #selector(checkoutSegue(_:))
        self.checkoutButton.target = self
        self.profileButton.target = self
        self.profileButton.action = #selector(self.profileSegue(_:))
        
        self.notificationButton.action = #selector(notificationSegue(_:))
        self.notificationButton.target = self
        self.loadCurrentUser()
    }
    
    func loadAdminPanel(){
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        if self.currentUser.admin == true {
            self.performSegue(withIdentifier: SegueId.profile_admin.id, sender: self)
        }
    }
    
    func loadCurrentUser() {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            self.loadPerson(uid: uid)
        } else {
            if KeychainWrapper.standard.hasValue(forKey: Keys.download_check.key) {
                Auth.auth().signInAnonymously { (user, error) in
                    if error != nil {
                        let err = error! as NSError
                        Authorize.instance.handleAlert(error: err, view: self)
                    } else {
                        let uid = user?.user.uid ?? "none"
                        self.loadPerson(uid: uid)
                    }
                    
                }
            } else {
                //                let vcid = VCID.tutorial_one.id
                //                let tutorialVC = self.storyboard?.instantiateViewController(withIdentifier: vcid) as! UINavigationController
                //                self.present(tutorialVC, animated: true, completion: nil)
            }
        }
    }
    func loadPerson(uid: String) {
        Person.loadCurrentPerson(uid: uid) { (error, current) in
            guard error == nil && current != nil else {
                self.goldenAlert(title: "Error", message: "Error loading person please check your internet connection and try again", view: self)
                return
            }
            self.currentUser = current!
            self.configureProfilePicture()
        }
    }
    
    @objc func profileSegue(_ sender: UIButton) {
        guard Auth.auth().currentUser != nil else {
            let workItem = DispatchWorkItem {
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
            return
        }
        guard self.currentUser != nil else {
            let workItem = DispatchWorkItem {
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
            return
        }
        
        
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.settings_profile.id, sender: self)
        } else {
            let workItem = DispatchWorkItem {
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        
        
    }
    
    @objc func notificationSegue(_ sender: UIBarButtonItem) {
        guard Auth.auth().currentUser != nil else {
            self.goldenAlert(title: "Notification Error", message: "Current user is already logedout, please login once!", view: self)
            return
        }
        /* let notifVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.notification_screen.id) as! NotificationViewController
         let navController = UINavigationController(rootViewController: notifVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
         self.present(navController, animated:true, completion: nil) */
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.settings_notif.id, sender: self)
        } else {
            let workItem = DispatchWorkItem {
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        
    }
    @objc func checkoutSegue(_ sender: UIBarButtonItem) {
        guard Auth.auth().currentUser != nil else {
            self.goldenAlert(title: "Checkout Error", message: "Current user is already loggdout, please login once!", view: self)
            return
        }
        
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.settings_cart.id, sender: self)
        } else {
            let workItem = DispatchWorkItem {
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.settings_profile.id {
            let destinationVC = segue.destination as! ProfileTableViewController
            self.loadCurrentUser()
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.settings_cart.id {
            let destinationVC = segue.destination as! CartViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.settings_notif.id {
            let destinationVC = segue.destination as! NotificationViewController
            destinationVC.currentUser = self.currentUser
        }else if segue.identifier == SegueId.profile_admin.id {
            let distinationVC = segue.destination as! AdminTabViewController
        }
    }
    
    // MARK: - Table view data source
    func designTableView() {
        let view = UIView()
        view.backgroundColor = Colors.app_tableview_background.generateColor()
        self.tableView.tableFooterView = view
        self.tableView.separatorColor = Colors.app_tableview_seperator.generateColor()
        self.tableView.backgroundColor = Colors.app_tableview_background.generateColor()
        self.tableView.allowsSelection = true
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        let imageColor1 = self.gradient(size: header.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        if section == 0 {
            view.tintColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1)
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.init(patternImage: imageColor1!)
            let formattedString = NSMutableAttributedString()
            formattedString.bold("Settings", fontSize: 21.0)
            header.textLabel?.attributedText = formattedString
        }else{
            view.tintColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1)
            header.textLabel?.textColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
            header.textLabel?.font = UIFont.init(name: "Avenir Next", size: 15.0)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 75
        }
        return 25.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Settings"
        }else{
            return "Authentication"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.settingsSelection1.count
        }else{
            return self.settingsSelection2.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.settings_cell.id, for: indexPath) as! SettingsTableViewCell
        if indexPath.section == 0{
            let item = self.settingsSelection1[indexPath.row]
            cell.configureCell(item: item)
        }else{
            
            
            
            
            let item = self.settingsSelection2[indexPath.row]
            cell.configureCell(item: item)
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.handleRows(row: indexPath)
    }
    
    
    func handleRows(row: IndexPath)
    {
        if row.section == 0
        {
            if row.row == 0
            {
                let workItem = DispatchWorkItem
                {
                    let work = DispatchWorkItem
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    guard Auth.auth().currentUser != nil else{
                        self.goldenAlert(title: "Feedback Error", message: "Current user is already logedout, please login once!", view: self)
                        return
                    }
                    
                    self.showFeedback(currentUser: self.currentUser, workItem: work)
                }
                UserSettingsMenu.feedback.routeSideMenu(vc: workItem)
            }
            else if row.row == 1
            {
                let workItem = DispatchWorkItem {
                let privacy = self.storyboard?.instantiateViewController(withIdentifier: "FaqViewController") as! FaqViewController
                let navVC = UINavigationController(rootViewController: privacy)
               // privacy.settings = true
                self.present(navVC, animated: true, completion: nil)
                }
                UserSettingsMenu.privacyPolicy.routeSideMenu(vc: workItem)
            }
            else if row.row == 2
            {
                let workItem = DispatchWorkItem {
                    self.setUpTutorialWalkthrough()
                }
                UserSettingsMenu.about.routeSideMenu(vc: workItem)
            }
            else if row.row == 3
            {
                let workItem = DispatchWorkItem {
                    let privacy = self.storyboard?.instantiateViewController(withIdentifier: VCID.signup_legal.id) as! SignupLegalViewController
                    let navVC = UINavigationController(rootViewController: privacy)
                    privacy.settings = true
                    self.present(navVC, animated: true, completion: nil)
                }
                UserSettingsMenu.privacyPolicy.routeSideMenu(vc: workItem)
            }
        }else
        {
            if row.row == 0
            {
                guard Auth.auth().currentUser == nil else{
                    if self.currentUser.admin == true {
                        self.loadAdminPanel()
                    }else{
                        self.goldenAlert(title: "Sponsor Login Error", message: "You are not set as an admin.", view: self)
                        return
                    }
                    return
                }
//                let workItem = DispatchWorkItem {
//                    let adminLogin = self.storyboard?.instantiateViewController(withIdentifier: VCID.admin_welcome.id) as! WelcomeAdminViewController
//                    self.present(adminLogin, animated: true, completion: nil)
//
//                }
//                UserSettingsMenu.adminLogin.routeSideMenu(vc: workItem)
                
            }
            else if row.row == 1
            {
                let workItem = DispatchWorkItem
                {
                    let work = DispatchWorkItem
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    guard Auth.auth().currentUser != nil else{
                        self.goldenAlert(title: "Delete Error", message: "Current user is already loggedout, please login once!", view: self)
                        return
                    }
                    guard self.currentUser != nil else{
                        self.goldenAlert(title: "Delete Error", message: "Current user is already loggedout, please login once!", view: self)
                        return
                    }
                    
                    if self.currentUser.acctType != "anon" {
                        self.showDelete(currentUser: self.currentUser!, workItem: work)
                    } else {
                        self.goldenAlert(title: "Delete Error", message: "Current user is already loggedout, please login once!", view: self)
                        return
                    }
                    
                    
                }
                UserSettingsMenu.deleteAccount.routeSideMenu(vc: workItem)
                
            }
        }
        
        
    }
    
    // MARK: Add Gesture Recognizer for Seguing to next cells
    
    func deleteAccountView() {
        // let sclAppearance
    }
    
}
extension SettingsTableViewController: BWWalkthroughViewControllerDelegate {
    
    func setUpTutorialWalkthrough() {
        let sub = UIStoryboard(name: "Main", bundle: nil)
        self.walkthrough = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial.id) as! BWWalkthroughViewController
        self.page_one = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_one.id) as! FirstGoldenTutorialViewController
        let page_two = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_two.id) as! BWWalkthroughPageViewController
        let page_three = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_three.id) as! BWWalkthroughPageViewController
        let page_four = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_four.id) as! BWWalkthroughPageViewController
        let page_five = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_five.id) as! BWWalkthroughPageViewController
        self.walkthrough.delegate = self
        self.walkthrough.add(viewController: self.page_one)
        self.walkthrough.add(viewController: page_two)
        self.walkthrough.add(viewController: page_three)
        self.walkthrough.add(viewController: page_four)
        self.walkthrough.add(viewController: page_five)
        //self.providesPresentationContextTransitionStyle = true
        //self.definesPresentationContext = true
        self.modalPresentationCapturesStatusBarAppearance = false
        self.present(self.walkthrough, animated: true, completion: nil)
    }
    func walkthroughPageDidChange(_ pageNumber: Int) {
        if (self.walkthrough.numberOfPages - 1) == pageNumber {
            
        } else if pageNumber == 0 {
            self.walkthrough.prevButton?.isHidden = true
            if let vc = self.walkthrough.currentViewController as? FirstGoldenTutorialViewController {
                // vc.confettiView.startConfetti()
            } else {
                //                if !self.page_one.confettiView.isActive() {
                //                    self.page_one.confettiView.startConfetti()
                //                }
            }
        } else {
            self.walkthrough.prevButton?.isHidden = false
            //            if self.page_one.confettiView.isActive() {
            //                self.page_one.confettiView.stopConfetti()
            //            }
        }
        
    }
    
    func walkthroughNextButtonPressed() {
        if self.walkthrough.currentPage == 0 {
            if let vc = self.walkthrough.currentViewController as? FirstGoldenTutorialViewController {
                //                if vc.confettiView.isActive() {
                //                    vc.confettiView.startConfetti()
                //                }
            } else {
                //                if !self.page_one.confettiView.isActive() {
                //                    self.page_one.confettiView.startConfetti()
                //                }
            }
        } else if self.walkthrough.currentPage == 1 {
            //            if self.page_one.confettiView.isActive() {
            //                self.page_one.confettiView.stopConfetti()
            //            }
        } else if self.walkthrough.currentPage == 4 {
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func walkthroughPrevButtonPressed() {
        if self.walkthrough.currentPage == 0 {
            if let vc = self.walkthrough.currentViewController as? FirstGoldenTutorialViewController {
                // vc.confettiView.startConfetti()
            }
        }
    }
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension SettingsTableViewController{
    
    func configureProfilePicture(){
        guard self.currentUser != nil else {
            return
        }
        // self.activityView.startAnimating()
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            
            print("*****Profile Pic ******** \(imageUrl)")
            
            //   let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            storageRef.downloadURL(completion: { (url, error) in
                // self.activityView.stopAnimating()
                guard url != nil else {
                    return
                }
                do{
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    
                    let button = UIButton(type: .custom)
                    button.setImage(image, for: .normal)
                    button.isUserInteractionEnabled = true
                    //button.contentMode = UIViewContentMode.scaleAspectFill
                    button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
                    button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
                    button.layer.masksToBounds = true
                    button.layer.cornerRadius = button.bounds.size.width / 2
                    button.addTarget(self, action: #selector(self.profileSegue(_:)), for: .touchUpInside)
                    self.profileButton.customView = button
                }catch{
                    print(error)
                }
            })
        }
    }
    
    
}
