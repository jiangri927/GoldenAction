//
//  ProfileTableViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SearchTextField
import Toucan
import Firebase
import DGActivityIndicatorView
import FirebaseStorage
import FirebaseAuth


class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var voteView: UIView!
    @IBOutlet weak var nomView : UIView!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    
    @IBOutlet weak var votesLabel: UITextField!
    
    @IBOutlet weak var nomLabel: UITextField!
    @IBOutlet weak var votesButton: UIButton!
    @IBOutlet weak var nominationsButton: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var location: SearchTextField!
    
    @IBOutlet weak var yourNomsView: UICollectionView!
    @IBOutlet weak var yourVotesView: UICollectionView!
    @IBOutlet weak var yourGoldenActions: UICollectionView!
    
    @IBOutlet weak var adminButton: UIButton!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var saveChanges: UIButton!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    var activityView:DGActivityIndicatorView!

    
    var currentUser: Person!
    var currentVotes = [Votes]()
    var currentNoms = [UserNominations]()
    var goldenActions = [UserNominee]()
    
    var searches = [SearchTextFieldItem]()
    var selectedItem: SearchTextFieldItem!
    var needsUpdated: Bool = false
    
    var admin: Bool!
    var owner: Bool!
    
    var isVotesSegue: Bool!
    
    //Used to checking, is this calling from user list
    var isOtherUserProfile:Bool = false
    var activityIndicator : UIActivityIndicatorView!
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadIndicatorView()
        self.loadCurrentUser(completion: { (person,error) in
            
            if !self.isOtherUserProfile {
                self.currentUser = person
            }
            
            self.setupUserProfile()
            self.setupLocationField()
            self.fetchYourNoms()
            self.fetchYourVotes()
            self.fetchYourGoldenActions()
//            self.configureProfilePicture()

        })
        self.tapDismiss()
        //self.view.backgroundColor = Colors.black.generateColor()
        //self.designProfileInputs(outer: self.outerView, inner: self.innerView)
        self.designButton()
        self.setupFields(field: self.emailField)
        self.setupFields(field: self.nameField)
        
        self.profilePicture.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.profilePicture.addGestureRecognizer(tap)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.configureProfilePicture()
    }
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
       // self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        activityView.startAnimating()
    }
    
    func configureProfilePicture()
    {
        self.profilePicture.layer.masksToBounds = false
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.height/2
        self.profilePicture.clipsToBounds = true
        
        guard self.currentUser != nil else {
            return
        }
        
        
        if self.currentUser?.profilePictureURL != nil{
            let imageUrl = self.currentUser.profilePictureURL
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"

            let storageRef = Storage.storage().reference(forURL: completeUrl)
           // profilePicture.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "profileicon"))
                self.activityView.stopAnimating()
            
            storageRef.downloadURL(completion: { (url, error) in
                guard url != nil else
                {
                    return
                }
                do
                {
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    
                    self.profilePicture.image = image
                }
                catch
                {
                    print(error)
                }
            })
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
            //sud
            //self.createAnonymousUser()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func designProfileInputs(outer: UIView, inner: UIView) {
        // Outer
        outer.backgroundColor = Colors.nom_detail_outerBackground.generateColor()
        outer.layer.cornerRadius = 15.0
        outer.layer.masksToBounds = true
        // Inner
        inner.backgroundColor = Colors.nom_detail_innerBackground.generateColor()
        inner.layer.borderColor = Colors.nom_detail_innerBorder.generateColor().cgColor
        inner.layer.borderWidth = 1.0
        inner.layer.cornerRadius = 15.0
        inner.layer.masksToBounds = true
    }
    func setupFields(field: UITextField) {
        field.borderStyle = .none
       // field.textColor = Colors.app_text.generateColor()
        
    }
    func setupLocationField() {
        
        guard self.currentUser != nil else{
            return
        }
        self.location.borderStyle = .none
//        self.location.theme.bgColor = UIColor.black
//        self.location.theme.font = Fonts.hira_pro_three.generateFont(size: 14.0)
//        self.location.theme.fontColor = Colors.app_text.generateColor()
//        self.location.textColor = Colors.app_text.generateColor()
//        self.location.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: self.currentUser.cityState)
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.location.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title), \(item.subtitle!)")
            self.selectedItem = item
            self.resignFirstResponder()
        }
        self.location.itemSelectionHandler = closure
    }
    
    func designButton() {
        self.votesLabel.layer.cornerRadius = 10.0
        self.nomLabel.layer.cornerRadius = 10.0
        self.votesLabel.layer.masksToBounds = true
        self.nomLabel.layer.masksToBounds = true
        
        self.changePassword.layer.cornerRadius = 10.0
        self.changePassword.layer.masksToBounds = true
        self.saveChanges.layer.cornerRadius = 10.0
        self.saveChanges.layer.masksToBounds = true
    }
    
    
    func setupUserProfile() {
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        guard self.currentUser != nil else{
        return
        }
        
        self.nameField.text  = self.currentUser.fullName
        self.emailField.text = self.currentUser.email
        self.location.text   = self.currentUser.cityState
        
       // if self.admin == nil {
            self.userProfileDetails()
            //self.setAdminButton()
       /* } else {
            //self.votesButton.setTitle("Set Address", for: [])
            self.nominationsButton.isHidden = true
            self.adminButton.setTitle("Admin Access", for: [])
        }*/
        
        
        self.changePassword.addTarget(self, action: #selector(passwordChangeDidTap(_:)), for: .touchUpInside)
        //self.adminButton.addTarget(self, action: #selector(adminDidTap(_:)), for: .touchUpInside)
        self.saveChanges.addTarget(self, action: #selector(saveChanges(_:)), for: .touchUpInside)
    }
    
    func userProfileDetails() {
        
//        let voteGesture = UITapGestureRecognizer(target: self, action: #selector(voteDidTap(recognizer:)))
//        let nomGesture = UITapGestureRecognizer(target: self, action: #selector(nominationDidTap(recognizer:)))

        if self.currentUser.purchasedVotes == 0 {
            self.votesLabel.text = "+"
        } else {
            self.votesLabel.text = "\(self.currentUser.purchasedVotes)"
        }
        if self.currentUser.purchasedNoms == 0 {
            self.nomLabel.text = ""
        } else {
            self.nomLabel.text = "\(self.currentUser.purchasedNoms)"
        }
        //self.votesButton.addTarget(self, action: #selector(votesDidTap(_:)), for: .touchUpInside)
       // self.nominationsButton.addTarget(self, action: #selector(nominationsDidTap(_:)), for: .touchUpInside)
        
//        self.voteView.addGestureRecognizer(voteGesture)
//        self.nomView.addGestureRecognizer(nomGesture)
    }
    
    @objc func voteDidTap(recognizer: UITapGestureRecognizer) {
        self.isVotesSegue = true
        self.performSegue(withIdentifier: SegueId.profile_checkout.id, sender: self)
    }
    
    @IBAction func voteAction(_ sender: UIButton) {
        self.isVotesSegue = true
        self.performSegue(withIdentifier: SegueId.profile_checkout.id, sender: self)
    }
    
    
    @IBAction func nominationAction(_ sender: UIButton) {
        self.isVotesSegue = false
        self.performSegue(withIdentifier: SegueId.profile_checkout.id, sender: self)
    }
    
    
    @objc func nominationDidTap(recognizer: UITapGestureRecognizer) {
        self.isVotesSegue = false
        self.performSegue(withIdentifier: SegueId.profile_checkout.id, sender: self)
    }
    
    @IBAction func votesEditingEnd(_ sender: UITextField) {
        let votesStr = self.votesLabel.text ?? "0"
        self.currentUser.purchasedVotes = (votesStr as NSString).integerValue
        let userRef = DBRef.user(uid: self.currentUser.uid).reference()
        let dict: [String: Any] = ["votes": self.currentUser.purchasedVotes]
        userRef.updateChildValues(dict)
    }
    
    @IBAction func nomEditingEnd(_ sender: UITextField) {
        let nomStr = self.nomLabel.text ?? "0"
        self.currentUser.purchasedNoms = (nomStr as NSString).integerValue
        let dict: [String: Any] = ["noms": self.currentUser.purchasedNoms]
        let userRef = DBRef.user(uid: self.currentUser.uid).reference()
        userRef.updateChildValues(dict)
    }
    

    
    func setAdminButton() {
       /* if self.currentUser.adminStage == AdminStatus.not_accepted.status {
            AdminStatus.not_accepted.setProfileButton(selector: self.getAwaitingApproval(), button: self.adminButton)
        } else if self.currentUser.adminStage == AdminStatus.accepted_initial.status {
            AdminStatus.accepted_initial.setProfileButton(selector: self.getInitialApproval(), button: self.adminButton)
        } else if self.currentUser.adminStage == AdminStatus.accepted_final.status { */
            AdminStatus.not_accepted.setProfileButton(selector: self.getFinalApproval(), button: self.adminButton)
       /* } else if self.currentUser.adminStage == AdminStatus.denied.status {
            AdminStatus.not_accepted.setProfileButton(selector: self.getDeniedApproval(), button: self.adminButton)
        } else {
            AdminStatus.not_accepted.setProfileButton(selector: self.getNoneApproval(), button: self.adminButton)
        } */
    }
    
    func getAwaitingApproval() -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            self.goldenAlert(title: "Awaiting Approval", message: "We have not gotten a chance to look at your application, check back in a few days!", view: self)
        }
        return workItem
    }
    func getInitialApproval() -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            self.performSegue(withIdentifier: SegueId.profile_admin.id, sender: self) // Edit this when tutorial is done
        }
        return workItem
    }
    func getFinalApproval() -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            self.performSegue(withIdentifier: SegueId.profile_admin.id, sender: self)
        }
        return workItem
    }
    func getDeniedApproval() -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            self.goldenAlert(title: "Denied", message: "We apologize, but we could not accept your application if you would like to find out why contact us via our website at goldenactionawards.com", view: self)
        }
        return workItem
    }
    func getNoneApproval() -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            let adminInfo = self.storyboard?.instantiateViewController(withIdentifier: VCID.sponsor_info.id) as! AdminInfoViewController
            adminInfo.returningUser = true
            adminInfo.currentUser = self.currentUser
            let navVC = UINavigationController(rootViewController: adminInfo)
            navVC.setNavigationBarHidden(true, animated: false)
            // self.navigationController?.pushViewController(adminInfo, animated: true)
            self.present(navVC, animated: true, completion: nil)
        }
        return workItem
    }
    @objc func votesDidTap(_ sender: UIButton!) {
        self.isVotesSegue = true
        self.performSegue(withIdentifier: SegueId.profile_checkout.id, sender: self)
    }
    @objc func nominationsDidTap(_ sender: UIButton!) {
        self.isVotesSegue = false
        self.performSegue(withIdentifier: SegueId.profile_checkout.id, sender: self)
    }
    @IBAction func locationTyping(_ sender: Any) {
        self.location.showLoadingIndicator()
       /* SearchAlg.instance.loadCityQuery(query: self.location.text!) { (searches) in
            guard searches != nil else {
                return
            }
            self.searches = searches!
            self.location.filterItems(searches!)
            self.location.startSuggestingInmediately = true
            self.location.stopLoadingIndicator()
        } */
    }
    @objc func adminLogin(_ sender: UIButton!) {
        
    }
    // MARK: - Table view data source
    @objc func adminDidTap(_ sender: UIButton!) {
        /*let adminHome = self.storyboard?.instantiateViewController(withIdentifier: VCID.admin_users.id) as! AdminUsersViewController
        self.navigationController?.pushViewController(adminHome, animated: false) */
        if  self.currentUser.adminStage == AdminStatus.accepted_final.status {
            self.performSegue(withIdentifier: SegueId.profile_admin.id, sender: self)
        } else {
            //let adminLogin = self.storyboard?.instantiateViewController(withIdentifier: VCID.admin_welcome.id) as! WelcomeAdminViewController
            //self.present(adminLogin, animated: true, completion: nil)
            let adminInfo = self.storyboard?.instantiateViewController(withIdentifier: VCID.sponsor_info.id) as! AdminInfoViewController
            adminInfo.returningUser = true
            adminInfo.currentUser = self.currentUser
            let navVC = UINavigationController(rootViewController: adminInfo)
            navVC.setNavigationBarHidden(true, animated: false)
            // self.navigationController?.pushViewController(adminInfo, animated: true)
            self.present(navVC, animated: true, completion: nil)
            /*let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.welcome_screen.id) as! WelcomeViewController
            let navVC = UINavigationController(rootViewController: welcomeVC)
            navVC.setNavigationBarHidden(true, animated: false)
            self.present(navVC, animated: true, completion: nil) */
        }
    }
    
    @objc func passwordChangeDidTap(_ sender: UIButton!) {
        guard self.currentUser.acctType == AcctType.email.type else {
            self.goldenAlert(title: "You did not sign up with an email account", message: "", view: self)
            return
        }
        //ProfilePopup.instance.displayEditPassword(view: self, confirmOld: true, email: self.currentUser.email)
        ProfilePopup.instance.editUserPassword(view:self ,confirmOld: true, email: self.currentUser.email)
    }
    
    @objc func saveChanges(_ sender: UIButton!) {

//        var dict = [String : Any]()
//        if self.currentUser.email != self.emailField.text && self.emailField.text != "" {
//            guard RegexChecker.email(text: self.emailField.text!).check() else {
//                self.goldenAlert(title: "Error", message: "Please enter a valid email address", view: self)
//                return
//            }
//            dict["email"] = self.emailField.text!
//            self.needsUpdated = true
//        }
//        if self.currentUser.fullName != self.nameField.text && self.nameField.text != "" {
//            dict["fullName"] = self.nameField.text!
//            self.currentUser.fullName = self.nameField.text!
//            self.needsUpdated = true
//        }
//        if self.location.text != "" {
//            guard self.selectedItem != nil else {
//                self.goldenAlert(title: "Error", message: "If you would like to change your location, please choose a location from the dropdown", view: self)
//                return
//            }
//            let cityState = "\(self.selectedItem.title), \(self.selectedItem.subtitle!)"
//            if self.currentUser.cityState != cityState {
//                dict["cityState"] = cityState
//                self.currentUser.region = cityState
//                self.needsUpdated = true
//                if self.currentUser.region != self.selectedItem.cluster! {
//                    dict["region"] = self.selectedItem.cluster!
//                    self.currentUser.region = self.selectedItem.cluster!
//                }
//            }
//        }
//        if dict["email"] != nil {
//            Auth.auth().currentUser?.updateEmail(to: self.emailField.text!, completion: { (error) in
//                guard error == nil else {
//                    self.goldenAlert(title: "Error", message: error!.localizedDescription, view: self)
//                    return
//                }
//                self.currentUser.email = self.emailField.text!
//                self.updateUser(dict: dict)
//            })
//        } else {
//            self.updateUser(dict: dict)
//        }
        
        
        
        
        let yourProfile: SignupDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "SignupDetailViewController") as! SignupDetailViewController
        
//        yourProfile.password = self.passwordTextField.text
//        yourProfile.email = self.emailTextField.text
        yourProfile.acctType = "email"
        yourProfile.admin = false
        yourProfile.isEditProfile = true
        yourProfile.adminDescription = "No admin description"
        yourProfile.adminAddress = "No address"
        yourProfile.currentUser = currentUser
        self.navigationController?.pushViewController(yourProfile, animated: true)
    }
    
    
    func updateUser(dict: [String : Any]) {
        if self.needsUpdated {
            let userRef = DBRef.user(uid: self.currentUser.uid).reference()
           // let userAlgoliaRef = AlgoliaRef.users.reference()
            let adminRef = DBRef.admin(uid: self.currentUser.uid).reference()
           // let adminAlgoliaRef = AlgoliaRef.admin.reference()
            
            userRef.updateChildValues(dict)
//            userAlgoliaRef.partialUpdateObject(self.currentUser.toDictionary(), withID: self.currentUser.uid, createIfNotExists: true, requestOptions: nil, completionHandler: { (person, error) in
//                guard error == nil && person != nil else {
//                    print(error!.localizedDescription)
//                    return
//                }
            
               // print(person!)
                if self.currentUser.admin {
                    adminRef.updateChildValues(dict)
                    /*adminAlgoliaRef.partialUpdateObject(self.currentUser.toDictionary(), withID: self.currentUser.uid, createIfNotExists: true, requestOptions: nil, completionHandler: { (admin, error) in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        guard admin != nil else {
                            print("Admin is nil on Update User")
                            return
                        }
                        print(admin!)
                        
                    }) */
                }
           // })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

 
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.app_tableview_background.generateColor()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == SegueId.profile_admin.id {
             let destinationVC = segue.destination as! AdminTabViewController
            
        } else if segue.identifier == SegueId.profile_notifications.id {
            let destinationVC = segue.destination as! NotificationViewController
            destinationVC.currentUser = self.currentUser
            if self.admin {
                destinationVC.admin = true
            } else {
                destinationVC.admin = false
            }
            
        } else if segue.identifier == SegueId.profile_checkout.id {
            let destinationVC = segue.destination as! CartViewController
            destinationVC.currentUser = self.currentUser
            destinationVC.isVotesSegue = self.isVotesSegue
            
        }
    }
    
    @IBAction func backDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ProfileTableViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func designCollection(collectionView: UICollectionView) {
        collectionView.backgroundColor = UIColor.black
        collectionView.layer.borderColor = Colors.app_text.generateColor().cgColor
        collectionView.layer.borderWidth = 1.0
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func fetchYourNoms() {
        self.currentNoms = []
        UserNominations.fetch(uid: self.currentUser.uid) { (userNoms) in
            self.currentNoms = userNoms
           // self.yourNomsView.reloadData()
        }
    }
    func fetchYourGoldenActions() {
        self.goldenActions = []
        UserNominee.fetch(phone: self.currentUser.phone) { (goldenActions)  in
            self.goldenActions = goldenActions
           // self.yourGoldenActions.reloadData()
        }
    }
    func fetchYourVotes() {
        self.currentVotes = []
        Votes.observeVotes(uid: self.currentUser.uid) { (votes) in
            self.currentVotes = votes
           // self.yourVotesView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.yourVotesView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.user_votes_cell.id, for: indexPath) as! UserVotesCollectionViewCell
            let vote = self.currentVotes[indexPath.row]
            cell.configureCell(votes: vote)
            //cell.categoryImage = self.generateTitleView(currentCategory: vote.category)
            // Put above in if pic loads too slow
            return cell
        } else if self.yourNomsView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.user_noms_cell.id, for: indexPath) as! UserNomsCollectionViewCell
            let nom = self.currentNoms[indexPath.row]
            cell.categoryIcon = self.generateIcon(currentCategory: nom.category)
            cell.configureCell(nom: nom)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.user_golden_cell.id, for: indexPath) as! UserGoldenCollectionViewCell
            let golden = self.goldenActions[indexPath.row]
            cell.categoryPicture = self.generateIcon(currentCategory: golden.category)
            cell.configureCell(nom: golden)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.yourVotesView == collectionView {
            return self.currentVotes.count
        } else if self.yourNomsView == collectionView {
            return self.currentNoms.count
        } else {
            return self.goldenActions.count
        }
    }
}


extension ProfileTableViewController {
    
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
    
}
