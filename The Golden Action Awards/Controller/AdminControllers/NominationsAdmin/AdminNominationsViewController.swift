//
//  AdminNominationsViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
//import AlgoliaSearch
import Firebase
import Toucan
import SideMenu
import FirebaseStorage
import FirebaseAuth
import FirebaseMessaging

class AdminNominationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    //    @IBOutlet weak var activeButton: UIButton!
    //    @IBOutlet weak var approvalNeeded: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    var currentUser: Person!
    var nominations = [Nominations]()
    var pendingNomination = [Nominations]()
    
    let unselectedColor = UIColor.clear
    let selectedColor = Colors.app_text.generateColor()
    
    var isApproval = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.backgroundColor = UIColor.black
        self.designTableView(tableView: self.tableView)
        self.tapDismiss()
        self.loadPerson()
        self.setUpNav()
        //        self.setupButtons(isApproval: self.isApproval, firstLoad: true)
        //        self.activeButton.addTarget(self, action: #selector(activeDidTap(_:)), for: .touchUpInside)
        //        self.approvalNeeded.addTarget(self, action: #selector(approvalDidTap(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
        
        setupSegmentedControl()
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .selected)
        self.updateGradientBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let image2 = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.segmentController.layer.borderColor = UIColor.init(patternImage: image2).cgColor
        
        
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        self.updateGradientBackground()
        if sender.selectedSegmentIndex == 0 {
            //if !(self.allUsersButton.backgroundColor == self.selectedColor) {
            self.isApproval = true
            //self.setupButtons(isApproval: self.isApproval, firstLoad: false)
            self.tableView.reloadData()
            //}
            
        }else{
            //if !(self.bannedUsersButton.backgroundColor == self.selectedColor) {
            self.isApproval = false
            // self.setupButtons(isApproval: self.isApproval, firstLoad: false)
            self.tableView.reloadData()
            //}
        }
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        self.segmentController.removeAllSegments()
        self.segmentController.insertSegment(withTitle: "Approval Needed", at: 0, animated: false)
        self.segmentController.insertSegment(withTitle: "Active", at: 1, animated: false)
        self.segmentController.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        self.segmentController.layer.borderWidth = 2
        self.segmentController.layer.masksToBounds = true
        self.segmentController.layer.cornerRadius = 8
        self.segmentController.selectedSegmentIndex = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllNomination()
        loadAdminPendingNomination()
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
    
    func loadAdminPendingNomination(){
        self.pendingNomination = []
        Nominations.getAllAdminPendingNomination(){(error, noms) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            for nom in noms {
//                if !self.pendingNomination.contains(nom) {
                    self.pendingNomination.append(nom)
//                }
            }
            print("Pending Noms Got")
            self.pendingNomination.sort()
            self.tableView.reloadData()
        }
    }
    
    func loadAllNomination(){
        self.nominations = []
        Nominations.getAllNomination(){(error, noms) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            for nom in noms {
                if !self.nominations.contains(nom) {
                    
                    if(nom.phase == 4){
                        
                    }else{
                        self.nominations.append(nom)
                    }
                    
                }
            }
            print(noms.count)
            print("Noms Got")
            self.nominations.sort()
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //    @objc func activeDidTap(_ sender: UIButton) {
    //        if !(self.activeButton.backgroundColor == self.selectedColor) {
    //            self.isApproval = false
    //            self.setupButtons(isApproval: self.isApproval, firstLoad: false)
    //            self.tableView.reloadData()
    //        }
    //    }
    //
    //    @objc func approvalDidTap(_ sender: UIButton) {
    //        if !(self.approvalNeeded.backgroundColor == self.selectedColor) {
    //            self.isApproval = true
    //            self.setupButtons(isApproval: self.isApproval, firstLoad: false)
    //            self.tableView.reloadData()
    //        }
    //    }
    
    //    func setupButtons(isApproval: Bool, firstLoad: Bool) {
    //        if firstLoad {
    //            self.designButton(button: self.activeButton)
    //            self.designButton(button: self.approvalNeeded)
    //        }
    //        if isApproval {
    //            self.designSelectedButton(button: self.approvalNeeded)
    //            self.designUnselectedButton(button: self.activeButton)
    //        } else {
    //            self.designSelectedButton(button: self.activeButton)
    //            self.designUnselectedButton(button: self.approvalNeeded)
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
    
    // MARK: - Segue to Detail Gesture Recognizer
    @objc func toDetail(recognizer: UITapGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            guard Auth.auth().currentUser != nil else{
                self.goldenAlert(title: "Login Error", message: "Account doesn't exist, please login first!", view: self)
                return
            }
            let tapCell = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                if let tapCell = self.tableView.cellForRow(at: indexPath) as? AdminNominationsTableViewCell {
                    // MARK: - Pass data from this cell to nom detail controller
                    print("Tap Recognized")
                    let nomDetailVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.nominee_detail.id) as! NomDetailTableViewController
                    nomDetailVC.isOpenFromAdmin = true
                    nomDetailVC.nomination = tapCell.nom
                    nomDetailVC.currentUser = self.currentUser
                    let navVC = UINavigationController(rootViewController: nomDetailVC)
                    self.present(navVC, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.isApproval {
//            return self.pendingNomination.count
//        }else{
//            return self.nominations.count
//        }
        
        
        if self.isApproval  {
            return self.pendingNomination.count > 0 ? self.pendingNomination.count : 1
        }else{
            return self.nominations.count > 0 ? self.nominations.count : 0
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var nom:Nominations!
        
        if self.isApproval
        {
            if self.pendingNomination.count > 0
            {
                nom = self.pendingNomination[indexPath.row]
            }
            else
            {
                let PendingNotFound = self.tableView.dequeueReusableCell(withIdentifier: "PendingNotFound")
                return PendingNotFound!
            }
            
            //nom = self.pendingNomination[indexPath.row]
        }
        else
        {
            nom = self.nominations[indexPath.row]
        }
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellId.admin_noms.id, for: indexPath) as! AdminNominationsTableViewCell
        cell.btnFinish.alpha = 0.0
        cell.nom = nom
        cell.downloadImageFromFirebase()
        // Category Used as time && nominee pic used as category icon
        
        
        if self.isApproval
        {
            let date = Date(timeIntervalSince1970: nom.startDate)
            let easyStr = date.toStringWithRelativeTime()
            cell.category.text = easyStr
            if nom.urls != []
            {
            }
            else
            {
                cell.nomineePic.image = self.generateIcon(currentCategory: nom.category)
                cell.nomineePic.contentMode = .scaleAspectFit
            }
            cell.nomineeStatus.text = ""
        }
        else
        {
            cell.category.text = nom.category
            
            if nom.phase == 4
            {
                cell.nomineeStatus.text = "Voting Closed"
            }
            else
            {
                cell.nomineeStatus.text = ""
            }
            cell.btnFinish.alpha = 1.0
        }
        cell.nomineeName.text = nom.nominee.fullName
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
        cell.addGestureRecognizer(gesture)
        
        cell.setUpPic()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.nominations.count {
            return 75.0
        } else {
            return 75.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.nominations.count {
            return 75.0
        } else {
            return 75.0
        }
    }
    
   
    
    func updateNomineeStatus(action:String, uid:String) {

        self.updateNomValue(action:action, uid: uid, completion: { status in
            if status == true{
                self.goldenAlert(title: "Admin Approval", message: "Congratulations! Your action\(AdminAction.lastSelectedOption.id) is processing.", view: self)
                self.loadAllNomination()
                self.loadAdminPendingNomination()

            }
        })
    }

    func updateNomValue(action:String, uid:String, completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            if action == AdminAction.finished.id{
                                docRef.updateData(["finished":true])
                                docRef.updateData(["charityDone":false])
                            }else if action == AdminAction.delete.id {
                                docRef.delete()
                            }else{
                                let userStatus = d.get("userApproved") as! Bool
                                if userStatus == true {
                                    docRef.updateData(["startDate":Date().timeIntervalSince1970])
                                    let days = TimeInterval(3.minutes)
                                    let tmpDate:Date = Date().addingTimeInterval(days)
                                    docRef.updateData(["endDate":tmpDate.timeIntervalSince1970])
                                    docRef.updateData(["phase":2])
                                }
                                docRef.updateData(["adminApproved": self.isApproval])
                            }
                        }
                    }
                }
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
    }
    
}



extension AdminNominationsViewController{
    
    func configureProfilePicture(){
        guard self.currentUser != nil else {
            return
        }
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            //let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
//            var imageV : UIImageView
//            imageV  = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 40));
//            imageV.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "profileicon"))
            
            
            
            storageRef.downloadURL(completion: { (url, error) in
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
        let image = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        
        let sortedViews = self.segmentController.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        for (index, view) in sortedViews.enumerated() {
            if index == self.segmentController.selectedSegmentIndex {
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









