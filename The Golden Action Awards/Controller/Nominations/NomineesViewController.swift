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


class NomineesViewController1: UIViewController {
    // MARK: - Bar Button Declaration
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var checkoutButton: UIBarButtonItem!
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    // MARK: - In title view
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var locationButton: MDCRaisedButton!
    @IBOutlet weak var categoryButton: MDCRaisedButton!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var nominateButton: MDCRaisedButton!
    
    // Variables Associated with above
    let titleText = "Golden Action Nominees"
    var testData  = [[String : Any]]()
    var samples   = [0,1,2,3,4,5,6,7,8,9]
    
    var currentVC:NomineesViewController?
    
    // Most Likely Temp Variable
    var cities = [Cities]()
    var nominations = [Nominations]()
    var nominationz = MutableObservableArray<Nominations>()
    
    var searchedNominations = [Nominations]()
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
    let per = Person(uid: "N/A", fullName: "N/A", acctType: AcctType.email.type, profilePic: "N/A", email: "N/A", phone: "N/A", region: "N/A", cityState: "N/A", uuid: "N/A", admin: false, adminStage: 0, adminDescription: "")
    let charity = Charity(charityName: "Sup Charity", address: "Hey", ein: "hey")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //scl.loadFirstPhoneAlert()
        // Refresh
        self.pullElastic()
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.tapDismiss()
        self.tabBarController?.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // Table View Setup
        self.setUpTableView(tableView: self.tableView)
        self.designTableView(tableView: self.tableView)
        self.setUpNav()
        self.setUpTitleView()
        self.observeLegal()
        self.observeAppUpdate()
        self.observeYourActiveNomination()
        // Navigation Controller Setup
        // Search Controller Setup
        //self.setUpSearchBar()
        // Add Target for function to New Nominate Button
        self.nominateButton.addTarget(self, action: #selector(newNomination(_:)), for: .touchUpInside)
        // Refresh Control
        //let refreshControl = UIRefreshControl()
        //refreshControl.tintColor = self.app_color
        //refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        /*if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.backgroundView = refreshControl
        }*/
       
        if Auth.auth().currentUser != nil {
            self.tabBarButtonEdit(enabled: true)
            if self.currentUser == nil {
                //self.nominations = []
                self.startUserLoadChain()
            } else {
                if (self.currentCategory != nil) && (self.currentLocation != nil) {
                    Authorize.instance.currentNomLocation = self.currentLocation
                    Authorize.instance.currentNomCategory = self.currentCategory
                    self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
                    self.locationButton.setAttributedTitle(Strings.titleview_location.generateString(text: self.currentLocation.cityState), for: [])
                    self.categoryIcon.image = self.generateTitleView(currentCategory: self.currentCategory)
                    
                    if !self.nominations.isEmpty {
                        //self.refresh(refreshControl)
                        self.pullElastic()
                    } else {
                        self.loadNominations(region: self.currentLocation.clusterNumber, category: self.currentCategory)
                    }
                    
                } else {
                    self.startUserLoadChain()
                }
            }
        } else {
            print("Hey Man!!")
            self.createAnonymousUser()
            if !KeychainWrapper.standard.hasValue(forKey: Keys.download_check.key) {
                self.setUpTutorialWalkthrough()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentVC = self
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
    func elasticRefresh(tableView: UITableView) {
        let workItem = DispatchWorkItem {
            if InternetConnection.instance.isInternetAvailable() {
                if self.currentUser != nil {
                    self.startUserLoadChain()
                } else {
                    self.createAnonymousUser()
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
                self.createAnonymousUser()
            }
            refreshControl.endRefreshing()
        } else {
            self.goldenAlert(title: "No Internet Connection", message: "Please connect to internet and refresh the page", view: self)
            refreshControl.endRefreshing()
        }
        
    }
    
    func startUserLoadChain() {
        self.loadCurrentUser() { (currentUser, error) in
            guard error == nil && currentUser != nil else {
                print("Hey error loading current user")
                self.createAnonymousUser()
                return
            }
            self.currentUser = currentUser!
            self.startNeededChain()
            print("User Instantiated")
        }
    }
    func startNeededChain() {
        let workItem = DispatchWorkItem {
            self.loadLastLocation(uid: self.currentUser.uid, completion: { (city) in
                self.currentLocation = city
                self.locationButton.setAttributedTitle(Strings.titleview_location.generateString(text: self.currentLocation.cityState), for: [])
                self.setUpTitleView()
                self.loadNominations(region: self.currentLocation.clusterNumber, category: self.currentCategory)
            })
        }
        let firstItem = DispatchWorkItem {
            self.loadLastCategory(uid: self.currentUser.uid, completion: { (category) in
                self.currentCategory = category
                self.categoryButton.setAttributedTitle(Strings.titleview_category.generateString(text: self.currentCategory), for: [])
                self.categoryIcon.image = self.generateTitleView(currentCategory: self.currentCategory)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: workItem)
            })

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: firstItem)
    }
    
    
    
    // MARK: - Load Nominations
    func loadNominations(region: String, category: String) {
        if region != "000" {
            Nominations.getNominationsRegion(region: region, awards: false, category: category) { (error, noms) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                for nom in noms {
                    /*self.nominations.map{ $0.uid != nom.uid }.bind(to: self.tableView) { array, indexPath, collectionView in
                        
                    } */
                    if !self.nominations.contains(nom) {
                        self.nominations.append(nom)
                    }
                }
                print(noms.count)
                print("Noms Got")
                self.nominations.sort()
                self.tableView.reloadData()
            }
        } else {
            Nominations.getNominationsHigh(awards: false, category: category) { (error, noms) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                for nom in noms {
                    if !self.nominations.contains(nom) {
                        self.nominations.append(nom)
                    }
                }
                print(noms.count)
                print("Noms Got")
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Setup Nomination Title View
    func setUpTitleView() {
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryFilterTapped(recognizer:)))
        let locationGesture = UITapGestureRecognizer(target: self, action: #selector(locationFilterTapped(recognizer:)))
        self.titleLabel.attributedText = Strings.titleview_title.generateString(text: self.titleText)
        self.categoryButton.isUserInteractionEnabled = true
        self.categoryButton.addGestureRecognizer(categoryGesture)
        self.locationButton.isUserInteractionEnabled = true
        self.locationButton.addGestureRecognizer(locationGesture)
        
        self.categoryButton.layer.masksToBounds = true
        self.categoryButton.layer.cornerRadius = 10.0
        self.locationButton.layer.masksToBounds = true
        self.locationButton.layer.cornerRadius = 10.0
        
    }
    @objc func categoryFilterTapped(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.began) || (recognizer.state == UIGestureRecognizerState.ended) {
            let categoryPopup = FilterPopup(vc: self, filterType: self.currentCategory ?? FilterStrings.all_category.id, nomination: true, uid: self.currentUser.uid)
            let workItem = DispatchWorkItem {
                self.present(categoryPopup.popup, animated: true, completion: nil)
            }
            self.providesPresentationContextTransitionStyle = true
            self.definesPresentationContext = true
            self.modalPresentationCapturesStatusBarAppearance = false
            categoryPopup.createCategoryPopup()
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(10), execute: workItem)
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
        self.checkInternet()
        guard self.currentUser != nil else {
            return
        }
/*        if self.currentUser.acctType == AcctType.anonymous.type {
            let backWorkItem = DispatchWorkItem {
                print("New Nomination WorkItem")
            }
            
            let workItem = DispatchWorkItem {
                self.checkVerification(currentUser: self.currentUser, message: "You must have an account to view notifications", workitem: backWorkItem)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        } else { */
        let workItem = DispatchWorkItem {
            let oneCreate = self.storyboard?.instantiateViewController(withIdentifier: VCID.one_create_nom.id) as! OneCreateNominationViewController
            oneCreate.phaseOne = true
            oneCreate.currentUser = self.currentUser
            let navVc = UINavigationController(rootViewController: oneCreate)
            navVc.setNavigationBarHidden(true, animated: false)
            self.present(navVc, animated: true, completion: nil)
            print(oneCreate)
            print(navVc)
            print(oneCreate)
            print(sender)

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)

 //       }
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
        self.checkInternet()
        guard self.currentUser != nil else {
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
                self.checkVerification(currentUser: self.currentUser, message: "You must have an account to viw your profile.", workitem: backWorkItem)
                /*let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)*/
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    @objc func notificationSegue(_ sender: UIBarButtonItem) {
        self.checkInternet()
        guard self.currentUser != nil else {
            return
        }
        if self.currentUser.acctType != "anon" {
            self.performSegue(withIdentifier: SegueId.nom_notif.id, sender: self)
        } else {
            let backWorkItem = DispatchWorkItem {
                print("Notifications WorkItem")
            }
            
            let workItem = DispatchWorkItem {
                self.checkVerification(currentUser: self.currentUser, message: "You must have an account to view notifications", workitem: backWorkItem)
                /*let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
                let navVC = UINavigationController(rootViewController: welcomeVC)
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true, completion: nil)*/
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    @objc func checkoutSegue(_ sender: UIBarButtonItem) {
        self.checkInternet()
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
                self.checkVerification(currentUser: self.currentUser, message: "You must have an account to view purchase nominations or votes", workitem: backWorkItem)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.nom_create.id {
            let destinationVC = segue.destination as! CreateNominationTableViewController
            destinationVC.currentUser = self.currentUser
        } else if segue.identifier == SegueId.nom_profile.id {
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
    // MARK: - Search Bar Controller
    // Setup
    /*func setUpSearchBar() {
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.placeholder = "Search for nominations!"
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.searchBar.barTintColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.50)
        self.searchController.searchBar.tintColor = Colors.app_text.generateColor()
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
    }*/
    /*func searchNominations(txt: String) {
        guard txt != "" else {
            return
        }
        let ref = AlgoliaRef.nominations.reference()
        Nominations.searchNominationsAwards(query: txt, ref: ref) { (noms) in
            self.searchedNominations = noms
        }
        
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard is hidden")
        self.searchController.searchBar.barTintColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.50)
        self.searchController.searchBar.tintColor = Colors.app_text.generateColor()
        self.searchController.searchBar.setShowsCancelButton(false, animated: true)
    } */

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = 0
        if self.isSearching {
            if self.searchedNominations != [] {
                tableView.separatorStyle = .singleLine
                numSections = 1
                tableView.backgroundView = nil
                self.tableView.backgroundView = nil
            } else {
                let imageView = UIImageView.init(image: StaticPictures.background.generatePic())
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.frame = self.tableView.bounds
                self.tableView.backgroundView = imageView
                self.tableView.separatorStyle = .none
            }
        } else {
            if self.nominations != [] {
                tableView.separatorStyle = .singleLine
                numSections = 1
                tableView.backgroundView = nil
                self.tableView.backgroundView = nil
            } else {
                let imageView = UIImageView.init(image: StaticPictures.background.generatePic())
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.frame = self.tableView.bounds
                self.tableView.backgroundView = imageView
                self.tableView.separatorStyle = .none
            }
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.searchedNominations.count
        } else {
            return self.nominations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.nominees_cell.id, for: indexPath) as! NomineesTableViewCell
        var nom: Nominations!
        if self.isSearching {
            nom = self.searchedNominations[indexPath.row]
        } else {
            nom = self.nominations[indexPath.row]
        }
        // Make Gesture Recognizer
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toDetail(recognizer:)))
        cell.configureNom(nom: nom)
        cell.nominations = nom
        cell.contentView.addGestureRecognizer(gesture)
        cell.profilePic.addGestureRecognizer(gesture)
        
        if nom.urls.count > 0{
            let imageUrl = nom.urls[0]
            let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
                storageRef.downloadURL(completion: { (url, error) in
                 do{
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    cell.profilePic.image = image

                 }catch{
                    print(error)
                    }
               })
        }
        return cell
    }
    
//    func getProfileImage(imageUrl:String) -> UIImage{
//        let storageRef = Storage.storage().reference()
//        let imagesRef = storageRef.child("nominationPics")
//        //let fileName = "space.jpg"
//        let spaceRef = imagesRef.child(imageUrl)
//
//        // File path is "images/space.jpg"
//        //let path = spaceRef.fullPath;
//
//        // File name is "space.jpg"
//        //let name = spaceRef.name;
//
//        // Points to "images"
//        let images = spaceRef.parent()
//        return images
//    }
    
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
            self.createAnonymousUser()
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
    func createAnonymousUser() {
        if self.keychain.hasValue(forKey: Keys.download_check.key) {
            Authorize.instance.resignAnon(view: self) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                Messaging.messaging().subscribe(toTopic: "000")
                self.startUserLoadChain()
            }
        } else {
            Authorize.instance.signUpAnonymously(view: self) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                Messaging.messaging().subscribe(toTopic: "000")
                self.setUpTutorialWalkthrough()
            }
        }
        
    }
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
        self.walkthrough = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial.id) as! BWWalkthroughViewController
        self.page_one = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_one.id) as! FirstGoldenTutorialViewController
        let page_two = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_two.id) as! BWWalkthroughPageViewController
        let page_three = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_three.id) as! BWWalkthroughPageViewController
        let page_four = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_four.id) as! BWWalkthroughPageViewController
        self.page_five = sub.instantiateViewController(withIdentifier: VCID.golden_tutorial_five.id) as! LastGoldenTutorialViewController
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
        //self.providesPresentationContextTransitionStyle = true
        //self.definesPresentationContext = true
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
                vc.confettiView.startConfetti()
            } else {
                if !self.page_one.confettiView.isActive() {
                    self.page_one.confettiView.startConfetti()
                }
            }
        } else {
            self.walkthrough.prevButton?.isHidden = false
            if self.page_one.confettiView.isActive() {
                self.page_one.confettiView.stopConfetti()
            }
        }
        
    }
    
    func walkthroughNextButtonPressed() {
        print("Swiped")
        if self.walkthrough.currentPage == 0 {
            if let vc = self.walkthrough.currentViewController as? FirstGoldenTutorialViewController {
                if vc.confettiView.isActive() {
                    vc.confettiView.startConfetti()
                }
            } else {
                if !self.page_one.confettiView.isActive() {
                    self.page_one.confettiView.startConfetti()
                }
            }
        } else if self.walkthrough.currentPage == 1 {
            if self.page_one.confettiView.isActive() {
                self.page_one.confettiView.stopConfetti()
            }
        } else if self.walkthrough.currentPage == 4 {
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func walkthroughPrevButtonPressed() {
        if self.walkthrough.currentPage == 0 {
            if let vc = self.walkthrough.currentViewController as? FirstGoldenTutorialViewController {
                vc.confettiView.startConfetti()
            }
        }
    }
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UIViewController {
    func checkInternet() {
        guard InternetConnection.instance.isInternetAvailable() else {
            self.error(title: "No Internet", message: "Golden Action Awards requires internet connection, please make sure you have internet before proceeding", error: nil)
            return
        }
    }
    
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
    func generateTitleView(currentCategory: String) -> UIImage {
        switch currentCategory {
        case FilterStrings.hand_category.id:
            return StaticPictures.titleview_hand.generatePic()
        case FilterStrings.head_category.id:
            return StaticPictures.titleview_head.generatePic()
        case FilterStrings.heart_category.id:
            return StaticPictures.titleview_heart.generatePic()
        case FilterStrings.health_category.id:
            return StaticPictures.titleview_health.generatePic()
        default:
            return StaticPictures.titleview_head.generatePic()
        }
    }
    func generateIcon(currentCategory: String) -> UIImage {
        switch currentCategory {
        case FilterStrings.hand_category.id:
            return StaticPictures.gold_hand.generatePic()
        case FilterStrings.head_category.id:
            return StaticPictures.gold_head.generatePic()
        case FilterStrings.heart_category.id:
            return StaticPictures.gold_heart.generatePic()
        case FilterStrings.health_category.id:
            return StaticPictures.gold_health.generatePic()
        default:
            return StaticPictures.gold_head.generatePic()
        }
    }
    func setBarTint() {
        self.navigationController?.navigationBar.barTintColor = Colors.app_navbar_tint.generateColor()
    }
    func setBarButtonTint() {
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    func checkTutorial() {
        let key = KeychainWrapper.standard
        if !key.hasValue(forKey: Keys.download_check.key) {
            self.performSegue(withIdentifier: SegueId.nomination_tutorialone.id, sender: self)
            //let tutorialVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.tutorial_one.id) as! UINavigationController
            //self.navigationController?.pushViewController(tutorialVC, animated: true)
            //self.present(tutorialVC, animated: true, completion: nil)
        }
    }
    func tabBarButtonEdit(enabled: Bool) {
        let count = [0, 1, 2]
        if enabled {
            for c in count {
                if let items = self.tabBarController?.tabBar.items as Any as? NSArray, let item = items[c] as? UITabBarItem {
                    item.isEnabled = true
                } else {
                    print("Item does not exist!!!")
                }
            }
        } else {
            for c in count {
                if let items = self.tabBarController?.tabBar.items as Any as? NSArray, let item = items[c] as? UITabBarItem {
                    item.isEnabled = false
                } else {
                    print("Item does not exist!!!")
                }
            }
        }
    }
    func tapDismissSearch(searchVC: UISearchController) {
        
    }
    func tapDismiss() {
        //self.providesPresentationContextTransitionStyle = true
        //self.definesPresentationContext = true
        //self.modalPresentationCapturesStatusBarAppearance = false
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        //self.resignFirstResponder()
    }
}

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Float.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    func endRotate() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
}



























