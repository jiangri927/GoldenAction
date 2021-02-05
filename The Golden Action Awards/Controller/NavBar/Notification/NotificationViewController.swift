//
//  NotificationViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import DGElasticPullToRefresh
import DGActivityIndicatorView

class NotificationViewController: UIViewController {
    // MARK: - Bar Button Declaration
    
    
    @IBOutlet var lblTitle: UILabel!
    
    
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var activityView:DGActivityIndicatorView!
    
    var notifications = [GoldenNotifications]()
    var showNotification = [Dictionary<String,String>]()
    var currentUser: Person!
    var admin: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTitleLbl()
        self.loadIndicatorView()
        // Table View Setup
       // self.setUpTableView(tableView: self.tableView)
        self.designTableView(tableView: self.tableView)
        // Navigation Controller Setup
        self.setUpNav()
        self.pullElastic()
        let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
        self.linkingFunction(loadView: loadingVC)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        getUserNotification()
    }
    
    func configureTitleLbl(){
        let imageColor = self.gradient(size: self.lblTitle.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.lblTitle.textColor = UIColor.init(patternImage: imageColor!)
        
    }
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //
    //        let image2 = self.gradient(size: self.lblTitle.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
    //        self.lblTitle.layer.borderColor = UIColor.init(patternImage: image2).cgColor
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pullElastic() {
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = Colors.app_color.generateColor()
        loadingView.setPullProgress(100)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.elasticRefresh(tableView: (self?.tableView)!)
            }, loadingView: loadingView)
        self.tableView.dg_setPullToRefreshFillColor(Colors.black.generateColor())
        self.tableView.dg_setPullToRefreshBackgroundColor(Colors.app_text.generateColor())
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        activityView.startAnimating()
    }
    
    func elasticRefresh(tableView: UITableView) {
        let workItem = DispatchWorkItem {
            if InternetConnection.instance.isInternetAvailable() {
                //self.loadCurrentUser()
                let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
                self.linkingFunction(loadView: loadingVC)
                tableView.dg_stopLoading()
            } else {
                self.goldenAlert(title: "No Internet Connection", message: "Please connect to internet and refresh the page", view: self)
                tableView.dg_stopLoading()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100), execute: workItem)
    }
    // MARK: - Navigation Controller Setup
    func setUpNav() {
        // Navigation Bar Color
        self.navigationController?.isNavigationBarHidden = false
        self.setBarTint()
        self.setBarButtonTint()
        self.view.backgroundColor = Colors.app_tableview_background.generateColor()
        
    }
    func linkingFunction(loadView: LoadingViewController) {
        if (self.currentUser == nil) {
            self.notifications = []
            self.loadUser {
                self.loadNotifications(loadView: loadView)
            }
        } else {
            self.notifications = []
            self.loadNotifications(loadView: loadView)
        }
    }
    func loadUser(completion: @escaping () -> Void) {
        let uid = Auth.auth().currentUser!.uid
        Person.loadCurrentPerson(uid: uid) { (error, person) in
            guard error == nil else {
                self.goldenAlert(title: error!, message: "Please check you internet and try refreshing", view: self)
                return
            }
            self.currentUser = person!
            completion()
        }
    }
    func loadNotifications(loadView: LoadingViewController) {
        self.activityView.startAnimating()
        if self.admin != nil {
            self.currentUser.observeAdminNotifications { (notifications) in
                self.notifications = notifications
                self.activityView.stopAnimating()
                self.tableView.reloadData()
            }
        } else {
            self.currentUser.observeNotificatons { (notifications) in
                self.notifications = notifications
                self.activityView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    @objc func backSegue(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func backDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    func getUserNotification()
    {
        var ref1: Database
        ref1 = Database.database(url: "https://golden-test-app-646fe.firebaseio.com/")
        var ref = ref1.reference(withPath: "notification_saved").child("user_msg").child("\(self.currentUser.uid)")
        
        
        if(admin == true)
        {
            ref = ref1.reference(withPath: "notification_saved").child("admin_msg").child("\(self.currentUser.uid)")
        }
        
       
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                   // var users = [Person]()
                    for snap in snapshot {
                        if let dict = snap.value as? [String : Any] {
                            //let nomination = Person(dict: dict)
//                            if !users.contains(nomination) {
//                                users.append(nomination)
//                            }
                            
                            //print(dict)
                            let timestamp = dict["timestamp"] as? NSString ?? ""
                            
                            print(timestamp)
                            
                            self.showNotification.append(dict as! [String : String])
                        }
                        self.showNotification = self.showNotification.reversed()
                        self.tableView.reloadData()
                    }
                    
                   // print(users)
                }
            }
        }
    }
    
    
    
    
    
    
}









extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func setUpTableView(tableView: UITableView) {
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // return self.notifications.count
        return self.showNotification.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.notification_cell.id, for: indexPath) as! NotificationTableViewCell
        
        let notiData = self.showNotification[indexPath.row]
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapCell(recognizer:)))
        cell.contentView.addGestureRecognizer(gesture)
        cell.addGestureRecognizer(gesture)
        
        
        cell.notifDescription.text = notiData["notificationmsg"]
        cell.lblTitle.text = notiData["title"]
        
        return cell
    }
    
    @objc func tapCell(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            print("CLICK")
            let tappedCell = recognizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: tappedCell)
            _ = indexPath!.row
            
            if self.showNotification[indexPath!.row]["notificationmsg"]!.contains("checkout") {
            
                let alertController = UIAlertController(title: "Mailing Address", message: "Please input the mailing address so we can send you your award. Thanks so much for being a part of Golden Action Awards.", preferredStyle: UIAlertControllerStyle.alert)
                
                let saveAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { alert -> Void in
                    let firstTextField = alertController.textFields![0] as UITextField
                    //save to nomination data to display for admin
                    let address = firstTextField.text
                    self.currentUser.address = address ?? ""
                    print(address ?? "")
                    Person.saveCurrentPerson(uid: self.currentUser.uid, person: self.currentUser) { (flag, error, person) in
                        if !flag! {
                            self.goldenAlert(title: "Error", message: error!, view: self)
                            return
                        }
                        self.goldenAlert(title: "Success", message: error!, view: self)
                        self.currentUser = person
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
                    (action : UIAlertAction!) -> Void in })
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "123 Abc St..."
                }
                
                alertController.addAction(saveAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
          
        
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("CLICK")
        let notif = self.notifications[indexPath.row]
        let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
        self.present(loadingVC, animated: false, completion: nil)
        self.loadNomAndSegue(notif: notif, loadView: loadingVC)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.notifications.count {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.notifications.count {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    
    //    @objc func nominationDidTap(_ sender: UIButton) {
    //        let notif = self.notifications[sender.tag]
    //        let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
    //        self.present(loadingVC, animated: false, completion: nil)
    //        self.loadNomAndSegue(notif: notif, loadView: loadingVC)
    //    }
    
    
    func loadNomAndSegue(notif: GoldenNotifications, loadView: LoadingViewController) {
        if self.admin != nil
        {
        }
        else
        {
            if notif.notificationType == NotificationType.phase_two.typ
            {
            }
        }
        
        Nominations.loadSpecNom(uid: notif.nominationUID) { (nomin, error) in
            guard error == nil && nomin != nil else {
                self.goldenAlert(title: "Error loading nomination", message: "Please check you internet connection and refresh, if this does not work try accessing the nomination through your profile", view: self)
                return
            }
            
            if nomin!.finished
            {
                let nomVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.nominee_detail.id) as! NomDetailTableViewController
                nomVC.nomination = nomin!
                nomVC.currentUser = self.currentUser
                nomVC.notificationType = notif.notificationType
                loadView.dismiss(animated: false, completion: {
                    self.navigationController?.pushViewController(nomVC, animated: true)
                })
            }
            else
            {
                let awardVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.awards_detail.id) as! AwardDetailTableViewController
                awardVC.award = nomin!
                awardVC.notificationType = notif.notificationType
                awardVC.currentUser = self.currentUser
                loadView.dismiss(animated: false, completion: {
                    self.navigationController?.pushViewController(awardVC, animated: true)
                })
            }
        }
    }
    
    
    
    
}










