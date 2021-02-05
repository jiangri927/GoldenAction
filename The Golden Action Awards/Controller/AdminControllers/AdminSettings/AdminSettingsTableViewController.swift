//
//  AdminSettingsTableViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import MessageUI
import FirebaseAuth
import FirebaseStorage

class AdminSettingsTableViewController: UITableViewController {

    // MARK: Bar Button Declaration
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var currentUser: Person!
    
    var settingsSelection: [[String : Any]] {
//        return [
//           // ["title": "Job Duties", "description": "What are you duties for being a nomination sponsor"],
//            ["title": "Send Feedback", "description": "If you found an issue in this app, let us know right away"],
//            ["title": "Contact the Owners", "description": "Get to know us or ask us anything!"],
//            ["title": "Privacy Policy", "description": "Our protocols of confidentiality"],
//            ["title": "Back to Main App", "description": "Go back to app home screen"],
//           // ["title": "Stop being a sponsor", "description": "You will still have your account, but will no longer have admin features"]
//        ]
        
        
        return [
            ["title": "Send Feedback", "description": "If you found an issue in this app, let us know right away"],
            ["title": "Contact the Owners", "description": "Get to know us or ask us anything!"],
            ["title": "Privacy Policy", "description": "Our protocols of confidentiality"],
            ["title": "Back to Main App", "description": "Go back to app home screen"]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNav()
        self.loadPerson()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation Controller Setup
    func setUpNav() {
        // Navigation Bar Color
        self.setBarTint()
        self.setBarButtonTint()
        self.designTableView()
        //self.navigationController?.navigationItem.title = "Settings"
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : Colors.settings_title.generateColor(), NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)]
        self.profileButton.action = #selector(profileSegue(_:))
        self.profileButton.target = self
        self.notificationButton.action = #selector(notificationSegue(_:))
        self.notificationButton.target = self
        
    }
    
    func loadPerson() {
        let uid = Auth.auth().currentUser!.uid
        Person.loadCurrentPerson(uid: uid) { (error, current) in
            guard error == nil && current != nil else {
                self.goldenAlert(title: "Error", message: "Error loading person please check your internet connection and try again", view: self)
                return
            }
            self.currentUser = current!
            self.configureProfilePicture()
        }
    }
    @objc func profileSegue(_ sender: UIBarButtonItem) {
        let workItem = DispatchWorkItem {
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.profile.id) as! ProfileTableViewController
            profileVC.currentUser = self.currentUser
            profileVC.admin = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        let ownerItem = DispatchWorkItem {
            self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        }
        if self.currentUser.owner {
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(30), execute: ownerItem)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30), execute: workItem)
        }

    }
    @objc func notificationSegue(_ sender: UIBarButtonItem) {
        let notifVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.notification_screen.id) as! NotificationViewController
        notifVC.currentUser = self.currentUser
        notifVC.admin = true
        self.navigationController?.pushViewController(notifVC, animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.settings_profile.id {
            let destinationVC = segue.destination as! ProfileTableViewController
         //destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.settings_notif.id {
            let destinationVC = segue.destination as! AdminNotificationsViewController
         //destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.admin_settings_home.id {
            let destinationVC = segue.destination as! MainTabViewController
            
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.admin_settings.id, for: indexPath) as! AdminSettingsTableViewCell
        let item = self.settingsSelection[indexPath.row]
        // Configure the cell...
        cell.configureCell(item: item)
        return cell
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
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 75
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.handleRows(row: indexPath.row)
            // self.performSegue(withIdentifier: SegueId.admin_settings_home.id, sender: self)
        }
    }
    func handleRows(row: Int) {
//        if row == 0 {
//            AdminSettingsMenu.duties.routeSideMenu(vc: self, currentUser: self.currentUser)
//        } else
            if row == 0 {
            
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
            
           // AdminSettingsMenu.feedback.routeSideMenu(vc: self, currentUser: self.currentUser)
            
        } else if row == 1 {
            
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            AdminSettingsMenu.contactOwners.routeSideMenu(vc: self, currentUser: self.currentUser)
            
        } else if row == 2 {
            
            let privacy = self.storyboard?.instantiateViewController(withIdentifier: VCID.signup_legal.id) as! SignupLegalViewController
            let navVC = UINavigationController(rootViewController: privacy)
            privacy.settings = true
            self.present(navVC, animated: true, completion: nil)
            AdminSettingsMenu.privacyPolicy.routeSideMenu(vc: self, currentUser: self.currentUser)
            
        } else if row == 3 {
            AdminSettingsMenu.backToMain.routeSideMenu(vc: self, currentUser: self.currentUser)
        }
//            else if row == 5 {
//            AdminSettingsMenu.stopSponsor.routeSideMenu(vc: self, currentUser: self.currentUser)
//        }
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
    
    

}

extension AdminSettingsTableViewController{
    
    func configureProfilePicture(){
        guard self.currentUser != nil else {
            return
        }
        // self.activityView.startAnimating()
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            //let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"

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
                    //button.addTarget(self, action: #selector(self.profileTapped), for: .touchUpInside)
                    self.profileButton.customView = button
                }catch{
                    print(error)
                }
            })
        }
    }
    
}



extension AdminSettingsTableViewController: MFMessageComposeViewControllerDelegate , MFMailComposeViewControllerDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["admin@goldenactionawards.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
