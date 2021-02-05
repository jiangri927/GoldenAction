//
//  CartViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

/*
 
 If self.isVotesSegue == true
 reload tableview with vote option
 else
 reload tableview with nomination option
 
 Note: Same logic is applied on user cell selection
 */


import UIKit
import StoreKit
import Firebase
import NYAlertViewController
import Stripe
import PassKit
import DGActivityIndicatorView

class CartViewController: UIViewController {
    
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    
    // MARK: - Bar Button Declaration
    @IBOutlet weak var backButton: UIBarButtonItem!
    // @IBOutlet weak var couponButton: UIBarButtonItem!
    // MARK: - View Variable Declaration
    @IBOutlet weak var voteTitle: UILabel!
    @IBOutlet weak var numberVotesLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    var price: Int = 0
    
    var selectedRow : Int!
    // Table View
    @IBOutlet weak var tableView: UITableView!
    
    var bundles: [[String : Any]] {
        return [
            ["bundle_num": "Bundle Pack 1", "num_votes": 1,  "price": 0.99],
            ["bundle_num": "Bundle Pack 2", "num_votes": 5,  "price": 3.99],
            ["bundle_num": "Bundle Pack 3", "num_votes": 10, "price": 7.99]
        ]
    }
    
    var cartNomination: [[String : Any]]{
        return [
            ["bundle_num": "1 Nomination", "num_votes": 1,  "price": 1.99],
            ["bundle_num": "Buy 3 get 1 Nomination", "num_votes": 4,  "price": 3.99]
        ]
    }
    
    var payments = [SKProduct]()
    var currentUser: Person!
    var isVotesSegue = true
    
    let selectedButtonColor = Colors.app_text.generateColor()
    let unselectedButtonColor = UIColor.clear
    let tableViewBackgroundColor = Colors.app_tableview_background.generateColor()
    let tableViewSeperatorColor = Colors.app_tableview_seperator.generateColor()
    
    var coupons = [Coupon]()
    var couponsTextField: UITextField!
    var alertStart: NYAlertViewController!
    
    var storeKit = GoldenStoreKit.instance
    var votes = GoldenStoreKit.instance.votes
    var noms = GoldenStoreKit.instance.nominees
    
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    var activityView:DGActivityIndicatorView!
    
    // MARK: - From Alert View
    var fromAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // if fromAlert {
        //     self.setupDownGesture()
        //        self.backButton.reactive.tap.observeNext {
        //            self.dismiss(animated: true, completion: nil)
        //            //self.navigationController?.popViewController(animated: true)
        //        }
        // }
        //        self.loadCurrentUser() { (currentUser, error) in
        //            guard error == nil && currentUser != nil else {
        //                print("Hey error loading current user")
        //                return
        //            }
        //            self.currentUser = currentUser!
        //            print("User Instantiated")
        //        }
        
        /*IAPHandler.shared.fetchAvailableProducts()
         
         IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
         guard let strongSelf = self else{ return }
         if type == .purchased {
         let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
         let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
         
         })
         alertView.addAction(action)
         strongSelf.present(alertView, animated: true, completion: nil)
         }
         } */
        // Table View Setup
        self.setUpTableView(tableView: self.tableView)
        self.designTableView(tableView: self.tableView)
        // Navigation Controller Setup
        self.setUpNav()
        // MARK: - Download Clusters BPlist to Keychain in Check Tutorial
        // Load Packages
        self.setTitleView(votes: self.isVotesSegue)
        self.loadPackages(votes: self.isVotesSegue)
        // self.loadButtonDesign(votes: self.isVotesSegue)
        // Buttons
        // self.setUpButtons()
        self.pullCoupons(isVote: self.isVotesSegue)
        
        
        setupSegmentedControl()
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        self.segmentController.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .selected)
        self.updateGradientBackground()
        
        let colorImage = self.gradient(size: self.voteTitle.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.voteTitle.textColor = UIColor.init(patternImage: colorImage!)
        //self.voteTitle.text = self.titleText
        
        loadIndicatorView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let image2 = self.gradient(size: self.segmentController.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        self.segmentController.layer.borderColor = UIColor.init(patternImage: image2).cgColor
        
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        self.updateGradientBackground()
        if sender.selectedSegmentIndex == 0 {
            
            self.isVotesSegue = true
            //            self.voteButton.backgroundColor = self.selectedButtonColor
            //            self.nomButton.backgroundColor = self.unselectedButtonColor
            //            self.nomButton.setTitleColor(self.selectedButtonColor, for: [])
            //            self.voteButton.setTitleColor(UIColor.black, for: [])
            
            self.loadPackages(votes: self.isVotesSegue)
            self.setTitleView(votes: self.isVotesSegue)
            self.pullCoupons(isVote: self.isVotesSegue)
            
        }else{
            self.isVotesSegue = false
            //            self.nomButton.backgroundColor = self.selectedButtonColor
            //            self.nomButton.setTitleColor(UIColor.black, for: [])
            //            self.voteButton.setTitleColor(self.selectedButtonColor, for: [])
            //            self.voteButton.backgroundColor = self.unselectedButtonColor
            self.loadPackages(votes: self.isVotesSegue)
            self.setTitleView(votes: self.isVotesSegue)
            self.pullCoupons(isVote: self.isVotesSegue)
        }
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        self.segmentController.removeAllSegments()
        self.segmentController.insertSegment(withTitle: "Votes", at: 0, animated: false)
        self.segmentController.insertSegment(withTitle: "Nominations", at: 1, animated: false)
        self.segmentController.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        self.segmentController.layer.borderWidth = 2
        self.segmentController.layer.masksToBounds = true
        self.segmentController.layer.cornerRadius = 8
        self.segmentController.selectedSegmentIndex = 0
        
    }
    
    func updateVoteAndNomValue(totalVote:Int){
        
        print(self.currentUser.uid)
        guard self.currentUser.uid != "N/A" else {
            return
        }
        guard self.currentUser != nil else{
            return
        }
        
        if self.isVotesSegue {
            let remainsVote = self.currentUser.purchasedVotes
            let finalVotePerchased = remainsVote + totalVote
            self.currentUser.purchasedVotes = finalVotePerchased
            let ref = DBRef.user(uid: self.currentUser.uid).reference()
            ref.updateChildValues(["votes":finalVotePerchased])
            self.goldenAlert(title: "Vote purchased!", message: "Congratulation! \(self.currentUser.purchasedVotes) votes has been credited into your account sucessfully.", view: self)
        }else{
            let remainsNom = self.currentUser.purchasedNoms
            let finalNomPerchased          = remainsNom + totalVote
            self.currentUser.purchasedNoms = finalNomPerchased
            let ref = DBRef.user(uid: self.currentUser.uid).reference()
            ref.updateChildValues(["noms":finalNomPerchased])
            self.goldenAlert(title: "Nomination!", message: "Congratulation! \(self.currentUser.purchasedNoms) noms has been credited into your account sucessfully.", view: self)
        }
        self.tabBarController?.selectedIndex = 0
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //Setting current user for voting
    // MARK: - Load Current Person
    func loadCurrentUser(completion: @escaping (Person?, String?) -> Void) {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            self.loadPerson(uid: uid, completion: { (person, error) in
                completion(person, error)
            })
            
        } else {
            //self.createAnonymousUser()
            print("create anonymous user")
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
    
    
    func setUpLastConfirmationCoupon(coupon: Coupon) {
        var acceptItem: DispatchWorkItem!
        if coupon.isNomination {
            acceptItem = DispatchWorkItem {
                let couponRef = DBRef.nomination_coupon(uid: coupon.uid).reference()
                let ref = DBRef.user(uid: self.currentUser.uid).reference()
                ref.updateChildValues(["noms" : coupon.discount])
                couponRef.updateChildValues(["isUsed" : true])
                self.currentUser.purchasedNoms += coupon.discount
                self.setTitleView(votes: false)
                self.alertStart.dismiss(animated: true, completion: nil)
            }
        } else {
            acceptItem = DispatchWorkItem {
                let couponRef = DBRef.votes_coupon(uid: coupon.uid).reference()
                let ref = DBRef.user(uid: self.currentUser.uid).reference()
                ref.updateChildValues(["votes" : coupon.discount])
                couponRef.updateChildValues(["isUsed" : true])
                self.currentUser.purchasedVotes += coupon.discount
                self.setTitleView(votes: true)
                self.alertStart.dismiss(animated: true, completion: nil)
            }
        }
        let cancelAction = DispatchWorkItem {
            self.alertStart.dismiss(animated: true, completion: nil)
        }
        var couponTitle: String!
        if coupon.isNomination {
            couponTitle = "Nomination"
        } else {
            couponTitle = "Votes"
        }
        self.alertStart = self.goldenCustomActions(vc: self, title: "\(couponTitle!) Coupon Found", message: "\(coupon.dealDescription)", buttonOneTitle: "Accept", buttonTwoTitle: "Cancel", buttonOneAction: acceptItem, buttonTwoAction: cancelAction, buttonThreeAction: nil, buttonThreeTitle: nil, twoAction: true, threeAction: false)
        self.present(alertStart, animated: true, completion: nil)
    }
    @objc func setUpCouponAlert(_ sender: UIBarButtonItem!) {
        var isVot: Bool!
        let nextAlert = DispatchWorkItem {
            self.alertStart.dismiss(animated: true, completion: nil)
            self.textFieldCustomAction(vc: self, title: "Enter the code below", isVote: isVot)
        }
        let votesItem = DispatchWorkItem {
            isVot = true
            self.pullCoupons(isVote: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: nextAlert)
        }
        let nominationsItem = DispatchWorkItem {
            isVot = false
            self.pullCoupons(isVote: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25), execute: nextAlert)
        }
        self.alertStart = self.goldenCustomActions(vc: self, title: "Type of Coupon", message: "", buttonOneTitle: "Votes", buttonTwoTitle: "Nominations", buttonOneAction: votesItem, buttonTwoAction: nominationsItem, buttonThreeAction: nil, buttonThreeTitle: nil, twoAction: true, threeAction: false)
        self.present(self.alertStart, animated: true, completion: nil)
    }
    func textFieldCustomAction(vc: UIViewController, title: String, isVote: Bool) {
        let alertVC = NYAlertViewController()
        self.designAlertView(alertVC: alertVC)
        alertVC.title = title
        alertVC.message = nil
        
        alertVC.addTextField { (textField) in
            self.couponsTextField = textField
            self.couponsTextField.attributedPlaceholder = LoginStrings.forgot_password.generateString(text: "Enter coupon code")
            self.couponsTextField.borderStyle = .roundedRect
            self.couponsTextField.layer.cornerRadius = 10.0
            self.couponsTextField.layer.masksToBounds = true
            self.couponsTextField.becomeFirstResponder()
        }
        
        let okayAction = NYAlertAction(title: "Submit", style: .default) { (_) in
            guard self.couponsTextField.text != "" else {
                self.goldenAlert(title: "Please enter a coupon code.", message: "", view: self)
                return
            }
            let couponCheck = Coupon(uid: self.couponsTextField.text!, dealDescription: "", isNomination: false, discount: 0, isUsed: false)
            //            print(self.coupons.count)
            //            print(self.coupons[0].toDictionary())
            if let index = self.coupons.index(of: couponCheck) {
                let selected = self.coupons[index]
                alertVC.dismiss(animated: true, completion: nil)
                self.setUpLastConfirmationCoupon(coupon: selected)
            } else {
                alertVC.dismiss(animated: true, completion: nil)
                self.goldenAlert(title: "There is no coupon associated with this code.", message: "", view: self)
            }
            
        }
        let cancelAction = NYAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(okayAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    func pullCoupons(isVote: Bool) {
        Coupon.loadCoupons(isVote: (isVote)) { (coup) in
            self.coupons = coup.filter { $0.isUsed == false }
        }
    }
    
    // MARK: - Navigation Controller Setup
    func setUpNav() {
        // Navigation Bar Color
        self.navigationController?.isNavigationBarHidden = false
        self.setBarTint()
        self.setBarButtonTint()
        self.view.backgroundColor = self.tableViewBackgroundColor
        //        self.couponButton.target = self
        //        self.couponButton.action = #selector(setUpCouponAlert(_:))
        
        
    }
    //    func setUpButtons() {
    //
    //        self.voteButton.addTarget(self, action: #selector(voteDidTap(_:)), for: .touchUpInside)
    //        self.nomButton.addTarget(self, action: #selector(nomDidTap(_:)), for: .touchUpInside)
    //        self.voteButton.layer.cornerRadius = 10.0
    //        self.voteButton.layer.borderColor = self.selectedButtonColor.cgColor
    //        self.nomButton.layer.borderColor = self.selectedButtonColor.cgColor
    //        self.voteButton.layer.borderWidth = 1.0
    //        self.nomButton.layer.borderWidth = 1.0
    //        self.nomButton.layer.cornerRadius = 10.0
    //        self.voteButton.layer.masksToBounds = false
    //        self.nomButton.layer.masksToBounds = false
    //
    //
    //    }
    //    func loadButtonDesign(votes: Bool) {
    //        if votes {
    //            self.voteButton.backgroundColor = self.selectedButtonColor
    //            self.nomButton.backgroundColor = self.unselectedButtonColor
    //            self.voteButton.setTitleColor(UIColor.black, for: [])
    //            self.nomButton.setTitleColor(self.selectedButtonColor, for: [])
    //        } else {
    //            self.nomButton.backgroundColor = self.selectedButtonColor
    //            self.nomButton.setTitleColor(UIColor.black, for: [])
    //            self.voteButton.setTitleColor(self.selectedButtonColor, for: [])
    //            self.voteButton.backgroundColor = self.unselectedButtonColor
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func voteDidTap(_ sender: UIButton!) {
        //            if !(self.voteButton.backgroundColor == self.selectedButtonColor) {
        //                self.isVotesSegue = true
        //                self.voteButton.backgroundColor = self.selectedButtonColor
        //                self.nomButton.backgroundColor = self.unselectedButtonColor
        //                self.nomButton.setTitleColor(self.selectedButtonColor, for: [])
        //                self.voteButton.setTitleColor(UIColor.black, for: [])
        //                self.loadPackages(votes: self.isVotesSegue)
        //                self.setTitleView(votes: self.isVotesSegue)
        //                self.pullCoupons(isVote: self.isVotesSegue)
        //            }
    }
    //    @objc func nomDidTap(_ sender: UIButton!) {
    //        if !(self.nomButton.backgroundColor == self.selectedButtonColor) {
    //            self.isVotesSegue = false
    //            self.nomButton.backgroundColor = self.selectedButtonColor
    //            self.nomButton.setTitleColor(UIColor.black, for: [])
    //            self.voteButton.setTitleColor(self.selectedButtonColor, for: [])
    //            self.voteButton.backgroundColor = self.unselectedButtonColor
    //            self.loadPackages(votes: self.isVotesSegue)
    //            self.setTitleView(votes: self.isVotesSegue)
    //            self.pullCoupons(isVote: self.isVotesSegue)
    //        }
    //    }
    @IBAction func backDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func couponDidTap(_ sender: Any) {
    }
    func setTitleView(votes: Bool) {
        if votes {
            self.voteTitle.text = "VOTE SHOP"
            self.numberVotesLabel.text = "Votes in Vault: \(self.currentUser!.purchasedVotes)"
        } else {
            self.voteTitle.text = "NOMINATION SHOP"
            self.numberVotesLabel.text = "Nominations in Vault: \(self.currentUser.purchasedNoms)"
            
        }
        self.tableView.reloadData()
    }
}


extension CartViewController: UITableViewDataSource, UITableViewDelegate
{
    func loadPackages(votes: Bool) {
        self.payments = []
        let keys: Set<String>!
        if votes {
            keys = self.votes
        } else {
            keys = self.noms
        }
        print(keys)
        // let test: Set<String> = ["com.stackonapp.The-Golden-Action-Awards-Beta.Nom-Pack-One"]
        NetworkActivity.operationsStarted()
        GoldenStoreKit.instance.retrievePrices(prods: keys) { (products, error) in
            print("Pulled")
            NetworkActivity.operationsEnded()
            guard error == nil else {
                self.goldenAlert(title: "Error", message: "There was an issue in loading products, please check your internet and try again.", view: self)
                return
            }
            for prod in products {
                print(prod)
                self.payments.append(prod)
            }
            self.tableView.reloadData()
        }
        /* PaymentPlans.store.requestProducts { (success, products) in
         if success {
         for prod in products! {
         if prod.localizedDescription.contains(id) {
         self.payments.append(prod)
         } else {
         self.payments.append(prod)
         }
         }
         self.payments = products!
         self.tableView.reloadData()
         
         } else {
         self.goldenAlert(title: "Error", message: "There was an issue loading products, please check your internet and try again", view: self)
         }
         } */
    }
    func setUpTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isVotesSegue {
            return self.bundles.count
        }else{
            return self.cartNomination.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.checkout_cell.id, for: indexPath) as! CheckoutTableViewCell
        
        if self.isVotesSegue {
            let plan = self.bundles[indexPath.row]
            cell.configureCell(voteBundle: plan)
            cell.isVoteSegue = true
        }else{
            let plan = self.cartNomination[indexPath.row]
            cell.configureCell1(voteBundle: plan)
            cell.isVoteSegue = false
        }
        
        // Gesture for tapping on image to go to detail
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSegue(recognizer:)))
        cell.addGestureRecognizer(gestureRecognizer)
        //        cell.priceLabel.setGradiantColor()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.bundles.count {
            return 100.0
        } else {
            return 100.0
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.bundles.count {
            return 100.0
        } else {
            return 100.0
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = self.tableViewBackgroundColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Segue to Detail Gesture Recognizer
    @objc func tapSegue(recognizer: UITapGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            print("Sup Recognized")
            let tapCell = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: tapCell) {
                selectedRow = indexPath.row
                //                if let tapCell = self.tableView.cellForRow(at: indexPath) as? NomineesTableViewCell {
                //
                //                }
                
                
                print("tap on vote call")
                //                let config = STPPaymentConfiguration()
                //                config.requiredBillingAddressFields = .full
                //                let viewController = STPAddCardViewController(configuration: config, theme: STPTheme.default())
                //                viewController.delegate = self
                //                let navigationController = UINavigationController(rootViewController: viewController)
                //                present(navigationController, animated: true, completion: nil)
                
                
                let plan = isVotesSegue == true ? self.bundles[indexPath.row] : self.cartNomination[indexPath.row]
                
                print(plan["price"] ?? "0")
                
                let request = PKPaymentRequest()
                request.merchantIdentifier = "merchant.golden-action-awards"
                request.supportedNetworks = SupportedPaymentNetworks
                request.merchantCapabilities = PKMerchantCapability.capability3DS
                request.countryCode = "US"
                request.currencyCode = "USD"
                
                let number = NSDecimalNumber(string: "\(plan["price"] ?? "0")")
                print(number) // 80
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 2
                self.price = Int(number.doubleValue * 100)
                //let string = formatter.string(from: number)
                
                request.paymentSummaryItems = [
                    PKPaymentSummaryItem(label: plan["bundle_num"] as? String ?? "", amount: number)
                ]
                
                let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
                applePayController?.delegate = self
                if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedPaymentNetworks) {
                    
                    self.present(applePayController!, animated: true, completion: nil)
                }
                else {
                    let alertController = UIAlertController(
                        title: "The settlement method is not registered",
                        message: "Would you like to register payment method now",
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { action in
                        if #available(iOS 8.3, *) {
                            PKPassLibrary().openPaymentSetup()
                        }
                    }))
                    alertController.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                
                
                
                //                let merchantIdentifier = "merchant.golden-action-awards"
                //                let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "US", currency: "USD")
                //
                //                // Configure the line items on the payment request
                //                paymentRequest.paymentSummaryItems = [
                //                    PKPaymentSummaryItem(label: "Fancy Hat", amount: 50.00),
                //                    // The final line should represent your company;
                //                    // it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
                //                    PKPaymentSummaryItem(label: "iHats, Inc", amount: 50.00),
                //                ]
                //
                //
                //                if Stripe.canSubmitPaymentRequest(paymentRequest) {
                //                    // Setup payment authorization view controller
                //                    let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                //                    paymentAuthorizationViewController?.delegate = self
                //
                //                    // Present payment authorization view controller
                //                    present(paymentAuthorizationViewController!, animated: true)
                //                }
                //                else {
                //                    // There is a problem with your Apple Pay configuration
                //                }
                
                
                
                //                if self.isVotesSegue {
                //                    let plan = self.bundles[indexPath.row]
                //                    let numVotes   = plan["num_votes"] as! Int
                //                    updateVoteAndNomValue(totalVote: numVotes)
                //                }else{
                //                    let plan = self.cartNomination[indexPath.row]
                //                    let numVotes   = plan["num_votes"] as! Int
                //                    updateVoteAndNomValue(totalVote: numVotes)
                //                }
                
                
                
                
            }
        }
    }
    
    public var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            if #available(iOS 10.0, *) {
                return PKPaymentRequest.availableNetworks()
            } else {
                return [.visa, .masterCard, .amex]
            }
        }
    }
    
}



extension CartViewController
{
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



extension CartViewController : STPAddCardViewControllerDelegate{
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        print(token)
    }
}

extension CartViewController :  PKPaymentAuthorizationViewControllerDelegate
{
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        activityView.startAnimating()
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            
            if let _ = error {
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                }
                // Present error to user...
                print(token?.tokenId ?? "")
                // Notify payment authorization view controller
                completion(.failure)
            }
            else {
                Payment.createCharge(token!.tokenId, self.price, completion: { (errMsg) in
                    DispatchQueue.main.async {
                        self.activityView.stopAnimating()
                        if errMsg == nil {
                            //                            let param:[String:Any] = ["":""]
                            //                            let rootR = Database.database().reference()
                            //                            let childID = rootR.childByAutoId().key!
                            //                            rootR.child("Tracking").child(childID).setValue(param)
                            
                            if self.isVotesSegue {
                                let plan = self.bundles[self.selectedRow]
                                let numVotes   = plan["num_votes"] as! Int
                                self.updateVoteAndNomValue(totalVote: numVotes)
                            }else{
                                let plan = self.cartNomination[self.selectedRow]
                                let numVotes   = plan["num_votes"] as! Int
                                self.updateVoteAndNomValue(totalVote: numVotes)
                            }
                            
                            
                            let alertController = UIAlertController(
                                title: "Success!",
                                message: "Payment completed",
                                preferredStyle: .alert
                            )
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
                            let alertController = UIAlertController(
                                title: "Oops!",
                                message: errMsg!,
                                preferredStyle: .alert
                            )
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
                
                completion(.success)
                
                
            }
        }
        
    }
}

