//
//  NomineesViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import CoreLocation
import Firebase
//import AlgoliaSearch
import BWWalkthrough
import SAConfettiView
import SwiftyStoreKit
import StoreKit
import DGElasticPullToRefresh
import Spruce
import EZSwipeController
import Bond
import MaterialComponents
import SCLAlertView
import DGActivityIndicatorView
import SDWebImage
import FirebaseUI
import Stripe


class NomineesViewController: UIViewController,UISearchBarDelegate {
    // MARK: - Bar Button Declaration
    
    
    var alertView = SCLAlertView()
    
    @IBOutlet var lblTotalDonation: UILabel!
    
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var checkoutButton: UIBarButtonItem!
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    var activityView:DGActivityIndicatorView!
    
    // MARK: - In title view
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var categoryButton: MDCRaisedButton!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var nominateButton: MDCRaisedButton!
    @IBOutlet weak var nominateView: UIView!
    
    // Variables Associated with above
    let titleText = "   Golden Action Nominees"
    var testData  = [[String : Any]]()
    
    var currentVC:NomineesViewController?
    
    // Most Likely Temp Variable
    var cities = [Cities]()
    var nominations = [Nominations]()
    var nominationz = MutableObservableArray<Nominations>()
    //Contains pending niminations for user approval
    var pendingNominations = [Nominations]()
    
    var searchedNominations = [Nominations]()
    var searchedPendingNominations = [Nominations]()
    // MARK: - Table View for Nominations
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser: Person!
    var currentLocation: Cities!
    var currentCategory: String!
    // Search Bar Controller
    var searchController : UISearchController!
    // Track Current Location if applicable
    var locationManage: CLLocationManager?
    
    let app_color = Colors.app_color.generateColor()
    // Download Check for Anonymous Account
    let download_key = Keys.download_check.key
    let uid_key = Keys.uid.key
    let keychain = KeychainWrapper.standard
    
    let loading_id = VCID.loading_screen.id
    
    
    var walkthrough: BWWalkthroughViewController!
    var page_one: FirstGoldenTutorialViewController!
    var page_five: LastGoldenTutorialViewController!
    
    var isSearching = false
    let prepareHandler: PrepareHandler = { view in
        view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    }
    let changeFunction: ChangeFunction = { view in
        view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    let test = true
    var filteredTableData = [String]()
    var resultSearchController:UISearchBar!
    
    
    
    var totalAmount:Float = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(Auth.auth().currentUser.toDictionary())
        
        let colorImage = self.gradient(size: (self.categoryButton.frame.size), color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.categoryButton.backgroundColor = UIColor.init(patternImage: colorImage!)
        
        let colorImage1 = self.gradient(size: (self.nominateView.frame.size), color: [Constants.gradientStartColor, Constants.gradientEndColor])
        nominateView.backgroundColor = UIColor.init(patternImage: colorImage1!)
        nominateView.layer.masksToBounds = true
        nominateView.layer.cornerRadius = 20.5
        
        // Refresh
        self.pullElastic()
        self.tapDismiss()
        self.tabBarController?.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
        self.setNavigationBarColor()
        // Table View Setup
        self.setUpTableView(tableView: self.tableView)
        self.designTableView(tableView: self.tableView)
        self.setUpNav()
        self.setUpTitleView()
        self.observeLegal()
        self.observeAppUpdate()
        self.observeYourActiveNomination()
        loadIndicatorView()
        // Navigation Controller Setup
        // Search Controller Setup
        // Add Target for function to New Nominate Button
        self.nominateButton.addTarget(self, action: #selector(newNomination(_:)), for: .touchUpInside)
       
        self.addSearchBar()
        self.startUserLoadChain()
        
        //This is delegate variable is used to show sucessfull message
        appDelegate.nomineeController = self
        
        if currentUser == nil {
            self.loadNominations(region: "000", category: FilterStrings.all_category.id)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSearching = false
        if Auth.auth().currentUser != nil
        {
            self.tabBarButtonEdit(enabled: true)
            
            if self.currentUser == nil
            {
                self.startUserLoadChain()
            }
            else
            {
                if (self.currentCategory != nil) && (self.currentLocation != nil)
                {
                    Authorize.instance.currentNomLocation = self.currentLocation
                    Authorize.instance.currentNomCategory = self.currentCategory
                    self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
                    
                    if !self.nominations.isEmpty
                    {
                        self.pullElastic()
                    }
                    else{
//                        self.loadNominations(region: "000", category: self.currentCategory)
                    }
                }
                else
                {
                    self.startUserLoadChain()
                }
            }
        }
        else
        {
            //self.createAnonymousUser()
//            if !KeychainWrapper.standard.hasValue(forKey: Keys.download_check.key) {
//                self.setUpTutorialWalkthrough()
//            }
        }
        self.addSearchBar()
        self.startUserLoadChain()
        
        //This is delegate variable is used to show sucessfull message
        appDelegate.nomineeController = self
        self.loadPendingNomination()
        
        self.configureProfilePicture()
    }
    
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
    }
    
    func addSearchBar(){
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
        
    }
    
    func setNavigationBarColor(){
        let imageColor = self.gradient(size: (self.navigationController?.navigationBar.frame.size)!, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.navigationController?.navigationBar.barTintColor = UIColor.init(patternImage: imageColor!)
        self.navigationController?.navigationBar.tintColor = UIColor.init(patternImage: imageColor!)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
    }
    
    func setNavigationDefaultColor1(){
        let colorImage = self.gradient(size: (self.navigationController?.navigationBar.frame.size)!, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.navigationController?.navigationBar.barTintColor = UIColor.init(patternImage: colorImage!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentVC = self
        self.startUserLoadChain()
        
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
        self.tableView.dg_setPullToRefreshBackgroundColor(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
    }
    
    func elasticRefresh(tableView: UITableView) {
        let workItem = DispatchWorkItem {
            if InternetConnection.instance.isInternetAvailable() {
                if self.currentUser != nil {
                    self.startUserLoadChain()
                } else {
//                    self.createAnonymousUser()
                }
                tableView.dg_stopLoading()
            } else {
                self.goldenAlert(title: "No Internet Connection", message: "Please connect to internet and refresh the page", view: self)
                tableView.dg_stopLoading()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(100), execute: workItem)
    }
    // MARK: - Refresh Method
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.isSearching = false
        if InternetConnection.instance.isInternetAvailable() {
            if self.currentUser != nil {
                self.startUserLoadChain()
            } else {
//                self.createAnonymousUser()
            }
            refreshControl.endRefreshing()
        } else {
            self.goldenAlert(title: "No Internet Connection", message: "Please connect to internet and refresh the page", view: self)
            refreshControl.endRefreshing()
        }
        
    }
    
    func startUserLoadChain()
    {
        self.loadCurrentUser() { (currentUser, error) in
            guard error == nil && currentUser != nil else
            {
                print("Hey error loading current user")
//                self.createAnonymousUser()
                return
            }
            self.currentUser = currentUser!
            self.configureProfilePicture()
            self.startNeededChain()
            self.loadPendingNomination()
            print("User Instantiated")
        }
    }
    func startNeededChain() {
        let workItem = DispatchWorkItem {
            self.loadLastLocation(uid: self.currentUser.uid, completion: { (city) in
                self.currentLocation = city
                
                self.setUpTitleView()
                self.loadNominations(region: "000", category: self.currentCategory)
            })
        }
        let firstItem = DispatchWorkItem {
            self.loadLastCategory(uid: self.currentUser.uid, completion: { (category) in
                self.currentCategory = category
                self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
                // self.categoryIcon.image = self.generateTitleView(currentCategory: self.currentCategory)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: workItem)
            })
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: firstItem)
    }
    
    
    
    
    
    // MARK: - Setup Nomination Title View
    func setUpTitleView() {
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryFilterTapped(recognizer:)))
        //let locationGesture = UITapGestureRecognizer(target: self, action: #selector(locationFilterTapped(recognizer:)))
        
        let colorImage = self.gradient(size: self.titleLabel.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.titleLabel.textColor = UIColor.init(patternImage: colorImage!)
        self.titleLabel.text = self.titleText
        
        self.categoryButton.isUserInteractionEnabled = true
        self.categoryButton.addGestureRecognizer(categoryGesture)
        
        self.categoryButton.layer.masksToBounds = true
        self.categoryButton.layer.cornerRadius = 10.0
        
    }
    
    @objc func categoryFilterTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            self.showCategoryAfterTap(filterType: self.currentCategory)
        }
    }
    
    @objc func locationFilterTapped(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.began) || (recognizer.state == UIGestureRecognizerState.ended) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: VCID.filter_location.id) as! FilterLocationViewController
            vc.nomination = true
            vc.nominationVC = self
            vc.cityState = self.currentLocation.cityState
            vc.cluster = self.currentLocation.clusterNumber
            vc.currentUserCity = self.currentUser.cityState
            vc.currentUserCluster = self.currentUser.region
            vc.uid = self.currentUser.uid
            let workItem = DispatchWorkItem {
                self.present(vc, animated: true, completion: nil)
            }
            self.providesPresentationContextTransitionStyle = true
            self.definesPresentationContext = true
            self.modalPresentationCapturesStatusBarAppearance = false
            vc.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: workItem)
        }
    }
    // MARK: - Create Nominatation Implementation
    @objc func newNomination(_ sender: UIButton) {
        
        
//        if self.checkInternet() == false{
//            return
//        }
//
//
//        guard Auth.auth().currentUser != nil else {
//            self.goldenAlert(title: "User login", message: "Please check your login first.", view: self)
//            return
//        }
//
//        guard self.currentUser != nil else{
//            self.goldenAlert(title: "User login", message: "Please check your login first.", view: self)
//            return
//        }
        
        
                let workItem = DispatchWorkItem {
                let oneCreate = self.storyboard?.instantiateViewController(withIdentifier: VCID.one_create_nom.id) as! OneCreateNominationViewController
                oneCreate.phaseOne = true
                oneCreate.currentUser = self.currentUser
                let navVc = UINavigationController(rootViewController: oneCreate)
                navVc.setNavigationBarHidden(true, animated: false)
                self.present(navVc, animated: true, completion: nil)
            }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
         
        
    }
    
    // MARK: - Navigation Controller Setup
    func setUpNav() {
        // Navigation Bar Color
        self.setBarTint()
        self.setBarButtonTint()
        self.checkoutButton.action = #selector(checkoutSegue(_:))
        self.checkoutButton.target = self
        self.profileButton.action = #selector(profileSegue(_:))
        self.profileButton.target = self
        self.notificationButton.action = #selector(notificationSegue(_:))
        self.notificationButton.target = self
        
    }
    
    @objc func profileSegue(_ sender: UIBarButtonItem) {
        
        if self.checkInternet() == false{
            return
        }
        
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
        print(self.currentUser.toDictionary())
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.nom_profile.id, sender: self)
        } else {
            let backWorkItem = DispatchWorkItem {
                print("Profile WorkItem")
            }
            let workItem = DispatchWorkItem {
                //self.checkVerification(currentUser: self.currentUser, message: "You must have an account to viw your profile.", workitem: backWorkItem)
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    
    @objc func notificationSegue(_ sender: UIBarButtonItem) {
        
        if self.checkInternet() == false{
            return
        }
        
        guard self.currentUser != nil else {
            return
        }
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.nom_notif.id, sender: self)
            
//            let checkoutVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.cart_screen.id) as! CartViewController
//            checkoutVC.currentUser = self.currentUser
//            self.navigationController?.pushViewController(checkoutVC, animated: true)
            
        } else {
            let backWorkItem = DispatchWorkItem {
                print("Notifications WorkItem")
            }
            
            let workItem = DispatchWorkItem {
                //self.checkVerification(currentUser: self.currentUser, message: "You must have an account to view notifications", workitem: backWorkItem)
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    
    @objc func checkoutSegue(_ sender: UIBarButtonItem) {
        
        if self.checkInternet() == false{
            return
        }
        
        guard self.currentUser != nil else {
            return
        }
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.nom_cart.id, sender: self)
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
//        if segue.identifier == SegueId.nom_create.id {
//            let destinationVC = segue.destination as! CreateNominationTableViewController
//            destinationVC.currentUser = self.currentUser
//        } else
        
        if segue.identifier == SegueId.nom_profile.id {
            let destinationVC = segue.destination as! ProfileTableViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.nom_search.id {
            let destinationVC = segue.destination as! SearchResultsTableViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.nom_cart.id {
            let destinationVC = segue.destination as! CartViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.nom_notif.id {
            let destinationVC = segue.destination as! NotificationViewController
            destinationVC.currentUser = self.currentUser
        }
    }
    func monitorLastCreate() {
        
    }
    
    // MARK: - Segue to Detail Gesture Recognizer
    @objc func toDetail(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            print("Sup Recognized")
            print("------------->")
            let tapCell = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                if let tapCell = self.tableView.cellForRow(at: indexPath) as? NomineesTableViewCell {
                    // MARK: - Pass data from this cell to nom detail controller
                    print("Tap Recognized")
                    print("------------->self")
                    let nomDetailVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.nominee_detail.id) as! NomDetailTableViewController
                    nomDetailVC.nomination = tapCell.nominations
                    nomDetailVC.currentUser = tapCell.nominations.nominee
                    let navVC = UINavigationController(rootViewController: nomDetailVC)
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Gesture Recognizer Delegate
    
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                self.dismiss(animated: true, completion: nil)
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    deinit {
        tableView.dg_removePullToRefresh()
    }
}

extension NomineesViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View Setup & Delegate Implementation
    func setUpTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(self.pendingNominations.count == 0){
            if(section == 0){
                return 0
            }else{
                return 25.0
            }
            
        }
        return 24.0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            
            if(self.pendingNominations.count == 0){
                return ""
            }
            return "Pending Nominees"
        }else{
            return "Approved Nominees"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            if section == 0 {
                return self.searchedPendingNominations.count > 0 ? self.searchedPendingNominations.count : 0
            }else {
                return self.searchedNominations.count > 0 ? self.searchedNominations.count : 0
            }
        } else {
            if section == 0 {
                return self.pendingNominations.count > 0 ? self.pendingNominations.count : 0
            }else{
                return self.nominations.count > 0 ? self.nominations.count : 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var nom: Nominations!
        if self.isSearching {
            if indexPath.section == 0{
                if self.searchedPendingNominations.count > 0 {
                    nom = self.searchedPendingNominations[indexPath.row]
                }else{
                    let recordNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "RecordNotFound")
                    return recordNotFoundCell!
                }
                
            }else{
                if self.searchedNominations.count > 0 {
                    nom = self.searchedNominations[indexPath.row]
                }else{
                    let recordNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "RecordNotFound")
                    return recordNotFoundCell!
                }
            }
        } else {
            if indexPath.section == 0{
                if self.pendingNominations.count > 0 {
                    nom = self.pendingNominations[indexPath.row]
                }else{
                    let recordNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "RecordNotFound")
                    return recordNotFoundCell!
                }
                
            }else{
                if self.nominations.count > 0 {
                    nom = self.nominations[indexPath.row]
                }else{
                    let recordNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "RecordNotFound")
                    return recordNotFoundCell!
                }
            }
        }
        // Make Gesture Recognizer
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.nominees_cell.id, for: indexPath) as! NomineesTableViewCell
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
        cell.nominations = nom
        cell.configureNom(nom: nom)
        cell.contentView.addGestureRecognizer(gesture)
        cell.profilePic.addGestureRecognizer(gesture)
        cell.addGestureRecognizer(gesture)
        
        if nom.urls.count > 0{
            let imageUrl = nom.urls[0]
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            cell.profilePic.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearching {
            if indexPath.row < self.searchedNominations.count {
                return 100.0
            } else {
                return 100.0
            }
        } else {
            if indexPath.row < self.nominations.count {
                return 100.0
            } else {
                return 100.0
            }
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearching {
            if indexPath.row < self.searchedNominations.count {
                return 100.0
            } else {
                return 100.0
            }
        } else {
            if indexPath.row < self.nominations.count {
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
extension NomineesViewController {
    // MARK: - General Observers for Home Screen
    
    func observeYourActiveNomination() {
        if Auth.auth().currentUser != nil {
            guard self.currentUser != nil, let nom = self.currentUser.nominee else {
                return
            }
            if nom {
                self.currentUser.observeFinished { (finishedNominations) in
                    let finishedVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.golden_award_screen.id) as! NominationFinishedViewController
                    let workItem = DispatchWorkItem {
                        self.present(finishedVC, animated: true, completion: nil)
                    }
                    self.providesPresentationContextTransitionStyle = true
                    self.definesPresentationContext = true
                    self.modalPresentationCapturesStatusBarAppearance = false
                    finishedVC.modalPresentationStyle = .overCurrentContext
                    finishedVC.nominations = finishedNominations
                    DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(50), execute: workItem)
                }
            }
            
        }
    }
    func observeLegal() {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            Person.checkLegal(uid: uid) { (agreed) in
                if !agreed {
                    let id = VCID.signup_legal.id
                    let legalVC = self.storyboard?.instantiateViewController(withIdentifier: id) as! SignupLegalViewController
                    self.present(legalVC, animated: true, completion: nil)
                }
            }
        }
    }
    // MARK: - Load Current Person
    func loadCurrentUser(completion: @escaping (Person?, String?) -> Void) {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            self.loadPerson(uid: uid, completion: { (person, error) in
                completion(person, error)
            })
            
        } else {
            self.currentUser = nil
//            self.createAnonymousUser()
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
//    func createAnonymousUser() {
//        if self.keychain.hasValue(forKey: Keys.download_check.key) {
//            Authorize.instance.resignAnon(view: self) { (error) in
//                guard error == nil else {
//                    print(error!.localizedDescription)
//                    return
//                }
//                Messaging.messaging().subscribe(toTopic: "000")
//                self.startUserLoadChain()
//            }
//        } else {
//            Authorize.instance.signUpAnonymously(view: self) { (error) in
//                guard error == nil else {
//                    print(error!.localizedDescription)
//                    return
//                }
//                Messaging.messaging().subscribe(toTopic: "000")
//                self.setUpTutorialWalkthrough()
//            }
//        }
//
//    }
    // MARK: - Load Last Category and Location
    func loadLastCategory(uid: String, completion: @escaping (String) -> Void) {
        DBRef.userLastNomCategory(uid: uid).reference().observe(.value) { (snapshot) in
            let category = snapshot.value as? String ?? FilterStrings.all_category.id
            completion(category)
        }
    }
    func loadLastLocation(uid: String, completion: @escaping (Cities) -> Void) {
        DBRef.userLastNomLocation(uid: uid).reference().observe(.value) { (snapshot) in
            if let city = snapshot.value as? [String : Any] {
                let obj = Cities(userLocDict: city)
                completion(obj)
            } else {
                let obj = Cities(cluster: "000", cityState: FilterStrings.popular_location.id)
                completion(obj)
            }
        }
    }
}
extension NomineesViewController: BWWalkthroughViewControllerDelegate {
    
    func setUpTutorialWalkthrough() {
        let sub = UIStoryboard(name: "Main", bundle: nil)
        self.walkthrough = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial.id) as? BWWalkthroughViewController
        self.page_one = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_one.id) as? FirstGoldenTutorialViewController
        let page_two = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_two.id) as! BWWalkthroughPageViewController
        let page_three = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_three.id) as! BWWalkthroughPageViewController
        let page_four = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_four.id) as! BWWalkthroughPageViewController
        self.page_five = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_five.id) as? LastGoldenTutorialViewController
        self.walkthrough.delegate = self
        self.walkthrough.add(viewController: self.page_one)
        self.walkthrough.add(viewController: page_two)
        self.walkthrough.add(viewController: page_three)
        self.walkthrough.add(viewController: page_four)
        self.walkthrough.add(viewController: self.page_five)
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .left
        self.page_five.topView.isUserInteractionEnabled = true
        self.page_five.topView.addGestureRecognizer(gesture)
        self.modalPresentationCapturesStatusBarAppearance = false
        self.present(self.walkthrough, animated: true, completion: nil)
    }
    func walkthroughPageDidChange(_ pageNumber: Int) {
        if (self.walkthrough.numberOfPages - 1) == pageNumber {
            /*if let vc = self.walkthrough.currentViewController as? BWWalkthroughViewController {
             let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
             gestureRecognizer.direction = .left
             vc.view.isUserInteractionEnabled = true
             vc.view.addGestureRecognizer(gestureRecognizer)
             print("Added")
             
             } */
            print(pageNumber)
            let workItem = DispatchWorkItem {
                self.dismiss(animated: true, completion: nil)
                self.startUserLoadChain()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: workItem)
            
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
        print("Swiped")
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

extension UIViewController {
    
    // MARK: - App Wide Observe for Update
    func observeAppUpdate() {
        if Auth.auth().currentUser != nil {
            Person.monitorAppUpdate { (version, appURL) in
                let key = Keys.app_version(version: version).key
                if !KeychainWrapper.standard.hasValue(forKey: key) {
                    let appStoreItem = DispatchWorkItem {
                        self.dismiss(animated: true, completion: nil)
                        KeychainWrapper.standard.set(true, forKey: key)
                        if let url = URL(string: "https://\(appURL)"),
                            UIApplication.shared.canOpenURL(url)
                        {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                    let alert = self.goldenCustomActions(vc: self, title: "App Update", message: "Please click below to go to the App Store and download the newest update. We wish to make the app as high quality as possible!", buttonOneTitle: "Go to App Store", buttonTwoTitle: nil, buttonOneAction: appStoreItem, buttonTwoAction: nil, buttonThreeAction: nil, buttonThreeTitle: nil, twoAction: false, threeAction: false)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkTutorial() {
        let key = KeychainWrapper.standard
        if !key.hasValue(forKey: Keys.download_check.key) {
            self.performSegue(withIdentifier: SegueId.nomination_tutorialone.id, sender: self)
        }
    }
    
}


/// Search delegate
extension NomineesViewController{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false;
        self.tableView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false;
        self.tableView.reloadData()
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false;
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedNominations.removeAll()
        self.searchedPendingNominations.removeAll()
        
        filteredTableData.removeAll(keepingCapacity: false)
        
        if (searchText.count) > 0 {
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        
        //let searchPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchController.searchBar.text!)
        self.nominations.forEach({
            if $0.nominee.fullName.range(of: searchText, options: .caseInsensitive) != nil || $0.searchCode.range(of: searchText, options: .caseInsensitive) != nil {
                print("exist")
                if !self.searchedNominations.contains($0) {
                    self.searchedNominations.append($0)
                }
            }
        })
        
        self.pendingNominations.forEach({
            if $0.nominee.fullName.range(of: searchText, options: .caseInsensitive) != nil || $0.searchCode.range(of: searchText, options: .caseInsensitive) != nil {
                print("exist")
                if !self.searchedPendingNominations.contains($0) {
                    self.searchedPendingNominations.append($0)
                }
            }
        })
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
//        self.searchedNominations.removeAll()
//        self.searchedPendingNominations.removeAll()
//
//        filteredTableData.removeAll(keepingCapacity: false)
//
//        let searchTxt = text
//
//        if (searchTxt.count) > 0 {
//            self.isSearching = true
//        }else{
//            self.isSearching = false
//        }
//
//        //let searchPredicate = NSPredicate(format: "fullName CONTAINS[c] %@", searchController.searchBar.text!)
//        self.nominations.forEach({
//            if $0.nominee.fullName.contains(find: searchTxt){
//                print("exist")
//                if !self.searchedNominations.contains($0) {
//                    self.searchedNominations.append($0)
//                }
//            }
//        })
//
//        self.pendingNominations.forEach({
//            if $0.nominee.fullName.contains(find: searchTxt){
//                print("exist")
//                if !self.searchedPendingNominations.contains($0) {
//                    self.searchedPendingNominations.append($0)
//                }
//            }
//        })
//
//        self.tableView.reloadData()
        return true
    }
    
    
    
    
}


extension NomineesViewController
{
   
    
    func showCategoryAfterTap(filterType:String)
    {
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
            kTitleFont: UIFont(name: "Avenir Next", size: 20)!,
            kTextFont: UIFont(name: "Avenir Next", size: 14)!,
            kButtonFont: UIFont(name: "Avenir Next", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false,
            hideWhenBackgroundViewIsTapped: true
        )
        alertView = SCLAlertView(appearance: appearance)

        
        for btn in buttonTitleArray{
            alertView.addButton(btn, backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil){
                print(btn)
                self.currentCategory = btn
                if self.currentCategory == "All"{
                    self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: "Categories"), for: [])
                }else{
                    self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
                }
                //self.loadAwards(region: "", category: self.currentCategory, loadVC: nil)
                self.loadNominations(region: "", category: self.currentCategory)
            }
        }
        alertView.showInfo("Choose category", subTitle: "")
    }
}



extension NomineesViewController{
    
    func configureProfilePicture(){
        guard self.currentUser != nil else {
              let img = UIImage(named:"profileicon")
              let button = UIButton(type: .custom)
              button.isUserInteractionEnabled = true
              //button.contentMode = UIViewContentMode.scaleAspectFill
              button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                                     button.translatesAutoresizingMaskIntoConstraints = false
                                     button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
                                     button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
                                     button.layer.masksToBounds = true
                                     button.layer.cornerRadius = button.bounds.size.width / 2
                                     button.addTarget(self, action: #selector(self.profileSegue(_:)), for: .touchUpInside)
             button.setImage(img, for: .normal)
               self.profileButton.customView = button

            return
        }
        // self.activityView.startAnimating()
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            
            print("***********\(imageUrl)***********")
            
            
            
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



extension NomineesViewController{
    // MARK: - Load Nominations
    func loadNominations(region: String, category: String) {
        print(category)
        self.nominations.removeAll()
        self.activityView.startAnimating()
        if region != "000" {
            Nominations.getNominationsRegion(region: region, awards: false, category: category) { (error, noms) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                self.totalAmount = 0
                for nom in noms {
                    /*self.nominations.map{ $0.uid != nom.uid }.bind(to: self.tableView) { array, indexPath, collectionView in
                     
                     } */
                    if !self.nominations.contains(nom) {
                        let interval = Date().timeIntervalSince1970
                        if nom.endDate >= interval {
                            self.nominations.append(nom)
                        }
                    }
                    
                    let count = nom.numberOfVotes
                    
                    if count > 30 && count <= 50 {
                        self.totalAmount += 10
                    }else if count > 50 && count <= 80 {
                        self.totalAmount += 20
                    }else if count > 80 {
                        self.totalAmount += 30
                    } else if count > 110 {
                        self.totalAmount += 40
                    }
                    
                }
                print(noms.count)
                print("Noms Got")
                self.nominations.sort()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.lblTotalDonation.text = String(format: "Total Raised: $%.2f", self.totalAmount)
                }
                self.activityView.stopAnimating()
            }
        } else {
            Nominations.getNominationsHigh(awards: false, category: category) { (error, noms) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                self.totalAmount = 0
                for nom in noms {
                    if !self.nominations.contains(nom) {
                        let interval = Date().timeIntervalSince1970
                            if nom.endDate >= interval {
                            self.nominations.append(nom)
                        }
                    }
                    let count = nom.numberOfVotes
                    
                    if count > 30 && count <= 50 {
                        self.totalAmount += 10
                    }else if count > 50 && count <= 80 {
                        self.totalAmount += 20
                    }else if count > 80 && count <= 110 {
                        self.totalAmount += 30
                    } else if count > 110 {
                        
                    }
                }
                
                print(noms.count)
                print("Noms Got")
                print(self.totalAmount)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.lblTotalDonation.text = String(format: "Total Raised: $%.2f", self.totalAmount)
                }
                self.activityView.stopAnimating()
            }
        }
    }
    
    
    func loadPendingNomination()
    {
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        guard self.currentUser != nil else{
            return
        }
        print(self.currentUser.toDictionary())
        if self.currentUser.acctType != "anon" {
            
        }else{
            self.pendingNominations.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        
        self.activityView.startAnimating()
        
        Nominations.getPendingListWhereImNomineeWithEmail(email: self.currentUser.email, phone: self.currentUser.phone, completion: {
            (error, noms) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.pendingNominations.removeAll()
            self.totalAmount = 0
            for nom in noms {
//                if !self.pendingNominations.contains(nom) {
                    self.pendingNominations.append(nom)
//                }
                let count = nom.numberOfVotes
                
                if count > 30 && count <= 50 {
                    self.totalAmount += 10
                }else if count > 50 && count <= 80 {
                    self.totalAmount += 20
                }else if count > 80 {
                    self.totalAmount += 30
                }
            }
            print("total pending Noms Got")
            print(noms.count)
            print(self.totalAmount)
            
            DispatchQueue.main.async {
                self.lblTotalDonation.text = String(format: "Total Raised: $%.2f", self.totalAmount)
                self.tableView.reloadData()
            }
            
            self.activityView.stopAnimating()
            
        })
    }
}
