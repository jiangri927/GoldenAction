//
//  AwardsViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/10/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import CoreLocation
import Firebase
//import AlgoliaSearch
import DGElasticPullToRefresh
import DGActivityIndicatorView
import DropDown
import FacebookShare
import TwitterKit
import SCLAlertView


class AwardsViewController: UIViewController,UISearchBarDelegate {
    // Bar Button Declartion
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    @IBOutlet weak var checkoutButton: UIBarButtonItem!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
  //  @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    // Header View Variable Declartion
    @IBOutlet weak var headerPicture: UIImageView!
    @IBOutlet weak var awardsTitle: UILabel!
    
    var shareActionDropDown:DropDown!

    var awards = [Nominations]()
    var searchAwards = [Nominations]()
    var currentUser: Person!
    
    
    var currentLocation: Cities!
    var currentCategory: String = "All"
    var testData = [[String : Any]]()
    let titleText = "Golden Action Awards"
    var samples = [0,1,2,3,4,5,6,7,8,9]
    
    let keychain = KeychainWrapper.standard
    var app_color = Colors.app_color.generateColor()
    
    // Table View Variable Declaration
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var locationManage: CLLocationManager?
    
    var isSearching = false
    
    var activityView:DGActivityIndicatorView!
    var filteredTableData = [String]()
    var resultSearchController:UISearchBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapDismiss()
        // Table View Setup
        NotificationCenter.default.addObserver(self, selector: #selector(self.nameOfFunction), name: NSNotification.Name(rawValue: "logoutNotification"), object: nil)
        self.setUpTableView(tableView: self.tableView)
        self.designTableView(tableView: self.tableView)
        self.designButtonAndTitle()
        // Navigation Controller Setup
        self.setUpNav()
        // Search Controller Setup
        self.reloadInputViews()
        self.observeAppUpdate()
        self.loadIndicatorView()
        self.pullElastic()

        self.profileButton.action = #selector(profileSegue(_:))
        self.profileButton.target = self
        
        self.resultSearchController = UISearchBar()
        self.resultSearchController.barTintColor = Colors.black.generateColor()
        let textFieldInsideSearchBar = self.resultSearchController.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = Colors.app_text.generateColor()
        textFieldInsideSearchBar?.backgroundColor = Colors.black.generateColor()
        textFieldInsideSearchBar?.setBottomBorder()
        
        self.resultSearchController.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        self.resultSearchController.delegate = self
        self.resultSearchController.searchBarStyle = UISearchBarStyle.default
        self.resultSearchController.placeholder = "Search Here"
        self.resultSearchController.sizeToFit()
        self.tableView.tableHeaderView = self.resultSearchController
        
        if self.currentUser == nil {
            let loadView = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
            self.loadAwards(region: "", category: self.currentCategory, loadVC: loadView)

        }
    }
    
    func designButtonAndTitle(){
        let imageColor1 = self.gradient(size: self.awardsTitle.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.awardsTitle.textColor = UIColor.init(patternImage: imageColor1!)
        
        let imageColor = self.gradient(size: self.categoryButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.categoryButton.backgroundColor     = UIColor.init(patternImage: imageColor!)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.resultSearchController.delegate = self
        
        self.pullElastic()
        let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
        if self.currentUser == nil {
            self.awards = []
            self.startUserLoadChain(loadView: loadingVC)
            self.categoryButton.layer.masksToBounds = true
            self.categoryButton.layer.cornerRadius = 10.0
            
        } else {
            
            if (self.currentCategory != nil) || (self.currentLocation != nil) {
                self.currentLocation = Authorize.instance.currentNomLocation
                self.currentCategory = Authorize.instance.currentNomCategory
                self.setUpTitleView()
                if self.awards != [] {
                    //self.awards = Authorize.instance.currentNominations
                    self.pullElastic()
                    //self.refresh(refreshControl)
                } else {
                    self.awards = []
                    // self.loadAwards(region: self.currentLocation.clusterNumber, category: self.currentCategory, loadVC: loadingVC)
                    self.loadAwards(region: "", category: self.currentCategory, loadVC: nil)
                }
            } else {
                self.awards = []
                self.startUserLoadChain(loadView: loadingVC)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    @objc func nameOfFunction(notif: NSNotification) {
        self.profileButton.customView?.removeFromSuperview()
        self.profileButton.customView = nil
        self.profileButton.image = UIImage(named: "profileicon")
    }

    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
    }
    
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
            self?.activityView.stopAnimating()
            self?.elasticRefresh(tableView: (self?.tableView)!)
            }, loadingView: loadingView)
        self.tableView.dg_setPullToRefreshFillColor(Colors.black.generateColor())
        self.tableView.dg_setPullToRefreshBackgroundColor(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
    }
    
    func elasticRefresh(tableView: UITableView) {
        let workItem = DispatchWorkItem {
            self.isSearching = false
            //let loadView = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
            if InternetConnection.instance.isInternetAvailable() {
                //Loding awards without login
                //if self.currentUser != nil {
                    //self.loadAwards(region: self.currentLocation.clusterNumber, category: self.currentCategory ?? FilterStrings.all_category.id, loadVC: nil)
                self.loadAwards(region: "", category: self.currentCategory ?? "HEAD", loadVC: nil)

               // } else {
                    //sud
                    //self.createAnonymousUser(loadView: loadView)
                //}
                tableView.dg_stopLoading()
            } else {
                self.goldenAlert(title: "No Internet Connection", message: "Please connect to internet and refresh the page", view: self)
                tableView.dg_stopLoading()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100), execute: workItem)
    }
    // MARK: - Data Loads
    // MARK: - Refresh Method
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.isSearching = false
        let loadView = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
        if InternetConnection.instance.isInternetAvailable() {
            //self.loadCurrentUser()
            if self.currentUser != nil {
                //self.loadAwards(region: self.currentLocation.clusterNumber, category: self.currentCategory ?? FilterStrings.all_category.id, loadVC: nil)
                self.loadAwards(region: "", category: "", loadVC: loadView)

            } else {
                self.loadAwards(region: "", category: "", loadVC: loadView)
                //sud
                //self.createAnonymousUser(loadView: loadView)
            }
            refreshControl.endRefreshing()
        } else {
            self.goldenAlert(title: "No Internet Connection", message: "Please connect to internet and refresh the page", view: self)
            refreshControl.endRefreshing()
        }
        
    }
    
    func startUserLoadChain(loadView: LoadingViewController) {
        self.loadCurrentUser(loadView: loadView) { (currentUser, error) in
            guard error == nil && currentUser != nil else {
                //self.goldenAlert(title: error!, message: "", view: self)
                self.goldenAlert(title: "Error", message: "Current user is already logedout, please login once!", view: self)
                return
            }
            Authorize.instance.currentUser = currentUser!
            self.currentUser = Authorize.instance.currentUser
            self.startNeededChain(loadView: loadView)
            self.configureProfilePicture()
        }
    }

    func startNeededChain(loadView: LoadingViewController) {
        self.loadLastCategory(uid: self.currentUser.uid, completion: { (category) in
            self.currentCategory = category
            Authorize.instance.currentNomCategory = category
            self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
           // self.headerPicture.image = self.generateTitleView(currentCategory: self.currentCategory)
            self.loadLastLocation(uid: self.currentUser.uid, completion: { (city) in
                self.currentLocation = city

              //  self.locationButton.setAttributedTitle(Strings.titleview_location.generateString(text: self.currentLocation.cityState), for: [])
                Authorize.instance.currentNomLocation = city
                self.setUpTitleView()
                //self.loadAwards(region: self.currentLocation.clusterNumber, category: self.currentCategory, loadVC: loadView)
                self.loadAwards(region: "", category: self.currentCategory, loadVC: loadView)

            })
        })
    }
//
//    func startUserLoadChain() {
//        self.loadCurrentUser() { (currentUser, error) in
//            guard error == nil && currentUser != nil else {
//                print("Hey error loading current user")
//                self.createAnonymousUser()
//                return
//            }
//            self.currentUser = currentUser!
//            self.configureProfilePicture()
//            self.startNeededChain()
//            //self.loadPendingNomination()
//            print("User Instantiated")
//        }
//    }
//    func startNeededChain() {
//        let workItem = DispatchWorkItem {
//            self.loadLastLocation(uid: self.currentUser.uid, completion: { (city) in
//                self.currentLocation = city
//
//                self.setUpTitleView()
//                self.loadNominations(region: self.currentLocation.clusterNumber, category: self.currentCategory)
//            })
//        }
//        let firstItem = DispatchWorkItem {
//            self.loadLastCategory(uid: self.currentUser.uid, completion: { (category) in
//                self.currentCategory = category
//                self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
//                // self.categoryIcon.image = self.generateTitleView(currentCategory: self.currentCategory)
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: workItem)
//            })
//
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: firstItem)
//    }
    
    
    
    
    
    
    
    
    // MARK: - Load Current Person
    func loadCurrentUser(loadView: LoadingViewController, completion: @escaping (Person?, String?) -> Void) {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            self.loadPerson(uid: uid, completion: { (person, error) in
                completion(person, error)
            })
            
        } else {
            //sud
            //self.createAnonymousUser(loadView: loadView)
        }
    }
    func loadPerson(uid: String, completion: @escaping (Person?, String?) -> Void) {
        Person.loadCurrentPerson(uid: uid) { (error, current) in
            guard error == nil && current != nil else {
                completion(current, error)
                return
            }
            
            completion(current, error)
        }
    }
    func createAnonymousUser(loadView: LoadingViewController) {
        Authorize.instance.resignAnon(view: self) { (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            Messaging.messaging().subscribe(toTopic: "000")
            self.startUserLoadChain(loadView: loadView)
        }
    }
    func loadLastCategory(uid: String, completion: @escaping (String) -> Void) {
        DBRef.userLastAwardCategory(uid: uid).reference().observe(.value) { (snapshot) in
            let category = snapshot.value as? String ?? FilterStrings.all_category.id
            completion("Categories")
        }
    }
    func loadLastLocation(uid: String, completion: @escaping (Cities) -> Void) {
        DBRef.userLastAwardLocation(uid: uid).reference().observe(.value) { (snapshot) in
            if let city = snapshot.value as? [String : Any] {
                let obj = Cities(userLocDict: city)
                completion(obj)
            } else {
                let obj = Cities(cluster: "000", cityState: FilterStrings.popular_location.id)
                completion(obj)
            }
        }
    }
    func loadAwards(region: String, category: String, loadVC: LoadingViewController?) {
        self.activityView.startAnimating()
        self.awards = []
        if !self.isSearching {
            if region != "000" {
                Nominations.getAllNominations(region: region, awards: true, category: category) { (error, awards) in
                    for nom in awards {
                        if !self.awards.contains(nom) {
                            self.awards.append(nom)
                        }
                    }
                    self.activityView.stopAnimating()

                    self.tableView.reloadData()
                    self.pullElastic()
                }
            } else {
                Nominations.getAllNominations(region: region, awards: true, category: category) { (error, awards) in
                    for nom in awards {
                        if !self.awards.contains(nom) {
                            self.awards.append(nom)
                        }
                    }
                    self.activityView.stopAnimating()
                    self.tableView.reloadData()
                    self.pullElastic()

                }
            }
        }
    }
    // MARK: - Setup Nomination Title View
    func setUpTitleView() {
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryFilterTapped(recognizer:)))
        let locationGesture = UITapGestureRecognizer(target: self, action: #selector(locationFilterTapped(recognizer:)))
        
        //self.awardsTitle.attributedText = Strings.titleview_title.generateString(text: self.titleText)
        self.awardsTitle.text = self.titleText
        
        self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
        
        self.categoryButton.isUserInteractionEnabled = true
        self.categoryButton.addGestureRecognizer(categoryGesture)
       // self.locationButton.isUserInteractionEnabled = true
       // self.locationButton.addGestureRecognizer(locationGesture)
        
        self.categoryButton.layer.masksToBounds = true
        self.categoryButton.layer.cornerRadius = 10.0
       // self.locationButton.layer.masksToBounds = true
       // self.locationButton.layer.cornerRadius = 10.0
       // self.headerPicture.image = self.generateTitleView(currentCategory: self.currentCategory)
    }
    @objc func categoryFilterTapped(recognizer: UITapGestureRecognizer) {
        print("CLICK")
        if recognizer.state == UIGestureRecognizerState.ended {
            print("CLICKED IN")

            self.showCategoryAfterTap(filterType: self.currentCategory)
           /* guard Auth.auth().currentUser != nil else{
                self.goldenAlert(title: "Category Error", message: "Current user is already logedout, please login once!", view: self)
                return
            }
            let categoryPopup = FilterPopup(vc: self, filterType: self.currentCategory, nomination: false, uid: self.currentUser.uid)
            let workItem = DispatchWorkItem {
                self.present(categoryPopup.popup, animated: true, completion: nil)
            }
            categoryPopup.createCategoryPopup()
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(10), execute: workItem) */
        }
    }
    @objc func locationFilterTapped(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.began) || (recognizer.state == UIGestureRecognizerState.ended) {
            guard Auth.auth().currentUser != nil else{
                self.goldenAlert(title: "Location Error", message: "Current user is already logedout, please login once!", view: self)
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: VCID.filter_location.id) as! FilterLocationViewController
            vc.nomination   = false
            vc.awardsVC     = self
            vc.cityState    = self.currentLocation.cityState
            vc.uid          = self.currentUser.uid
            let workItem    = DispatchWorkItem {
                self.present(vc, animated: true, completion: nil)
            }
            self.providesPresentationContextTransitionStyle = true
            self.definesPresentationContext = true
            self.modalPresentationCapturesStatusBarAppearance = false
            vc.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: workItem)
        }
    }
    
    // MARK: - Navigation Controller Setup
    func setUpNav() {
        // Navigation Bar Color
        self.setBarTint()
        self.setBarButtonTint()
        self.checkoutButton.action = #selector(checkoutSegue(_:))
        self.checkoutButton.target = self
        //self.profileButton.action = #selector(profileSegue(_:))
        //self.profileButton.target = self
        self.notificationButton.action = #selector(notificationSegue(_:))
        self.notificationButton.target = self
    }
    
    @objc func profileSegue(_ sender: UIBarButtonItem) {
        guard Auth.auth().currentUser != nil else {
            //self.checkVerification(currentUser: self.currentUser, message: "You must have an account to viw your profile.", workitem: backWorkItem)
            let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
             let navVC = UINavigationController(rootViewController: welcomeVC)
             navVC.setNavigationBarHidden(true, animated: false)
             self.present(navVC, animated: true, completion: nil)
            return
        }
        
        guard self.currentUser != nil else{
            let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
            let navVC = UINavigationController(rootViewController: welcomeVC)
            navVC.setNavigationBarHidden(true, animated: false)
            self.present(navVC, animated: true, completion: nil)
            return
        }
        
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.awards_profile.id, sender: self)
        } else {
            let backWorkItem = DispatchWorkItem {
                print("Profile WorkItem")
            }
            let workItem = DispatchWorkItem {
               // self.checkVerification(currentUser: self.currentUser, message: "You must have an account to viw your profile.", workitem: backWorkItem)
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                 let navVC = UINavigationController(rootViewController: welcomeVC)
                 navVC.setNavigationBarHidden(true, animated: false)
                 self.present(navVC, animated: true, completion: nil)
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    @objc func notificationSegue(_ sender: UIBarButtonItem) {
        guard self.currentUser != nil else {
            self.goldenAlert(title: "Notification Error", message: "Current user is already logedout, please login once!", view: self)
            return
        }
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.awards_notif.id, sender: self)
        } else {
            let backWorkItem = DispatchWorkItem {
                print("Notifications WorkItem")
            }
            
            let workItem = DispatchWorkItem {
               // self.checkVerification(currentUser: self.currentUser, message: "You must have an account to view notifications", workitem: backWorkItem)
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        
    }
    @objc func checkoutSegue(_ sender: UIBarButtonItem) {
        guard self.currentUser != nil else {
            self.goldenAlert(title: "Checkout Error", message: "Current user is already logedout, please login once!", view: self)
            return
        }
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.awards_cart.id, sender: self)
        } else {
            let backWorkItem = DispatchWorkItem {
                print("Cart WorkItem")
            }
            
            let workItem = DispatchWorkItem {
                //self.checkVerification(currentUser: self.currentUser, message: "You must have an account to view purchase nominations or votes", workitem: backWorkItem)
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.awards_profile.id {
            let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController

            self.loadCurrentUser(loadView: loadingVC) { (currentUser, error) in
                guard error == nil && currentUser != nil else {
                    print("Hey error loading current user")
                    //sud
                    //self.createAnonymousUser()
                    return
                }
                self.currentUser = currentUser!
                let destinationVC = segue.destination as! ProfileTableViewController
                destinationVC.currentUser = self.currentUser
            }
        } else if segue.identifier == SegueId.awards_search.id {
            let destinationVC = segue.destination as! SearchResultsTableViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.awards_cart.id {
            let destinationVC = segue.destination as! CartViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.awards_notif.id {
            let destinationVC = segue.destination as! NotificationViewController
            destinationVC.currentUser = self.currentUser
        }
    }
    // MARK: - Search Bar Controller
    // Setup
    /*func setUpSearchBar() {
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.barTintColor = Colors.app_tableview_background.generateColor()
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.placeholder = "Search awards in your area!"
        self.searchController.searchBar.barTintColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.50)
        self.searchController.searchBar.tintColor = Colors.app_text.generateColor()
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
    }
    // Implenting
    func updateSearchResults(for searchController: UISearchController) {
        self.isSearching = true
        self.searchNominations(txt: searchController.searchBar.text!)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != nil && searchBar.text != "" else {
            return
        }
        self.searchNominations(txt: searchBar.text!)
    }
    func searchNominations(txt: String) {
        guard txt != "" else {
            return
        }
        let ref = AlgoliaRef.awards.reference()
        Nominations.searchNominationsAwards(query: txt, ref: ref) { (awardsList) in
            self.searchAwards = awardsList
        }
        
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard is hidden")
        self.searchController.searchBar.setShowsCancelButton(false, animated: true)
    }*/
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
    // MARK: - Segue to Detail Gesture Recognizer
    @objc func toDetail(recognizer: UITapGestureRecognizer) {
//        if recognizer.state == UIGestureRecognizerState.ended {
//            let tapCell = recognizer.location(in: self.tableView)
//            if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
//                if let tapCell = self.tableView.cellForRow(at: indexPath) as? AwardsTableViewCell {
//                    // MARK: - Pass data from this cell to nom detail controller
//                    let nomDetailVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.awards_detail.id) as! AwardDetailTableViewController
//                    nomDetailVC.award = tapCell.award
//                    self.navigationController?.pushViewController(nomDetailVC, animated: true)
//                }
//            }
//        }
        
        
        
        if recognizer.state == UIGestureRecognizerState.ended {
            print("Sup Recognized")
            print("------------->")
            let tapCell = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                if let tapCell = self.tableView.cellForRow(at: indexPath) as? AwardsTableViewCell {
                    // MARK: - Pass data from this cell to nom detail controller
                    print("Tap Recognized")
                    print("------------->self")
                    let nomDetailVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.nominee_detail.id) as! NomDetailTableViewController
                    nomDetailVC.nomination = tapCell.award
                    nomDetailVC.currentUser = tapCell.award.nominee

                    //nomDetailVC.award = tapCell.award

                    let navVC = UINavigationController(rootViewController: nomDetailVC)
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        }
        
        
    }

}

extension AwardsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setUpTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numSections = 1
       /* if self.isSearching {
            if self.searchAwards != [] {
                tableView.separatorStyle = .singleLine
                numSections = 1
                tableView.backgroundView = nil
                self.tableView.backgroundView = nil
            } else {
                
                self.tableView.separatorStyle = .none
            }
        } else {
            if self.awards != [] {
                tableView.separatorStyle = .singleLine
                numSections = 1
                tableView.backgroundView = nil
                self.tableView.backgroundView = nil
            } else {
                self.tableView.separatorStyle = .none
            }
        }*/
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isSearching {
            return self.searchAwards.count > 0 ? self.searchAwards.count : 1
        }else{
            return self.awards.count > 0 ? self.awards.count : 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var award: Nominations!
        
        if self.isSearching{
            if self.searchAwards.count > 0{
                award = self.searchAwards[indexPath.row]
            }else{
                let recordNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "AwardsNotFound")
                return recordNotFoundCell!
            }
        }else{
            if self.awards.count > 0{
                if indexPath.row < self.awards.count {
                    award = self.awards[indexPath.row]
                }
            }else{
                let recordNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "AwardsNotFound")
                return recordNotFoundCell!
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.award_cell.id, for: indexPath) as! AwardsTableViewCell
        cell.selectionStyle = .none
        cell.configureAward(awardee: award)
        cell.award = award
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
        cell.addGestureRecognizer(gesture)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
        if self.isSearching {
            if indexPath.row < self.searchAwards.count {
                return 100.0
            } else {
                return 100.0
            }
        } else {
            if indexPath.row < self.awards.count {
                return 100.0
            } else {
                return 100.0
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
        if self.isSearching {
            if indexPath.row < self.searchAwards.count {
                return 100.0
            } else {
                return 100.0
            }
        } else {
            if indexPath.row < self.awards.count {
                return 100.0
            } else {
                return 100.0
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
}




/*extension AwardsViewController{
    func shareFromFacebook(){
        // let twiteText = "\(self.nomineeName.text ?? "")\n\(self.location.text ?? "")\n\(self.pendingAward.text ?? "")\n\(self.nominatedBy.text ?? "")\n "
        let twitText = "I nominated \(self.nomineeName.text ?? "") for a Golden Action Award for \(self.pendingAward.text ?? ""). Click here to support them!"
        
        var content:LinkShareContent = LinkShareContent.init(url: URL.init(string: "https://firebasestorage.googleapis.com/v0/b/golden-test-app.appspot.com/o/nominationPics%2F05F73153-CA12-4AB4-84A5-22945DF7B8DD?alt=media&token=488761c7-1ffc-4e38-bbcd-cdd95f76c288") ?? URL.init(fileURLWithPath: "https://itunes.apple.com/us/app/golden-action-awards/id1387621029?ls=1&mt=8"), quote: twitText)
        content.url = URL.init(string: "https://itunes.apple.com/us/app/golden-action-awards/id1387621029?ls=1&mt=8") ?? URL.init(fileURLWithPath: "https://itunes.apple.com/us/app/golden-action-awards/id1387621029?ls=1&mt=8")
        
        let shareDialog = ShareDialog(content: content)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in
            // Handle share results
        }
        do
        {
            try shareDialog.show()
        }
        catch
        {
            print("Exception")
            
        }
        
    }
    
    
    func shareFromTwitter(){
        // let twiteText = "\(self.nomineeName.text ?? "")\n\(self.location.text ?? "")\n\(self.pendingAward.text ?? "")\n\(self.nominatedBy.text ?? "")\n "
        let twitText = "I nominated \(self.awardsTitle.text ?? "") for a Golden Action Award for \(self.pendingAward.text ?? ""). Click here to support them!"
        
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if (session != nil) {
                let client = TWTRAPIClient(userID: session?.userID)
                
                client.requestEmail { email, error in
                    if (email != nil) {
                        let composer = TWTRComposer()
                        
                        composer.setText(twitText)
                        composer.setURL(URL(string:"https://www.goldenaction.com"))
                        composer.setImage(self.headerPicture.image)
                        
                        // Called from a UIViewController
                        composer.show(from: self.navigationController!) { (result) in
                            if (result == .done) {
                                print("Successfully composed Tweet")
                                
                            } else {
                                print("Cancelled composing")
                            }
                        }
                    }else {
                        print("error: \(String(describing: error?.localizedDescription))");
                    }
                }
            }else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        }
        
        
    }
    
    @objc func actionDidTap(_ sender: UIBarButtonItem) {
        guard Auth.auth().currentUser != nil else {
            self.goldenAlert(title: "Vote Error!", message: "Sorry! You are not able to vote! Please login first.", view: self)
            return
        }
        self.shareActionDropDown.show()
    }

}

*/

extension AwardsViewController{
    
    func showCategoryAfterTap(filterType:String){
        print(filterType)
        let heart = FilterStrings.heart.id
        let hand = FilterStrings.hand.id
        let head = FilterStrings.head.id
        let health = FilterStrings.health.id
        let all = FilterStrings.all.id
        var buttonTitleArray = [String]()
        
        switch filterType {
        case "Categories","All" :
            buttonTitleArray = [heart,hand,head,health]
        case heart:
            buttonTitleArray = [hand,head,health,all]
        case hand:
            buttonTitleArray = [heart,head,health,all]
        case head:
            buttonTitleArray = [heart,hand,health,all]
        case health:
            buttonTitleArray = [heart,hand,head,all]
        default:
            print("")
        }
        
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false,
            hideWhenBackgroundViewIsTapped: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        for btn in buttonTitleArray{
            alertView.addButton(btn, backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil){
                print(btn)
                self.currentCategory = btn
                if self.currentCategory == "All"{
                    self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: "Categories"), for: [])
                }else{
                    self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
                }
                self.loadAwards(region: "", category: self.currentCategory, loadVC: nil)
            }
        }
        alertView.showInfo("Choose category", subTitle: "")
    }
}



extension AwardsViewController{
    
    func configureProfilePicture(){
        guard self.currentUser != nil else {
            return
        }
        // self.activityView.startAnimating()
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
//            let storageRef = Storage.storage().reference(forURL: completeUrl)
//            
//            var imageV : UIImageView
//            imageV  = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 40));
//            imageV.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "profileicon"))
//            
//            let button = UIButton(type: .custom)
//            button.setImage(imageV.image, for: .normal)
//            button.isUserInteractionEnabled = true
//            //button.contentMode = UIViewContentMode.scaleAspectFill
//            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
//            button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
//            button.layer.masksToBounds = true
//            button.layer.cornerRadius = button.frame.height / 2
//            button.addTarget(self, action: #selector(self.profileSegue(_:)), for: .touchUpInside)
//            self.profileButton.customView = button
            
            
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


extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

extension AwardsViewController{
    
    func updateSearchResults(for searchController: UISearchController) {
        var tmpSearchNom = [Nominations]()
        
        filteredTableData.removeAll(keepingCapacity: false)
        
        var searchTxt = searchController.searchBar.text
        
        if (searchTxt?.count)! > 0 {
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        
        let searchPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchController.searchBar.text!)
        self.awards.forEach({
            if $0.nominee.fullName.contains(find: searchTxt!){
                print("exist")
                if !tmpSearchNom.contains($0) {
                    tmpSearchNom.append($0)
                }
            }
        })
        
        self.searchAwards.removeAll()
        self.searchAwards = tmpSearchNom
        
        self.tableView.reloadData()
    }
    
}


/// Search delegate
extension AwardsViewController{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
     return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isSearching = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var tmpSearchNom = [Nominations]()
        
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchTxt = searchText
        
        if (searchTxt.count) > 0 {
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        
        //let searchPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchController.searchBar.text!)
        self.awards.forEach({
            if $0.nominee.fullName.contains(find: searchTxt){
                print("exist")
                if !tmpSearchNom.contains($0) {
                    tmpSearchNom.append($0)
                }
            }
        })
        
        self.searchAwards.removeAll()
        self.searchAwards = tmpSearchNom
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        var tmpSearchNom = [Nominations]()
        
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchTxt = text
        
        if (searchTxt.count) > 0 {
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        
        //let searchPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchController.searchBar.text!)
        self.awards.forEach({
            if $0.nominee.fullName.contains(find: searchTxt){
                print("exist")
                if !tmpSearchNom.contains($0) {
                    tmpSearchNom.append($0)
                }
            }
        })
        
        self.searchAwards.removeAll()
        self.searchAwards = tmpSearchNom
        
        self.tableView.reloadData()
        return true
    }

    
}
























