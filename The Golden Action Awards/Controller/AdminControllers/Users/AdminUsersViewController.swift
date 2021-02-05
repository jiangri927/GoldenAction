//
//  AdminUsersViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/12/18.
//  Copyright © 2019 Sudesh Kumar. All rights reserved.
//

import UIKit
import Firebase
import SideMenu

enum AdminAction{
    case delete
    case banned
    case active
    case adminApproved
    case userApproved
    case userReject
    case lastSelectedOption
    case finished
    case adminReject
    case charityDone
    
    public var id:String{
        var lastOption:String!
        switch self {
        case .delete:
            lastOption = "Delete"
            return "delete"
        case .banned:
            lastOption = "Banned"
            return "banned"
        case .active:
            lastOption = "Active"
            return "active"
        case .adminApproved:
            lastOption = "Admin Aproved"
            return "adminApproved"
        case .userApproved:
            lastOption = "User Approved"
            return "userApproved"
        case .userReject:
            lastOption = "User Rejected"
            return "userRejected"
        case .lastSelectedOption:
            return lastOption ?? ""
        case .finished:
            return "nomineeAwarded"
        case .adminReject:
            return "adminReject"
        case .charityDone:
            return "charityDone"
        }
    }
}
class AdminUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    //    @IBOutlet weak var allUsersButton: UIButton!
    //    @IBOutlet weak var bannedUsersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var currentUser: Person!
    var usersRegion = [Person]()
    
    var activeUser = [Person]()
    var bannedUser = [Person]()
    
    let unselectedColor = UIColor.clear
    let selectedColor = Colors.app_text.generateColor()
    
    var isAll = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.backgroundColor = UIColor.black
        self.designTableView(tableView: self.tableView)
        self.tapDismiss()
        self.setBarTint()
        self.loadPerson()
        self.setUpNav()
        //self.setupButtons(isAll: self.isAll, firstLoad: true)
        //        self.allUsersButton.addTarget(self, action: #selector(allUsersTapped(_:)), for: .touchUpInside)
        //        self.bannedUsersButton.addTarget(self, action: #selector(bannedUsersTapped(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        getAllActiveAndBannedUser()
        configureProfilePicture()
        
        setupSegmentedControl()
        self.segmentedControll.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        self.segmentedControll.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .selected)
        self.updateGradientBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let image2 = self.gradient(size: self.segmentedControll.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.segmentedControll.layer.borderColor = UIColor.init(patternImage: image2).cgColor
        
        
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        self.updateGradientBackground()
        if sender.selectedSegmentIndex == 0 {
            //if !(self.allUsersButton.backgroundColor == self.selectedColor) {
            self.isAll = true
            //self.setupButtons(isAll: self.isAll, firstLoad: false)
            self.tableView.reloadData()
            //}
            
        }else{
            //if !(self.bannedUsersButton.backgroundColor == self.selectedColor) {
            self.isAll = false
            // self.setupButtons(isAll: self.isAll, firstLoad: false)
            self.tableView.reloadData()
            //}
        }
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        self.segmentedControll.removeAllSegments()
        self.segmentedControll.insertSegment(withTitle: "All Users", at: 0, animated: false)
        self.segmentedControll.insertSegment(withTitle: "Banned Users", at: 1, animated: false)
        self.segmentedControll.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        self.segmentedControll.layer.borderWidth = 2
        self.segmentedControll.layer.masksToBounds = true
        self.segmentedControll.layer.cornerRadius = 8
        self.segmentedControll.selectedSegmentIndex = 0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getAllActiveAndBannedUser(){
        self.activeUser.removeAll()
        self.bannedUser.removeAll()
        
        Person.getAllUsers(){ (users) in
            guard users != nil else{
                return
            }
            for usr in users! {
                if usr.banned == true {
                    if !self.bannedUser.contains(usr) && !usr.fullName.contains(find: "Anonymous") {
                        self.bannedUser.append(usr)
                    }
                }else{
                    if !self.activeUser.contains(usr) && !usr.fullName.contains(find: "Anonymous") {
                        self.activeUser.append(usr)
                    }
                }
            }
            //            self.activeUser.sort()
            self.bannedUser.sort(by: {$0.fullName < $1.fullName})
            self.activeUser.sort(by: {$0.fullName < $1.fullName})
            
            self.tableView.reloadData()
        }
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
            Messaging.messaging().subscribe(toTopic: current!.region)
        }
    }
    func setUpNav() {
        self.setBarTint()
        self.setBarButtonTint()
        self.notificationButton.action = #selector(notificationTapped(_:))
        self.notificationButton.target = self
        self.profileButton.action = #selector(profileTapped(_:))
        self.profileButton.target = self
    }
    @objc func profileTapped(_ sender: Any) {
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
    
    @objc func notificationTapped(_ sender: Any) {
        let notifVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.notification_screen.id) as! NotificationViewController
        notifVC.currentUser = self.currentUser
        notifVC.admin = true
        self.navigationController?.pushViewController(notifVC, animated: true)
    }
    
    //    @objc func allUsersTapped(_ sender: UIButton) {
    //        if !(self.allUsersButton.backgroundColor == self.selectedColor) {
    //            self.isAll = true
    //            self.setupButtons(isAll: self.isAll, firstLoad: false)
    //            self.tableView.reloadData()
    //        }
    //    }
    //
    //    @objc func bannedUsersTapped(_ sender: UIButton) {
    //        if !(self.bannedUsersButton.backgroundColor == self.selectedColor) {
    //            self.isAll = false
    //            self.setupButtons(isAll: self.isAll, firstLoad: false)
    //            self.tableView.reloadData()
    //        }
    //    }
    
    //    func setupButtons(isAll: Bool, firstLoad: Bool) {
    //        if firstLoad {
    //            self.designButton(button: self.bannedUsersButton)
    //            self.designButton(button: self.allUsersButton)
    //        }
    //        if isAll {
    //            self.designSelectedButton(button: self.allUsersButton)
    //            self.designUnselectedButton(button: self.bannedUsersButton)
    //        } else {
    //            self.designSelectedButton(button: self.bannedUsersButton)
    //            self.designUnselectedButton(button: self.allUsersButton)
    //        }
    //    }
    
    func designSelectedButton(button: UIButton!) {
        button.setTitleColor(UIColor.black, for: [])
        button.backgroundColor = self.selectedColor
    }
    
    func designUnselectedButton(button: UIButton!) {
        button.setTitleColor(self.selectedColor, for: [])
        button.backgroundColor = self.unselectedColor
    }
    
    func designButton(button: UIButton!) {
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = false
        button.layer.borderWidth = 1.0
        button.layer.borderColor = self.selectedColor.cgColor
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var selectedUserId:String!
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            if self.isAll {
                let tmpPerson = self.activeUser[indexPath.row]
                selectedUserId = tmpPerson.uid
                self.updateUsersStatus(action: AdminAction.delete.id, uid: selectedUserId)
                self.activeUser.remove(at: indexPath.row)
            }else{
                let tmpPerson = self.bannedUser[indexPath.row]
                selectedUserId = tmpPerson.uid
                self.updateUsersStatus(action: AdminAction.delete.id, uid: selectedUserId)
                self.bannedUser.remove(at: indexPath.row)
            }
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let action = UITableViewRowAction(style: .default, title:self.isAll ? "Banned" : "Active") { (action, indexPath) in
            
            if self.isAll{
                let tmpPerson = self.activeUser[indexPath.row]
                selectedUserId = tmpPerson.uid
                self.updateUsersStatus(action: AdminAction.banned.id, uid: selectedUserId)
            }else{
                let tmpPerson = self.bannedUser[indexPath.row]
                selectedUserId = tmpPerson.uid
                self.updateUsersStatus(action: AdminAction.active.id, uid: selectedUserId)
            }
            
        }
        
        action.backgroundColor = UIColor.lightGray
        
        return [delete, action]
        
    }
    
    func updateUsersStatus(action:String, uid:String) {
        
        self.updateUserValue(action:action, uid: uid, completion: { status in
            if status == true{
                self.goldenAlert(title: "User Updated", message: "", view: self)
                self.getAllActiveAndBannedUser()
                
            }
        })
    }
    
    func updateUserValue(action:String, uid:String, completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = DBRef.user(uid: uid).reference()
            if action == AdminAction.delete.id {
                ref.removeValue { error, _ in
                    //print(error!)
                }
            }else{
                ref.updateChildValues([AdminAction.banned.id:self.isAll])
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
    }
    
    // MARK: - Segue to Detail Gesture Recognizer
    @objc func toDetail(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            //            guard Auth.auth().currentUser != nil else{
            //                self.goldenAlert(title: "Login Error", message: "Account doesn't exist, please login first!", view: self)
            //                return
            //            }
            let tapCell = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                if let tapCell = self.tableView.cellForRow(at: indexPath) as? AdminUsersTableViewCell {
                    
                    // MARK: - Pass data from this cell to nom detail controller
                    print("Tap Recognized")
                    let profileVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.profile.id) as! ProfileTableViewController
                    profileVC.currentUser = tapCell.person
                    profileVC.admin = true
                    profileVC.isOtherUserProfile = true
                    self.navigationController?.pushViewController(profileVC, animated: true)
                    
                    // let navVC = UINavigationController(rootViewController: nomDetailVC)
                    // self.present(navVC, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isAll {
            return self.activeUser.count
        }else{
            return self.bannedUser.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numSections = 1
        return numSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellId.admin_users.id, for: indexPath) as! AdminUsersTableViewCell
        let person:Person!
        if self.isAll{
            person = self.activeUser[indexPath.row]
        }else{
            person = self.bannedUser[indexPath.row]
        }
        cell.person = person
        //NukeLoad.admin_cells.imageLoadFinish(view: cell.profilePicture, urlString: person.profilePictureURL)
        cell.profileName.text = person.fullName
        cell.profileName.textColor = Colors.nom_detail_innerBorder.generateColor()
        
        cell.personUID = person.uid
        cell.downloadImageFromFirebase()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cell.profilePicture.addGestureRecognizer(tap)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
        cell.addGestureRecognizer(gesture)
        
        cell.setUpPic()
        
        return cell
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.usersRegion.count {
            return 85.0
        } else {
            return 85.0
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.usersRegion.count {
            return 85.0
        } else {
            return 85.0
        }
    }
    
    
}
extension AdminUsersViewController {
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard is hidden")
    }
    
    /* func searchUsers(txt: String) {
     guard txt != "" else {
     return
     }
     var ref: Index!
     if self.allUsersButton.backgroundColor == self.selectedColor {
     ref = AlgoliaRef.users.reference()
     } else {
     ref = AlgoliaRef.banned_users.reference()
     }
     Person.searchUsers(query: txt, ref: ref) { (persons) in
     self.usersRegion = persons
     self.tableView.reloadData()
     }
     }*/
}
extension UIViewController {
    func designTableView(tableView: UITableView) {
        let view = UIView()
        let px = 2 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: px)
        let line = UIView(frame: frame)
        view.backgroundColor = Colors.app_tableview_background.generateColor()
        tableView.tableFooterView = view
        tableView.separatorColor = UIColor.black
        tableView.backgroundColor = UIColor.black
        tableView.allowsSelection = false
        tableView.tableHeaderView = line
        line.backgroundColor = Colors.app_tableview_seperator.generateColor()
    }
}

extension AdminUsersViewController{
    
    func configureProfilePicture(){
        guard self.currentUser != nil else {
            return
        }
        // self.activityView.startAnimating()
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            
//            var imageV : UIImageView
//            imageV  = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 40));
//            imageV.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "profileicon"))
            
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
                    button.addTarget(self, action: #selector(self.profileTapped), for: .touchUpInside)
                    self.profileButton.customView = button
                }catch{
                    print(error)
                }
            })
        }
    }
    
    fileprivate func updateGradientBackground() {
        let image = self.gradient(size: self.segmentedControll.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        
        let sortedViews = self.segmentedControll.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        for (index, view) in sortedViews.enumerated() {
            if index == self.segmentedControll.selectedSegmentIndex {
                //very important thing to notice here is because tint color was not honoring the `UIColor(patternImage` I rather used `backgroundColor` to create the effect and set clear color as clear color
                view.backgroundColor = UIColor(patternImage: image)
                view.tintColor = UIColor.clear
            } else {
                //very important thing to notice here is because tint color was not honoring the `UIColor(patternImage` I rather used `backgroundColor` to create the effect and set clear color as clear color
                view.backgroundColor = .clear //Whatever the color of non selected segment controller tab
                //view.tintColor = UIColor.whi
            }
        }
    }
    
}



