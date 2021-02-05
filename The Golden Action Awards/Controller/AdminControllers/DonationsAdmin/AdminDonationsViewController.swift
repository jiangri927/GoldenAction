//
//  AdminDonationsViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 5/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
//import AlgoliaSearch
import Firebase
import AFDateHelper
import Bond
import SideMenu
import DGActivityIndicatorView

class AdminDonationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var checkNomationType : String?
    
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var finished: UIButton!
    @IBOutlet weak var donationPending: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    var currentUser: Person!
    var awards = [Nominations]()
    var activityView:DGActivityIndicatorView!
    
    
    let unselectedColor = UIColor.clear
    let selectedColor = Colors.app_text.generateColor()
    
    var isPending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.register(UINib(nibName: "PendingDonationTableViewCell", bundle: nil), forCellReuseIdentifier: "PendingDonationTableViewCell")
        
        self.loadIndicatorView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.designTableView(tableView: self.tableView)
        self.tapDismiss()
        self.loadPerson()
        self.setUpNav()
        
        //        self.setupButtons(isPending: self.isPending, firstLoad: true)
        //        self.donationPending.addTarget(self, action: #selector(donationPendingTapped(_:)), for: .touchUpInside)
        //        self.finished.addTarget(self, action: #selector(finishedAwardsTapped(_:)), for: .touchUpInside)
        
        
        setupSegmentedControl()
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .selected)
        self.updateGradientBackground()
        self.loadAllFinishedNomination()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.loadAllFinishedNomination()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let image2 = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.segmentController.layer.borderColor = UIColor.init(patternImage: image2).cgColor
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        self.updateGradientBackground()
        if sender.selectedSegmentIndex == 0 {
            print("pendingDidTap")
            self.loadAllFinishedNomination()
        }else{
            print("finishedDidTap")
            self.loadAllCharityFinishedNomination()
        }
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        self.segmentController.removeAllSegments()
        self.segmentController.insertSegment(withTitle: "Donation Pending", at: 0, animated: false)
        self.segmentController.insertSegment(withTitle: "Finished", at: 1, animated: false)
        self.segmentController.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        self.segmentController.layer.borderWidth = 2
        self.segmentController.layer.masksToBounds = true
        self.segmentController.layer.cornerRadius = 8
        self.segmentController.selectedSegmentIndex = 0
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
    }
    
    func loadPerson() {
        let uid = Auth.auth().currentUser!.uid
        Person.loadCurrentPerson(uid: uid) { (error, current) in
            guard error == nil && current != nil else {
                self.goldenAlert(title: "Error", message: "Error loading person please check your internet connection and try again", view: self)
                return
            }
            self.currentUser = current!
            self.loadAllFinishedNomination()
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
    
    @objc func profileTapped(_ sender: Any)
    {
        let workItem = DispatchWorkItem
        {
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
    
    //    @objc func donationPendingTapped(_ sender: UIButton) {
    //        if !(self.donationPending.backgroundColor == self.selectedColor) {
    //            self.isPending = true
    //            self.setupButtons(isPending: self.isPending, firstLoad: false)
    //        }
    //    }
    //    @objc func finishedAwardsTapped(_ sender: UIButton) {
    //        if !(self.finished.backgroundColor == self.selectedColor) {
    //            self.isPending = false
    //            self.setupButtons(isPending: self.isPending, firstLoad: false)
    //        }
    //    }
    //    func setupButtons(isPending: Bool, firstLoad: Bool) {
    //        if firstLoad {
    //            self.designButton(button: self.donationPending)
    //            self.designButton(button: self.finished)
    //        }
    //        if isPending {
    //            self.designSelectedButton(button: self.donationPending)
    //            self.designUnselectedButton(button: self.finished)
    //        } else {
    //            self.designSelectedButton(button: self.finished)
    //            self.designUnselectedButton(button: self.donationPending)
    //        }
    //    }
    //    func designSelectedButton(button: UIButton!) {
    //        button.setTitleColor(UIColor.black, for: [])
    //        button.backgroundColor = self.selectedColor
    //    }
    //    func designUnselectedButton(button: UIButton!) {
    //        button.setTitleColor(self.selectedColor, for: [])
    //        button.backgroundColor = self.unselectedColor
    //    }
    //    func designButton(button: UIButton!) {
    //        button.layer.cornerRadius = 10.0
    //        button.layer.masksToBounds = false
    //        button.layer.borderWidth = 1.0
    //        button.layer.borderColor = self.selectedColor.cgColor
    //
    //    }
    // MARK: - Gesture Recognizer Delegate
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.awards.count)
        return self.awards.count
     //   return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func toDetail(recognizer: UITapGestureRecognizer) {
        print("working")
        
        if(checkNomationType == "finished")
        {
            if recognizer.state == UIGestureRecognizerState.ended {
                let tapCell = recognizer.location(in: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                    if let tapCell = self.tableView.cellForRow(at: indexPath) as? AdminDonationsTableViewCell {
                        let nomDetailVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.awards_detail.id) as! AwardDetailTableViewController
                        nomDetailVC.award = tapCell.nominations
                        self.navigationController?.pushViewController(nomDetailVC, animated: true)
                    }
                }
            }
        }
        else
        {
            if recognizer.state == UIGestureRecognizerState.ended {
                let tapCell = recognizer.location(in: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                    if let tapCell = self.tableView.cellForRow(at: indexPath) as? PendingDonationTableViewCell {
                        let nomDetailVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.awards_detail.id) as! AwardDetailTableViewController
                        nomDetailVC.award = tapCell.nominations
                        self.navigationController?.pushViewController(nomDetailVC, animated: true)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(checkNomationType == "finished")
        {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellId.admin_donations.id, for: indexPath) as! AdminDonationsTableViewCell
            let awards = self.awards[indexPath.row]
            cell.viewController = self
            cell.nominations = awards
            cell.nomineeName.text = awards.nominee.fullName
            cell.charityName.text = awards.charity?.charityName ?? ""
            cell.category.text = awards.category
            cell.loadNomineeImage()
            cell.amountDonated.text = "$\(cell.totalCalculatedAmount()).00"
            let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
            cell.addGestureRecognizer(gesture)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingDonationTableViewCell", for: indexPath) as! PendingDonationTableViewCell
            
            let awards = self.awards[indexPath.row]
            cell.viewController = self
            cell.nominations = awards
            cell.lblUserName.text = awards.nominee.fullName
            cell.lblCharity.text = awards.charity?.charityName 
            cell.lblAmount.text = "$\(cell.totalCalculatedAmount()).00"
            cell.loadNomineeImage()
            cell.lblVoteCount.text = "\(awards.numberOfVotes) Votes"
            
            cell.btnAward.tag = indexPath.row
            cell.btnDonation.tag = indexPath.row
            cell.btnAward.addTarget(self, action: #selector(btnActionOnAward(_:)), for: .touchUpInside)
            cell.btnDonation.addTarget(self, action: #selector(btnActionOnDonation(_:)), for: .touchUpInside)
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
            cell.viewBg.addGestureRecognizer(gesture)
            
            if(awards.finished == true){
                cell.imgCheckAward.image = UIImage(named: "checkBox")
            }else{
                cell.imgCheckAward.image = UIImage(named: "uncheckBox")
            }
            
            
            print("**** \(String(describing: awards.charityDone)) *****")
            
            if(awards.charityDone == false){
                cell.imgCheckDonation.image = UIImage(named: "uncheckBox")
            }else{
                cell.imgCheckDonation.image = UIImage(named: "checkBox")
                
            }
            
            return cell
        }
    }
    
    
    @objc func btnActionOnAward(_ sender: UIButton) {
        print(sender.tag)
        
        var selectedNomineeId:String!
        
        let tmpNom = self.awards[sender.tag]
        selectedNomineeId = tmpNom.uid
        
        self.activityView.startAnimating()
        if(tmpNom.finished == true){
            self.updateNomineeAdminAward(action: AdminAction.finished.id, uid: selectedNomineeId, sender:sender.tag, staus:false)
        }else{
            self.updateNomineeAdminAward(action: AdminAction.finished.id, uid: selectedNomineeId, sender:sender.tag,staus:true)
        }
        
        
    }
    
    @objc func btnActionOnDonation(_ sender: UIButton) {
        print(sender.tag)
        
        var selectedNomineeId:String!
       // var tmpNom:Nominations!
        
        let tmpNom = self.awards[sender.tag]
        selectedNomineeId = tmpNom.uid

        self.activityView.startAnimating()
        if(tmpNom.charityDone == true){
            self.updateNomineeAdminCharity(action: AdminAction.charityDone.id, uid: selectedNomineeId, sender:sender.tag, staus:false)
        }else{
            self.updateNomineeAdminCharity(action: AdminAction.charityDone.id, uid: selectedNomineeId, sender:sender.tag,staus:true)
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.awards.count {
            if(checkNomationType == "finished"){
                return 75
            }
            return 203
        } else {
            if(checkNomationType == "finished"){
                return 75
            }
            return 203
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.awards.count {
            if(checkNomationType == "finished"){
                return 75
            }
            return 203
        } else {
            if(checkNomationType == "finished"){
                return 75
            }
            return 203
        }
    }
    
    
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        var selectedNomineeId:String!
//        var tmpNom:Nominations!
//
//        let delete = UITableViewRowAction(style: .destructive, title: "Donate") { (action, indexPath) in
//
//            let tmpNom = self.awards[indexPath.row]
//            selectedNomineeId = tmpNom.uid
//            self.updateCharityStatus(status:true, uid: selectedNomineeId)
//            self.awards.remove(at: indexPath.row)
//        }
//
//        delete.backgroundColor = UIColor.green
//
//        if self.isPending {
//            return [delete]
//        }
//        return []
//    }
    
    
    //    @IBAction func pendingDidTap(_ sender: Any) {
    //        print("pendingDidTap")
    //        self.loadAllFinishedNomination()
    //    }
    //
    //    @IBAction func finishedDidTap(_ sender: Any) {
    //        print("finishedDidTap")
    //        self.loadAllCharityFinishedNomination()
    //    }
    
    
    
}

extension AdminDonationsViewController{
    
//    func loadAllFinishedNomination()
//    {
//        checkNomationType = "pending"
//        self.activityView.startAnimating()
//        //self.awards = []
//
//        guard self.currentUser != nil else {
//            return
//        }
//        Nominations.getAllCharityNominationWithCharityDoneTrue(status: false){(error, noms) in
//            self.activityView.stopAnimating()
//            guard error == nil else{
//                print(error!.localizedDescription)
//                return
//            }
//            for nom in noms {
//                if !self.awards.contains(nom) {
//                    self.awards.append(nom)
//
//                }
//            }
//            print("*****\(noms.count)*****")
//            print(self.awards.count)
//            print("pending nomination for me")
//            self.awards.sort()
//            self.tableView.reloadData()
//        }
//    }
    
    
    func loadAllFinishedNomination()
    {
        checkNomationType = "pending"
        self.activityView.startAnimating()
        self.awards = []
        
        guard self.currentUser != nil else {
            return
        }
        Nominations.getAllCharityNominationWithCharityDoneTrue(status: true){(error, noms) in
            self.activityView.stopAnimating()
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            for nom in noms {
                if !self.awards.contains(nom) {
                    
                    if(nom.finished != true){
                        self.awards.append(nom)
                    }
                }
            }
            print("*****\(noms.count)*****")
            print(self.awards.count)
            print("pending nomination for me")
            self.awards.sort()
            
            self.loadAllFinishedNominationFalse()
        }
    }
    
    func loadAllFinishedNominationFalse()
    {
        checkNomationType = "pending"
        self.activityView.startAnimating()
        //self.awards = []
        
        guard self.currentUser != nil else {
            return
        }
        Nominations.getAllCharityNominationWithCharityDoneFalse(status: false){(error, noms) in
            self.activityView.stopAnimating()
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            for nom in noms {
                if !self.awards.contains(nom) {
                    nom.finished = false
                    
                    self.awards.append(nom)
                }
            }
            print("*****\(noms.count)*****")
            print(self.awards.count)
            print("pending nomination for me")
            self.awards.sort()
            self.tableView.reloadData()
            
           
        }
    }
    
    func loadAllCharityFinishedNomination()
    {
        self.activityView.startAnimating()

        checkNomationType = "finished"
        
        self.awards = []
        
        guard self.currentUser != nil else {
            return
        }
        Nominations.getAllCharityNomination(status: true){(error, noms) in
            self.activityView.stopAnimating()
            
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            for nom in noms {
                if !self.awards.contains(nom) {
                    self.awards.append(nom)
                }
            }
            print(noms.count)
            print("pending nomination for me")
            self.awards.sort()
            self.tableView.reloadData()
        }
    }
    
    
    func updateNomineeAdminAward(action:String, uid:String, sender:Int,staus:Bool) {
        
        self.updateNomAdminValue(action:action, uid: uid, staus:staus, completion: { status in
            self.activityView.stopAnimating()
            if status == true{
                
                self.awards[sender].finished = staus
                
                if(self.awards[sender].charityDone == true && self.awards[sender].finished == true){
                    self.awards.remove(at: sender)
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    func updateNomAdminValue(action:String, uid:String, staus:Bool ,completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            if action == AdminAction.finished.id{
                                docRef.updateData(["finished":staus])
                            }
                        }
                    }
                }
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
    }
    
    
    func updateNomineeAdminCharity(action:String, uid:String, sender:Int,staus:Bool) {
        
        self.updateNomAdminValueCharityDone(action:action, uid: uid, staus:staus, completion: { status in
            self.activityView.stopAnimating()
            if status == true{
                
                self.awards[sender].charityDone = staus
                
                if(self.awards[sender].charityDone == true && self.awards[sender].finished == true){
                    self.awards.remove(at: sender)
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    
    func updateNomAdminValueCharityDone(action:String, uid:String, staus:Bool ,completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            if action == AdminAction.charityDone.id{
                                docRef.updateData(["charityDone":staus])
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


extension AdminDonationsViewController {
    
    func updateCharityStatus(status:Bool, uid:String) {
        self.activityView.startAnimating()
        self.updateNomValue(action: status, uid: uid, completion: { status in
            self.activityView.stopAnimating()
            if status == true{
                // self.setupButtons(isPending: false, firstLoad: true)
                self.loadAllFinishedNomination()
            }
        })
    }
    
    func updateNomValue(action:Bool, uid:String, completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            docRef.updateData(["charityDone":true])
                        }
                    }
                }
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: valueWorkItem)
    }
    
}


extension AdminDonationsViewController{
    
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

