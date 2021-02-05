//
//  NomDetailTableViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Toucan
import SwiftPhotoGallery
import NYAlertViewController
import Firebase
import DGActivityIndicatorView
import FacebookShare
import TwitterKit
import DropDown
import Lottie
import FirebaseUI
import RAMAnimatedTabBarController

class NomDetailTableViewController: UITableViewController, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    
     var voteUIPopup = UINib(nibName: "ViewVotePopup", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ViewVotePopup
    
    
    @IBOutlet weak var viewPendingNominenationbuttons: UIView!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnApprove: UIButton!
    
    @IBOutlet weak var donatedLabel: UILabel!
    
    
    // MARK: - Outlet Declaration
    @IBOutlet weak var backButton  : UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var fbActionButton: UIBarButtonItem!
    
    // Start Content Declaration
    @IBOutlet weak var nomineePic : UIImageView!
    @IBOutlet weak var nomineeName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var pendingAward: UILabel!
    @IBOutlet weak var nominatedBy: UILabel!
    // Number of Votes
    @IBOutlet weak var numberVotesButton: UIButton!
    
    // Vote
    @IBOutlet weak var voteButton: UIButton!
    
    @IBOutlet weak var timeRemaining: UILabel!
    // Photos
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var photosCollection: UICollectionView!
    // Achievments
    @IBOutlet weak var achievmentsLabel: UILabel!
    @IBOutlet weak var achievmentsSummary: UITextView!
    // Design
    @IBOutlet weak var viewLine: UIView!
    
    @IBOutlet weak var charityTitleLbl: UILabel!
    @IBOutlet weak var charityDetails: UITextView!
    
    //    @IBOutlet weak var approvedButton:UIBarButtonItem!
    //    @IBOutlet weak var rejectButton:UIBarButtonItem!
    
    @IBOutlet weak var tierLbl:UILabel!
    @IBOutlet weak var tierDetails:UILabel!
    
    var isOpenFromAdmin = false
    var shareActionDropDown:DropDown!
    
    var nomination: Nominations!
    
    var notificationType: Int?
    var currentUser: Person?
    var samplePics = [UIImage]()
    
    var admin: Bool!
    var activityView:DGActivityIndicatorView!
    var isFirstTime: Bool!
    
    var voteCount : Int = 0
    
    func designPopup()
    {
        voteUIPopup.btnSubmit.layer.cornerRadius = 3.0
        voteUIPopup.btnSubmit.layer.cornerRadius = 3.0
        voteUIPopup.btnSubmit.layer.masksToBounds = true
        let imageColor = self.gradient(size: voteUIPopup.btnSubmit.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        voteUIPopup.btnSubmit.backgroundColor     = UIColor.init(patternImage: imageColor!)
        
        
        voteUIPopup.viewPopup.layer.borderWidth = 1
        voteUIPopup.viewPopup.layer.borderColor = UIColor.lightGray.cgColor
        
        voteUIPopup.btnSubmit.addTarget(self, action: #selector(voteUIPopupSubmitAction(_:)), for: .touchUpInside)
        
        voteUIPopup.btnPlus.tag = 0
        voteUIPopup.btnMinus.tag = 1
        
        voteUIPopup.btnPlus.addTarget(self, action: #selector(countIncreseOrDecrese(_:)), for: .touchUpInside)
        
        voteUIPopup.btnMinus.addTarget(self, action: #selector(countIncreseOrDecrese(_:)), for: .touchUpInside)
    }
    
    @objc func voteUIPopupSubmitAction(_ sender: UIButton!) {
        voteUIPopup.removeFromSuperview()
       
        if(voteUIPopup.txt_input.text == "0"){
            self.view.window?.makeToast("Please input vote amount")
            return
        }
        
        let numberOfVote = Int(voteUIPopup.txt_input.text ?? "0") ?? 0
        let perchasedVotes = self.currentUser?.purchasedVotes ?? 0
        let nomUid = self.nomination.uid
        
//        if perchasedVotes >= numberOfVote {
            self.nomination.getAndSetVotesForParticulerNomination(action: VotesAction.set.id, uid: nomUid,vote: numberOfVote){ (totalVotes) in
                DispatchQueue.main.async {
                    self.numberVotesButton.setTitle("\(totalVotes)", for: .normal)
                }
                self.runningAnimation()
                self.updateCurrentUsersVoteCount()
            }
//        }else{
//          self.displayPopup()
//        }
        
    }
    
    @objc func countIncreseOrDecrese(_ sender: UIButton!) {
        
        if(sender.tag == 0)
        {
            voteCount = voteCount + 1
            voteUIPopup.txt_input.text =  "\(voteCount)"
        }
        else
        {
            if(voteCount == 0){
                return
            }
            voteCount = voteCount - 1
            voteUIPopup.txt_input.text =  "\(voteCount)"
        }
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        voteUIPopup.frame = CGRect(x: 0 , y: 0, width: screenSize.width, height: screenSize.height)
      //  designPopup()
        
        
        configureFacebookShareButtonConfigure()
        
        self.isFirstTime = true
        guard self.nomination != nil else {
            self.navigationController?.popViewController(animated: true)
            self.goldenAlert(title: "Error", message: "There was an issue loading this nomination", view: self)
            return
        }
        
        self.loadIndicatorView()
        self.configureRejectAndApprovedButton()
        
        self.designNav()
        //self.designInputViews()
        self.designGeneralInfo()
        self.designActionLayer()
        self.designInfo()
        self.observeVotes()
        self.loadLoggedInUser()
        self.designCollectionView(collection: self.photosCollection)
        self.voteButton.setBackgroundColor(.black, for: .normal)
        self.voteButton.addTarget(self, action: #selector(displayVotePopup(_:)), for: .touchUpInside)
        self.setApproveAndRejectButton()
        self.navigationController?.title = "Nominee: \(self.nomination.nominee.fullName)"
        
        
        self.nomineePic.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.nomineePic.addGestureRecognizer(tap)
        self.numberVotesButton.setTitle("\(self.nomination.numberOfVotes)", for: .normal)
        
        //        self.configureFacebookShareButtonConfigure()
        
    }
    
    
    func setApproveAndRejectButton(){
        
        if Auth.auth().currentUser == nil
        {
            if(self.nomination.finished == true)
            {
                self.btnReject.isHidden = true
                self.voteButton.isHidden = true
                self.btnApprove.isHidden = true
                viewPendingNominenationbuttons.isHidden = true
                return
            }
            
            viewPendingNominenationbuttons.isHidden = true
        }
        else
        {
            if(self.nomination.finished == true)
            {
                self.btnReject.isHidden = true
                self.voteButton.isHidden = true
                self.btnApprove.isHidden = true
                viewPendingNominenationbuttons.isHidden = true
                return
            }
            
            
            if self.isOpenFromAdmin
            {
                if self.nomination.adminApproved == false
                {
                    //self.approvedButton.title = "Approve"
                    self.btnApprove.setTitle("Approve", for: .normal)
//                    self.btnReject.setTitle("Reject", for: .normal)
                    
                    self.btnApprove.addTarget(self, action: #selector(AdminApprovedMethod(_:)), for: .touchUpInside)
                    self.btnReject.addTarget(self, action: #selector(rejectMethod(_:)), for: .touchUpInside)
                    
                }
                else
                {
                    self.btnReject.isHidden = true
                    // self.approvedButton.title = "Award"
                    btnApprove.setTitle("\(nomination.numberOfVotes) votes", for: .normal)
//                    self.btnApprove.isHidden = true
                }
                
                
              
            }
            if !nomination.userApproved {
                if nomination.nominatedBy.email == Auth.auth().currentUser?.email {
                    self.btnReject.isHidden = true
                    self.btnApprove.isHidden = true

                }
            }
            else
            {
                //                self.approvedButton.action = #selector(approvedMethod(_:))
                //                self.rejectButton.action = #selector(rejectMethod(_:))
                
                self.btnApprove.addTarget(self, action: #selector(approvedMethod(_:)), for: .touchUpInside)
                self.btnReject.addTarget(self, action: #selector(rejectMethod(_:)), for: .touchUpInside)
            }
        }
    }
    
    func loadIndicatorView()
    {
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        // activityView.startAnimating()
    }
    
    func loadLoggedInUser()
    {
        self.loadCurrentUser() { (currentUser, error) in
            guard error == nil && currentUser != nil else {
                print("Hey error loading current user")
                return
            }
            self.currentUser = currentUser!
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        designPendingBtns()
        designInputViews()
         designPopup()
    }
    
    
    @IBAction func btnActionOnReject(_ sender: UIButton)
    {
        var selectedNomineeId:String!
        selectedNomineeId = self.nomination.uid
        self.activityView.startAnimating()
        self.updateNomineeAdminStatus(action: AdminAction.adminReject.id, uid: selectedNomineeId)
    }
    
    
    @IBAction func btnActionOnApprove(_ sender: UIButton)
    {
        print(self.nomination.uid)
        
        var selectedNomineeId:String!
        selectedNomineeId = self.nomination.uid
        if self.nomination.adminApproved == false
        {
            self.activityView.startAnimating()
            self.updateNomineeAdminStatus(action: AdminAction.active.id, uid: selectedNomineeId)
        }
        else
        {
            self.activityView.startAnimating()
            self.updateNomineeAdminStatus(action: AdminAction.finished.id, uid: selectedNomineeId)
        }
    }
    
    
    func designPendingBtns()
    {
        self.btnApprove.layer.cornerRadius = 3.0
        self.btnReject.layer.cornerRadius = 3.0
        self.btnApprove.layer.masksToBounds = true
        let imageColor = self.gradient(size: self.btnApprove.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.btnApprove.backgroundColor     = UIColor.init(patternImage: imageColor!)
        self.btnReject.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        self.btnReject.layer.borderWidth = 1
    }
    
    func designNav()
    {
        self.setBarTint()
        self.setBarButtonTint()
        
        // Back Button
        self.backButton.target = self
        self.backButton.action = #selector(backSegue(_:))
        
        self.actionButton.target = self
        self.actionButton.action = #selector(actionDidTap(_:))
    }
    
    func designInputViews()
    {
        // Design Line View
        let imageColor = self.gradient(size: self.viewLine.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.viewLine.backgroundColor = UIColor.init(patternImage: imageColor!)
    }
    
    @objc func backSegue(_ sender: UIBarButtonItem)
    {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func moveToEditNomination(_ sender:UIBarButtonItem)
    {
        let checkoutVC = self.storyboard?.instantiateViewController(withIdentifier: "EditNominationViewController") as! EditNominationViewController
        checkoutVC.nomination = nomination
        checkoutVC.currentUser = nomination.nominee
        let navController = UINavigationController(rootViewController: checkoutVC)
        self.present(navController, animated:true, completion: nil)
    }
    
    
    @objc func shareGeneral(_ sender:UIBarButtonItem)
    {
        
        let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        if(nomination.urls.count > 0)
        {
            let imageUrl = self.nomination.urls[0]
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            
            imageV.sd_setImage(with: storageRef)
            
           
        }
        else
        {
            imageV.image = UIImage(named: "heartLogo")
        }
        
        let textspace = "\n\n"
        
        let appUrl = NSURL(string:"https://itunes.apple.com/us/app/golden-action-awards/id1387621029?ls=1&mt=8")

        
        let text = "\(self.nomineeName.text ?? "") has been nominated for a Golden Action Award. You can find my nomination by searching code \(self.nomination.searchCode) on the app here https://itunes.apple.com/us/app/golden-action-awards/id1387621029?ls=1&mt=8 \n"
        
        let shareAll = [imageV.image!, textspace, text , textspace, appUrl!] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo, UIActivityType.postToFacebook]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    @objc func shareFromFacebook(_ sender:UIBarButtonItem)
    {
      
        
        let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        if(nomination.urls.count > 0)
        {
            let imageUrl = self.nomination.urls[0]
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            
            imageV.sd_setImage(with: storageRef)
          
        }
        else
        {
            imageV.image = UIImage(named: "heartLogo")
            
        }
        
        let photo = Photo(image: imageV.image!, userGenerated: true)
        
        var content = PhotoShareContent(photos: [photo])
       
//        ShareDialog(content: [content])
        let shareDialog =  ShareDialog(content: content)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        
        do {
            try shareDialog.show()
        } catch let _ {
            print("ERROR")
        }
        
//        let textspace = "\n\n"
//
//        let text = "\(self.nomineeName.text ?? "") has been nominated for a Golden Action Award. You can find my nomination by searching code \(self.nomination.searchCode) on the app here https://itunes.apple.com/us/app/golden-action-awards/id1387621029?ls=1&mt=8 \n"
//
//        // let myWebsite = NSURL(string:"https://firebasestorage.googleapis.com/v0/b/golden-test-app.appspot.com/o/nominationPics%2F05F73153-CA12-4AB4-84A5-22945DF7B8DD?alt=media&token=488761c7-1ffc-4e38-bbcd-cdd95f76c288")
//
    
        
//        let shareAll = [imageV.image!, textspace, text , textspace, appUrl!] as [Any]
//
//        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo, UIActivityType.postToFacebook]
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @objc func actionDidTap(_ sender: UIBarButtonItem)
    {
//        guard Auth.auth().currentUser != nil else {
//            self.goldenAlert(title: "Vote Error!", message: "Sorry! You are not able to vote! Please login first.", view: self)
//            return
//        }
        //self.shareActionDropDown.show()
        
    }
    
    
    func designGeneralInfo()
    {
        self.nomineePic.layer.masksToBounds = false
        self.nomineePic.layer.cornerRadius  = self.nomineePic.frame.height/2
        self.nomineePic.clipsToBounds       = true
        
        self.loadNomineeImage()
        self.loadCollectionViewImages()
        
        let gesture = UITapGestureRecognizer(target: self.nomineePic, action: #selector(displayGallery(gesture:)))
        self.nomineePic.isUserInteractionEnabled = true
        
        self.nomineeName.text  =  self.nomination.nominee.fullName
        self.location.text     =  self.nomination.cityState
        self.pendingAward.text =  "Gold Award: \(self.nomination.category)"
        self.nominatedBy.text  = "Nominated By: \(self.nomination.nominatedBy.fullName)"
        
        self.tierLbl.text      = "Tiers:"
        self.tierDetails.text = "Nomination Level: 1-9 votes\nBronze Level: 10-30  votes\nSilver Level: 31-50 votes\nGold Level: 51+ votes"
    }
    
    func loadNomineeImage()
    {
        let imageUrl = self.nomination.nominee.profilePictureURL
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        nomineePic.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "heartLogo"))
        
        self.activityView.stopAnimating()
    }
    
    func loadCollectionViewImages()
    {
        self.photosCollection.reloadData()
    }
    
    
    @objc func displayVotePopup(_ sender: UIButton!) {
        
//        guard Auth.auth().currentUser != nil else{
//            self.activityView.stopAnimating()
//            self.goldenAlert(title: "Vote Error!", message: "Sorry! You are not able to vote! Please login first.", view: self)
//            return
//        }
        
        let endDate   = Date(timeIntervalSince1970: self.nomination.endDate)
        
        let dateString = endDate.toString(style: .short)
        let splitDate = dateString.components(separatedBy: " ")
        if splitDate[0] == "01/01/70," || splitDate[0] == "1/1/70,"{
            self.goldenAlert(title: "Vote Error!", message: "Nomination is still under review", view: self)
            return
        }
        
        let currentDate = Date()
        
        if endDate <= currentDate {
            self.goldenAlert(title: "Vote Error!", message: "Sorry! Voting is closed now", view: self)
            return
        }
        
        guard self.nomination.phase != 4 else{
            self.goldenAlert(title: "Share Error!", message: "Nomination is still under review", view: self)
            return
        }
        
        // let workItem = DispatchWorkItem {
        let nomUid = self.nomination.uid
        let perchasedVotes = self.currentUser?.purchasedVotes
        let nomPhase = self.nomination.phase
        
        // MARK:- #irshad (> 0)
        
        self.view.addSubview(voteUIPopup)
        
       /* if  perchasedVotes! > 0
        {
            self.nomination.getAndSetVotesForParticulerNomination(action: VotesAction.set.id, uid: nomUid){ (totalVotes) in
                DispatchQueue.main.async {
                    self.numberVotesButton.setTitle("\(totalVotes)", for: .normal)
                }
                self.runningAnimation()
                self.updateCurrentUsersVoteCount()
            }
        }
        else
        {
            
            //SubmitVoteViewController
            
//            let checkoutVC = self.storyboard?.instantiateViewController(withIdentifier:"SubmitVoteViewController") as! SubmitVoteViewController
//           // checkoutVC.currentUser = self.currentUser
//            //let navController = UINavigationController(rootViewController: checkoutVC)
//            //self.present(navController, animated:true, completion: nil)
//            //navController.pushViewController(checkoutVC, animated: true)
//            self.navigationController?.pushViewController(checkoutVC, animated: true)
            //self.displayPopup()
        }*/
        
    }
    
    func runningAnimation(){
        let workItem = DispatchWorkItem{
            LottieAnimationWithSound.sharedInstance.addAnimation(animationName: "3287-fireworks", soundFileName: "SMALL_CROWD_APPLAUSE", viewController: self)
        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
    }
    
    func updateCurrentUsersVoteCount(){
        guard self.currentUser != nil else{
            return
        }
        
        let uVote = self.currentUser?.purchasedVotes
        self.currentUser?.purchasedVotes = uVote! - 1
        
        self.currentUser?.saveFullAccount(completion: { (error,status) in
            print(status)
        })
    }
    
    func displayPopup()
    {
        let alert = UIAlertController(title: "Vote Error", message: "You have not enough vote, please purchase first.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"PURCHASE", style: .default, handler: { _ in
            NSLog("Please purchase votes first")
            
            let workItem = DispatchWorkItem {
                let checkoutVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.cart_screen.id) as! CartViewController
                checkoutVC.currentUser = self.currentUser
                let navController = UINavigationController(rootViewController: checkoutVC)
                //self.present(navController, animated:true, completion: nil)
                //navController.pushViewController(checkoutVC, animated: true)
                self.navigationController?.pushViewController(checkoutVC, animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func designActionLayer()
    {
        let endDate = self.nomination.endDate
        print("*****DATE INFO PARSING*****")
        print(nomination.endDate)
    
        let finalDate = Date(timeIntervalSince1970: endDate)
        let date = NSDate(timeIntervalSince1970: endDate)
        print(finalDate)

       // let chatDate = Date(timeIntervalSince1970: (TimeInterval(ts ?? 0) / 1000.0 ))
        
        if isDateIsEqualTo1970(date: finalDate) {
        }else{
        }
        
        
        
        // set donated value
        var totalAmount = 0
        let count = nomination.numberOfVotes
        
        if count > 30 && count <= 50 {
            totalAmount += 10
        }else if count > 50 && count <= 80 {
            totalAmount += 20
        }else if count > 80 && count <= 110 {
            totalAmount += 30
        } else if count > 110 {
            
        }
//        self.donatedLabel.text = "$\(totalAmount) Donated"
    }
    
    func isDateIsEqualTo1970(date:Date)-> Bool{
        self.timeRemaining.alpha = 1.0
        if !nomination.userApproved {
            self.timeRemaining.alpha = 0.0
        }
        let dateString = date.toString(style: .short)
        
        let splitDate = dateString.components(separatedBy: " ")
        if splitDate[0] == "01/01/70," || splitDate[0] == "1/1/70," || splitDate[0].contains("69"){
            self.timeRemaining.text = "Finished"
            return true
        }else{
           
            self.timeRemaining.text =  "Ends: \(dateString)"
            return false
        }
    }
    
    func observeVotes(){
        /*self.nomination.getAndSetVotesForParticulerNomination(action: VotesAction.get.id, uid: self.nomination.uid){(totalVotes) in
            
            DispatchQueue.main.async {
                //self.numberVotesButton.setTitle("\(totalVotes)", for: .normal)
            }
            
            if self.isFirstTime
            {
                self.isFirstTime = false
            }
            else
            {
                self.runningAnimation()
            }
        }*/
    }
    
    // Photos and Achievments --> Call Collection View Data here
    func designInfo() {
        self.photosLabel.text         = "Photos"
        self.achievmentsLabel.text    = "Achievments"
        self.charityTitleLbl.text     =  "Charity"
        
        self.achievmentsSummary.text  =  self.nomination.story
        self.achievmentsSummary.backgroundColor = UIColor.clear//Colors.nom_detail_innerBackground.generateColor()
        
        //        print(self.nomination.charity.charityName )
        //        print(self.nomination.charity.fullAddress ?? "")
        
        
        
        
        if (self.nomination.charity?.charityName) != nil &&  (self.nomination.charity?.fullAddress) != nil
        {
            let charityString = "\(self.nomination.charity.charityName),\n\(self.nomination.charity.fullAddress)\n"
            self.charityDetails.text  =  charityString
            self.charityDetails.backgroundColor = UIColor.clear//Colors.nom_detail_innerBackground.generateColor()
        }
        else
        {
            self.charityDetails.text  = ""
            self.charityDetails.backgroundColor = UIColor.clear//Colors.nom_detail_innerBackground.generateColor()
        }
        
    }
    // MARK: Needed Table View Items for Design and Sizing
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.nom_detail_firstBackground.generateColor()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return 671//UIScreen.main.bounds.height
        
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //return 671//UIScreen.main.bounds.height
        return UITableViewAutomaticDimension
    }
    // MARK: - Gesture Recognizer Delegate
    
    
    // MARK: - Swift Photo Library
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return self.samplePics.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return self.samplePics[forIndex]
    }
}
extension NomDetailTableViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func designCollectionView(collection: UICollectionView) {
        collection.backgroundColor = UIColor.clear//Colors.app_tableview_background.generateColor()
        collection.delegate = self
        collection.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.samplePics.count)
        return self.nomination.urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.nominee_detail_collection.id, for: indexPath) as! NomDetailCollectionViewCell
        //        cell.configureCell(img: self.samplePics[indexPath.row])
        
        
        let imageUrl = self.nomination.urls[indexPath.item]
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        
        
        cell.nomineeSuppPhoto.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "heartLogo"))
        
        
        cell.nomineeSuppPhoto.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cell.nomineeSuppPhoto.addGestureRecognizer(tap)
        
        return cell
    }
    
    
    @objc func displayGallery(gesture: UITapGestureRecognizer) {
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor(displayP3Red: 120/255, green: 120/255, blue: 120/255, alpha: 0.5)
        gallery.currentPageIndicatorTintColor = UIColor.white
        gallery.hidePageControl = false
        self.present(gallery, animated: true, completion: nil)
    }
    
    
}

extension NomDetailTableViewController{
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
}

extension NomDetailTableViewController{
    
    func configureRejectAndApprovedButton(){
        
        //        self.designButton(sender:self.approvedButton)
        //        self.designButton(sender:self.rejectButton)
        
        if self.isOpenFromAdmin
        {
            if self.nomination.adminApproved == false
            {
                self.btnApprove.isEnabled = true
                self.btnReject.isEnabled   = true
            }
            else
            {
                self.btnApprove.isEnabled = true
                self.btnReject.isEnabled   = false
                self.btnReject.tintColor   = .clear
            }
        }
        else
        {
            if(self.nomination.finished == true)
            {
                
            }
            else if self.nomination.userApproved == true
            {
                self.btnApprove.isEnabled = false
                self.btnReject.isEnabled   = false
                
                self.btnApprove.tintColor = .clear
                self.btnReject.tintColor   = .clear
                
                configureFacebookShareButtonConfigure()
                self.viewPendingNominenationbuttons.isHidden = true
            }
            else
            {
                configureEditButtonConfigure()
                self.btnApprove.isEnabled = true
                self.btnReject.isEnabled   = true
            }
        }
        
    }
    
    func designButton(sender:UIBarButtonItem){
        //sender.setBackgroundColor(UIColor.white, for: [])
        sender.tintColor = UIColor.black
        sender.target = self
    }
    
    @objc func approvedMethod(_ sender: UIBarButtonItem!) {
        
        print("**** userApproved ****")
        
        var selectedNomineeId:String!
        selectedNomineeId = self.nomination.uid
        self.updateNomineeStatus(action: AdminAction.userApproved.id, uid: selectedNomineeId)
    }
    
    @objc func rejectMethod(_ sender: UIBarButtonItem!)
    {
        print("rejected selector")
        
        var selectedNomineeId:String!
        selectedNomineeId = self.nomination.uid
        self.activityView.startAnimating()
        
        //self.updateNomineeStatus(action: AdminAction.adminReject.id, uid: selectedNomineeId)
        self.rejectNomValue(action: AdminAction.adminReject.id, uid: selectedNomineeId, completion: { status in
            self.activityView.stopAnimating()
            
            if status == true
            {
                self.goldenAlert(title: "Approved", message: "Congratulations! Your action\(AdminAction.lastSelectedOption.id) is processing.", view: self)
                self.dismiss(animated: true, completion: nil)
            }
            
        })
    }
    
    func updateNomineeStatus(action:String, uid:String) {
        self.activityView.startAnimating()
        self.updateNomValue(action:action, uid: uid, completion: { status in
            self.activityView.stopAnimating()
            if status == true{
                self.goldenAlert(title: "Approved for Admin", message: "Your nomination has been sent to be final approved by our admin. You will be notified soon.", view: self)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func rejectNomValue(action:String, uid:String, completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            if action == AdminAction.adminReject.id{
                                
                                if self.isOpenFromAdmin
                                {
                                    docRef.updateData(["userApproved":false, "phase" : 0])
                                }else{
                                    docRef.delete()
                                }
                            }
                        }
                    }
                }
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
    }
    
    
    /*    func updateNomValue(action:String, uid:String, completion: @escaping (Bool?) -> Void){
     let valueWorkItem = DispatchWorkItem {
     let ref = CollectionFireRef.nominations.reference()
     ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
     if error == nil {
     if let data = snapshot?.documents {
     for d in data {
     let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
     if action == AdminAction.userApproved.id {
     let adminStatus = d.get("adminApproved") as! Bool
     if adminStatus == true {
     let days = TimeInterval(3.minutes) //21.days
     let tmpDate:Date = Date().addingTimeInterval(days)
     docRef.updateData(["endDate":tmpDate.timeIntervalSince1970])
     docRef.updateData(["startDate":Date().timeIntervalSince1970])
     docRef.updateData(["phase":2])
     
     }
     docRef.updateData(["userApproved": true])
     }else{
     docRef.updateData(["userApproved": false])
     }
     }
     }
     }
     }
     completion(true)
     }
     DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
     } */
    
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
                                //                            }else if action == AdminAction.delete.id {
                                //                                docRef.delete()
                            }else{
                                let userStatus = d.get("userApproved") as! Bool
                                if userStatus == true {
                                    docRef.updateData(["startDate":Date().timeIntervalSince1970])
                                    let days = TimeInterval(20.days)
                                    let tmpDate:Date = Date().addingTimeInterval(days)
                                    docRef.updateData(["endDate":tmpDate.timeIntervalSince1970])
                                    docRef.updateData(["phase":2])
                                    docRef.updateData(["adminApproved": true])
                                }else{
                                    docRef.updateData(["userApproved": true])
                                }
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

//Handling admin action Approved/Reject here
extension NomDetailTableViewController{
    
    @objc func AdminApprovedMethod(_ sender: UIBarButtonItem!){
        print("**** adminApproved ****")
        
        var selectedNomineeId:String!
        selectedNomineeId = self.nomination.uid
        
        if self.nomination.adminApproved == false
        {
            self.activityView.startAnimating()
            self.updateNomineeAdminStatus(action: AdminAction.active.id, uid: selectedNomineeId)
        }
        else
        {
            self.activityView.startAnimating()
            self.updateNomineeAdminStatus(action: AdminAction.finished.id, uid: selectedNomineeId)
        }
    }
    
    
    func updateNomineeAdminStatus(action:String, uid:String) {
        
        self.updateNomAdminValue(action:action, uid: uid, completion: { status in
            self.activityView.stopAnimating()
            if status == true{
                self.goldenAlert(title: "Nomination updated!", message: "Congratulation! Your action\(AdminAction.lastSelectedOption.id) is in process", view: self)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func updateNomAdminValue(action:String, uid:String, completion: @escaping (Bool?) -> Void){
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
                                completion(true)

                            }else if action == AdminAction.delete.id {
                                docRef.delete()

                            }else if action == AdminAction.active.id {
                                docRef.updateData(["userApproved":true])

                            } else {
                                
                                let userStatus = d.get("userApproved") as! Bool
                                if userStatus == true {
                                    docRef.updateData(["startDate":Date().timeIntervalSince1970])
                                    let days = TimeInterval(20.days)
                                    let tmpDate:Date = Date().addingTimeInterval(days)
                                    docRef.updateData(["endDate":tmpDate.timeIntervalSince1970])
                                    docRef.updateData(["phase":2])
                                    docRef.updateData(["adminApproved": true])
                                   // docRef.updateData(["charityDone":false])
                                }

                            }
                            completion(true)

                        }
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
    }
}


extension NomDetailTableViewController {
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        
        let imageInfo   = GSImageInfo(image: (imageView.image ?? nil)!, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: imageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        
        imageViewer.dismissCompletion = {
            print("dismissCompletion")
        }
        
        present(imageViewer, animated: true, completion: nil)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
}

extension NomDetailTableViewController
{
    // icon dots
    
    
    func configureEditButtonConfigure(){
        guard self.currentUser != nil else {
            return
        }
        let button = UIButton(type: .custom)
        button.isUserInteractionEnabled = true
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        //button.contentMode = UIViewContentMode.scaleAspectFill
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.moveToEditNomination(_:)), for: .touchUpInside)
        self.actionButton.customView = button
    }
    
    func configureFacebookShareButtonConfigure(){
        guard self.currentUser != nil else {
            return
        }
        
        let button = UIButton(type: .custom)
//        button.setBackgroundImage(fShareImage?.resizableImage(withCapInsets: .zero), for: .normal) //.setImage(fShareImage, for: .normal)
        button.setImage(UIImage(named:"defShare.png"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        button.isUserInteractionEnabled = true
        //button.contentMode = UIViewContentMode.scaleAspectFill
        button.frame = CGRect(x: 5, y: 0, width: 15, height: 15)
//        button.translatesAutoresizingMaskIntoConstraints = false
        // button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        // button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
//        button.layer.masksToBounds = true
//        button.contentMode = .scaleAspectFit
        // button.layer.cornerRadius = button.bounds.size.width / 2
        
        button.addTarget(self, action: #selector(self.shareGeneral(_:)), for: .touchUpInside)
    
        self.actionButton.customView = button
        
        if let urlFromStr = URL(string: "fb://") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                setFBButton()
            }
        }
        
        

    }
    
    func setFBButton(){
        
        let fbShareImage = UIImage(named: "facebookShare.png");
        let fbbutton = UIButton(type: .custom)
        //        fbbutton.setBackgroundImage(fbShareImage?.resizableImage(withCapInsets: .zero), for: .normal) //.setImage(fShareImage, for: .normal)
        fbbutton.setImage(fbShareImage, for: .normal)
        fbbutton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        fbbutton.isUserInteractionEnabled = true
        //button.contentMode = UIViewContentMode.scaleAspectFill
        fbbutton.frame = CGRect(x: 5, y: 0, width: 40, height: 30)
        //        button.translatesAutoresizingMaskIntoConstraints = false
        // button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        // button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        //        button.layer.masksToBounds = true
        //        button.contentMode = .scaleAspectFit
        // button.layer.cornerRadius = button.bounds.size.width / 2
        
        fbbutton.addTarget(self, action: #selector(self.shareFromFacebook(_:)), for: .touchUpInside)
        self.fbActionButton.customView = fbbutton
    }
    
}
