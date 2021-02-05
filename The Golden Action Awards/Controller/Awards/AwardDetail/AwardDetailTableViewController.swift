//
//  AwardDetailTableViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Toucan
import SwiftPhotoGallery
import Firebase
import DGActivityIndicatorView
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class AwardDetailTableViewController: UITableViewController {
    
    // MARK: - Outlet Declaration
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    // Input View
    
    // Start Content Declaration
    @IBOutlet weak var awardeePic: UIImageView!
    @IBOutlet weak var awardeeName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var awardType: UILabel!
    @IBOutlet weak var nominatedBy: UILabel!
    // Number of Votes
    @IBOutlet weak var numberVotesLabel: UILabel!
    @IBOutlet weak var numberVotesButton: UIButton!
    
    // Vote
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var endedTime: UILabel!
    // Charity
    @IBOutlet weak var charityName: UILabel!
    @IBOutlet weak var charityDetails:UITextView!
    
    @IBOutlet var lblTearsDetails: UILabel!
    // Photos
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var photosCollection: UICollectionView!
    // Achievments
    @IBOutlet weak var achievmentsLabel: UILabel!
    @IBOutlet weak var achievmentsSummary: UITextView!
    // Design
    @IBOutlet weak var viewLineTop: UIView!
    var activityView:DGActivityIndicatorView!
    
    // Will be used to fill all information
    // var nominee: Nominee!
    var achieveSumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    var samplePics = [UIImage]()
    var award: Nominations!
    var currentUser: Person!
    var notificationType: Int?
    var admin: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadIndicatorView()
        
        guard self.award != nil else {
            self.navigationController?.popViewController(animated: true)
            self.goldenAlert(title: "Error", message: "There was an issue loading this award", view: self)
            return
        }
        self.designNav()
        self.designInputViews()
        self.designGeneralInfo()
        self.designActionLayer()
        self.observeVotes()
        self.designInfo()
        self.designCollectionView(collection: self.photosCollection)
        self.charityDesignInfo()
        
        self.awardeePic.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.awardeePic.addGestureRecognizer(tap)
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
    func designNav() {
        self.setBarTint()
        self.setBarButtonTint()
        // Back Button
        self.backButton.target = self
        self.backButton.action = #selector(backSegue(_:))
    }
    
    func designInputViews()
    {
        let imageColor = self.gradient(size: self.viewLineTop.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.viewLineTop.backgroundColor = UIColor.init(patternImage: imageColor!)
    }
    
    @objc func backSegue(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func actionTapped(_ sender: UIBarButtonItem)
    {
        if self.admin != nil {
            
        }
    }
    
    
    func designGeneralInfo()
    {
        // Nominee Pic Design
        self.awardeePic.contentMode = UIViewContentMode.scaleAspectFill
        self.awardeePic.layer.masksToBounds = true
        self.awardeePic.layer.cornerRadius = self.awardeePic.frame.height/2
        self.getNomineeProfilePic()
        
        self.awardeeName.text = self.award.nominee.fullName
        self.location.text = self.award.nominee.cityState
        let awType = self.getMedal()
        self.awardType.text = "\(awType) Award: \(self.award.category)"
        self.nominatedBy.text = "Nominated By \(self.award.nominatedBy.fullName)"
        
         self.lblTearsDetails.text = "Nomination Level: 1-9 votes\nBronze Level: 10-30  votes\nSilver Level: 31-50 votes\nGold Level: 51+ votes"
        
        self.loadCollectionViewImages()
    }
    
    func charityDesignInfo()
    {
        let charityObj = "\(self.award.charity?.charityName ?? ""),\n\(self.award.charity?.fullAddress ?? "")"
        self.charityDetails.text = charityObj
    }
    
    func getMedal() -> String {
        let votes = self.award.numberOfVotes
        if votes >= 50 {
            self.categoryImage.image = UIImage(named:"gold_\(award.category)")
            return "Gold"
        } else if (votes <= 50) && (votes >= 31) {
            self.categoryImage.image = UIImage(named:"silver_\(award.category)")
            return "Silver"
        } else if (votes <= 30) && (votes >= 10){
            self.categoryImage.image = UIImage(named:"copper_\(award.category)")
            return "Bronze"
        }else  if (votes <= 9) && (votes >= 1){
            return "Printable Certificate"
        }else{
            return ""
        }
    }
    
    func getNomineeProfilePic() {
        let valueWorkItem = DispatchWorkItem {
            if self.award.urls.count > 0{
                // let imageUrl = self.award.urls[0]
                let imageUrl = self.award.nominee.profilePictureURL
                let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
                
                // let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
                let storageRef = Storage.storage().reference(forURL: completeUrl)
                storageRef.downloadURL(completion: { (url, error) in
                    guard url != nil else {
                        self.activityView.stopAnimating()
                        return
                    }
                    do{
                        let data = try Data(contentsOf: url!)
                        let image = UIImage(data: data as Data)
                        self.awardeePic.image = image
                        self.activityView.stopAnimating()
                        
                    }catch{
                        print(error)
                        self.activityView.stopAnimating()
                    }
                })
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() /*+ .milliseconds(100) */, execute: valueWorkItem)
    }
    
    
    func loadCollectionViewImages()
    {
//        self.samplePics.removeAll()
//        for string in self.award.urls{
//            let imageUrl = string
//            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
//
//            //  let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
//            let storageRef = Storage.storage().reference(forURL: completeUrl)
//            storageRef.downloadURL(completion: { (url, error) in
//                guard url != nil else {
//                    return
//                }
//                do{
//                    let data = try Data(contentsOf: url!)
//                    let image = UIImage(data: data as Data)
//                    self.samplePics.append(image ?? UIImage(named: "heartLogo")!)
//                    self.photosCollection.reloadData()
//
//                }catch{
//                    print(error)
//                }
//            })
//        }
        
        self.photosCollection.reloadData()
        
    }
    
    @objc func displayVotePopup(_ sender: UIButton!) {
        let votePopup = VotePopup(vc: self)
        let workItem = DispatchWorkItem {
            self.present(votePopup.popup, animated: true, completion: nil)
        }
        votePopup.createPopup()
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(10), execute: workItem)
    }
    
    
    func designActionLayer() {
       // self.numberVotesLabel.attributedText = NomDetailStrings.numberVotesLabel.generateString(text: "Total Votes")
        self.numberVotesButton.layer.cornerRadius = 5.0
        self.numberVotesButton.layer.masksToBounds = true
        
        //self.categoryLabel.attributedText = NomDetailStrings.votesLabel.generateString(text: "Vote!")
        self.categoryLabel.text = "Vote!"
        
        let endDate = self.award.endDate
        let finalDate = Date(timeIntervalSince1970: endDate)
        
        if isDateIsEqualTo1970(date: finalDate)
        {
            //self.timeRemaining.attributedText = NomDetailStrings.timeRemaining.generateString(text: "Ends:")
        }
        else
        {
            // self.timeRemaining.attributedText = NomDetailStrings.timeRemaining.generateString(text: "Ends: \(finalDate)")//"Ends: \(split[0])")
        }
        
    }
    
    func isDateIsEqualTo1970(date:Date)-> Bool{
        let dateString = date.toString(style: .short)
        let splitDate = dateString.components(separatedBy: " ")
        
        if splitDate[0] == "1/1/70,"
        {
            self.endedTime.text = "Finished"
            return true
        }
        else
        {
            self.endedTime.text = "Ends: \(dateString)"
            return false
        }
    }
    
    func observeVotes() {
        print("VOTES--->")
        print(self.award.numberOfVotes)
       // self.numberVotesButton.setAttributedTitle(NomDetailStrings.numberVotesButton.generateString(text: "\(self.award.numberOfVotes)"), for: [])
        //self.numberVotesButton.setTitle("\(self.award.numberOfVotes)", for: .normal)
        self.numberVotesButton.setTitle("\(self.award.numberOfVotes)", for: .normal)
    }
    
    
    func designInfo()
    {
        self.achievmentsSummary.text = self.award.story
    }
    
    // MARK: Needed Table View Items for Design and Sizing
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.nom_detail_firstBackground.generateColor()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}








extension AwardDetailTableViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func designCollectionView(collection: UICollectionView) {
        collection.backgroundColor = Colors.app_tableview_background.generateColor()
        collection.delegate = self
        collection.dataSource = self
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.samplePics.count
        return self.award.urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.awardee_detail_collection.id, for: indexPath) as! AwardDetailCollectionViewCell
        // let url = self.award.urls[indexPath.row]
        // NukeLoad.nomination_detail.imageLoadFinish(view: cell.awardeePhoto, urlString: url)
        //cell.awardeePhoto.image = self.samplePics[indexPath.row]
        
        
        
        let imageUrl = self.award.urls[indexPath.item]
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        
        
        cell.awardeePhoto.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "heartLogo"))
        
        
//        cell.nomineeSuppPhoto.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
//        cell.nomineeSuppPhoto.addGestureRecognizer(tap)
        
        
        return cell
    }
    
    
}

extension AwardDetailTableViewController {
    
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
