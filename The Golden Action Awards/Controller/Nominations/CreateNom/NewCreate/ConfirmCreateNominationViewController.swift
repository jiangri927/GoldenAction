//
//  ConfirmCreateNominationViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
//import MaterialComponents
import LinearProgressBarMaterial
import SwiftEventBus
import SwiftyContacts
import Bond
import Firebase
import SwiftKeychainWrapper
import DGActivityIndicatorView
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging


class ConfirmCreateNominationViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: ShadowedView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!//MDCRaisedButton!
    @IBOutlet weak var submitButton: UIButton!//MDCRaisedButton!
    
    @IBOutlet weak var charityDiscription:UILabel!
    
    @IBOutlet weak var addPhoto:UIButton!
    
    @IBOutlet weak var storyView: UITextView!
    
    var selectedCollectionCell : NomCreateCollectionViewCell!
    
    var currentUser: Person!
    
    var nominationType: String!
    var personType: Int!
    var selectedPerson: Person!
    
    // For new user Person Type
    var selectedPhone: String!
    var selectedName: String!
    var selectedEmail: String!
    var selectedPersonCluster: String!
    var selectedPersonCityState: String!
    
    var saveSelectedCharity:Charity!
    
    // Confirm VC Fields
    let storyPlaceholder = "Why should this person be nominated?"
    
    // Images
    var newImgPick: GoldenPicture!
    var samplePics = [UIImage]()
    
    var freeNominations: Int!
    var activityView:DGActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.charityDiscription.textColor = UIColor.white
        self.configureTitleLbl()
        self.tapDismiss()
        self.loadCurrentUser()
        self.designCharityLabel()
        self.checkForFreeNominations()
        self.setupDelegates()
        self.designButtons()
        self.submitButton.addTarget(self, action: #selector(saveNomination), for: .touchUpInside)
        self.backButton.reactive.tap.observeNext {
            self.navigationController?.popViewController(animated: true)
        }
        self.loadIndicatorView()
        self.storyView.text = storyPlaceholder
        self.storyView.textColor = .white
        self.storyView.backgroundColor = .clear
    }
    
    func configureTitleLbl(){
        let imageColor = self.gradient(size: self.titleLabel.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.titleLabel.textColor = UIColor.init(patternImage: imageColor!)
        
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        // self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        //activityView.startAnimating()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func charityTapped(_ gesture: UITapGestureRecognizer){
        let tutorialVC = self.storyboard?.instantiateViewController(withIdentifier: "CharityViewControler") as! CharityViewControler
        self.present(tutorialVC, animated: true, completion: {
            tutorialVC.doneClouser = { charity in
                self.charityDiscription.text = "\(charity.charityName)"
                self.saveSelectedCharity = Charity(charityName: charity.charityName, address: charity.fullAddress, ein: charity.ein, uid:charity.uid)
            }
        })
    }
    
   
    
    
    @objc func saveNomination(){
        self.activityView.startAnimating()
        guard self.saveSelectedCharity != nil else {
            self.goldenAlert(title: "Error", message: "There was an error finding the charity.", view: self)
            self.activityView.stopAnimating()
            return
        }
        
        if(self.storyView.text == "Why should this person be nominated?"){
            self.goldenAlert(title: "Error", message: "Why should this person be nominated?", view: self)
            self.activityView.stopAnimating()
            return
        }
        
        Nominations.saveNomPics(nomPics: self.samplePics) { (urls) in
            //  self.checkForExisting(phone: self.selectedPhone ?? "N/A") { (signedUp, uid) in
            //if signedUp {
            
            
            if self.personType == 0 {
                Person.getUser(uid: self.selectedPerson.uid, completion: { (person) in //uid!
                    guard person != nil else {
                        self.goldenAlert(title: "Error", message: "There was an error finding the person", view: self)
                        self.activityView.stopAnimating()
                        return
                    }
                    let anonymous = false
                    //self.currentUser = person!
                    
//                    var stroyText : String = self.storyView.text
//                    if(self.storyView.text == "Why should this person be nominated?"){
//                        stroyText = ""
//                    }
                    
                    let endDate = Date().millisecondsSince1970
                    let date = Date(milliseconds: endDate)
                    
                    let nomination = Nominations(nominee: person!, anon: anonymous, nominatedBy: self.currentUser, endDate: endDate, urls: urls, category: self.nominationType, region: self.currentUser.region, cityState: self.currentUser.cityState, story: self.storyView.text, imgUIDS: person?.uuid ?? [], phase: NominationPhase.phase_one.id, edited: false, charityAdded: true, charity: self.saveSelectedCharity!, uid :person?.uid ?? "N/A", searchCode: self.randomString(6))
                    
                    
                    let userNominatedBy = UserNominations(nomineePhone: person!.phone, nomineeName: person!.fullName, nomineeEmail: person!.email, nomUID: person!.uid, status: NominationPhase.phase_one.status, nominatedByUID: self.currentUser.uid, nomineeUID: person!.uid, nomineeURL: person!.profilePictureURL, category: self.nominationType, phase: NominationPhase.phase_one.id)
                    // Saves and sends notification --> Phase One
                    NominationStatus.phase_one(nomination: nomination, userNom: userNominatedBy, hasAccount: true).saveNomination(vc: self, completion: { (complete) in
                        if complete {
                            let back = DispatchWorkItem {
                                self.navigationController?.dismiss(animated: false, completion:nil);
                                return
                            }
                            let alertMessage = "Your nomination is awaiting approval from the nominee and our nomination sponsors and it will be up! You will be notified as it goes through this process"
                            
                            guard appDelegate.nomineeController != nil else{
                                //self.activityView.stopAnimating()
                                return
                            }
                            
                            if let view = appDelegate.nomineeController {
                                self.goldenAlert(title: "Congratulations", message: alertMessage, view: view)
                            }
                            
                            self.activityView.stopAnimating()
                            self.navigationController?.dismiss(animated: false, completion:nil);
                            
                        }
                        self.activityView.stopAnimating()
                    })
                })
            } else {
                
                let region          = self.selectedPersonCluster
                let cityState       = self.selectedPersonCityState
                let phone           = self.selectedPhone
                let emailValue      = self.selectedEmail
                let fullName         = self.selectedName
                let story            = self.storyView.text
                self.runNoUserNomination(cityState:cityState ?? "Popular" , region: region ?? "000", phone: phone ?? "N/A", fullName: fullName ?? "N/A", story: story ?? "For good work", urls: urls, email: emailValue ?? "N/A")
            }
        }
    }
    
    func randomString(_ len:Int) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var c = Array(charSet)
        var s:String = ""
        for _ in 1 ... len {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }
    
    func loadCurrentUser() {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser!.uid
            self.loadPerson(uid: uid)
        } else {
            if KeychainWrapper.standard.hasValue(forKey: Keys.download_check.key) {
                Auth.auth().signInAnonymously { (user, error) in
                    if error != nil {
                        let err = error! as NSError
                        Authorize.instance.handleAlert(error: err, view: self)
                    } else {
                        let uid = user?.user.uid ?? "none"
                        self.loadPerson(uid: uid)
                    }
                    
                }
            } else {
                //                let vcid = VCID.tutorial_one.id
                //                let tutorialVC = self.storyboard?.instantiateViewController(withIdentifier: vcid) as! UINavigationController
                //                self.present(tutorialVC, animated: true, completion: nil)
            }
        }
    }
    func loadPerson(uid: String) {
        Person.loadCurrentPerson(uid: uid) { (error, current) in
            guard error == nil && current != nil else {
                self.goldenAlert(title: "Error", message: "Error loading person please check your internet connection and try again", view: self)
                return
            }
            self.currentUser = current!
        }
    }
    
    func runNoUserNomination(cityState: String, region: String, phone: String, fullName: String, story: String, urls: [String],email : String) {
        //Taking only first profile image
        var profileImageUrl = "N/A"
        if urls.count > 0 {
            profileImageUrl = urls[0]
        }
        
        let nomineePerson = Person(uid: "N/A", fullName: fullName, acctType: AcctType.anonymous.type, profilePic: profileImageUrl, email: email, phone: phone, region: region, cityState: cityState, uuid: "N/A", admin: false, adminStage: AdminStatus.none.status, adminDescription: "N/A",isSponsor: false, address: "")
        let anonymous = true
        
        let currentUserId = Auth.auth().currentUser?.uid
        guard currentUserId != nil else {
            self.activityView.stopAnimating()
            return
        }
        Person.getUser(uid: currentUserId ?? "", completion: { (person) in
            guard person != nil else {
                self.goldenAlert(title: "Error", message: "There was an error finding the person", view: self)
                self.activityView.stopAnimating()
                return
            }
            let nomination = Nominations(nominee: nomineePerson, anon: false, nominatedBy: person!, endDate: 0, urls: urls, category: self.nominationType, region: region, cityState: cityState, story: story, imgUIDS: person?.uuid ?? [], phase: NominationPhase.phase_one.id, edited: false, charityAdded: false, charity:self.saveSelectedCharity, uid :person?.uid ?? "N/A", searchCode: self.randomString(6))
            
            let userNominatedBy = UserNominations(nomineePhone: nomineePerson.phone, nomineeName: nomineePerson.fullName, nomineeEmail: nomineePerson.email, nomUID: nomination.uid, status: NominationPhase.phase_one.status, nominatedByUID: person!.uid, nomineeUID:nomineePerson.uid , nomineeURL: nomineePerson.profilePictureURL, category: self.nominationType, phase: NominationPhase.phase_one.id)
            
            print(nomination.toDictionary())
            print(userNominatedBy.toDictionary())
            
            NominationStatus.phase_one(nomination: nomination, userNom: userNominatedBy, hasAccount: false).saveNomination(vc: self) { (complete) in
                self.activityView.stopAnimating()
                
                if complete {
                    let back = DispatchWorkItem {
                        
                        self.navigationController?.dismiss(animated: false, completion:nil);
                        return
                    }
                    var alertMessage: String!
                    if anonymous {
                        var totalNom = self.currentUser.purchasedNoms
                        self.currentUser.purchasedNoms = totalNom - 1
                        self.currentUser.updatePurchasedNom()
                        alertMessage = "Your nomination is awaiting approval from the nominee and our nomination sponsors and it will be up! You will be notified as it goes through this process."
                        //                        let alertVC = self.goldenCustomActions(vc: self, title: "Congratulations", message: alertMessage, buttonOneTitle: "Okay", buttonTwoTitle: nil, buttonOneAction: back, buttonTwoAction: nil, buttonThreeAction: nil, buttonThreeTitle: nil, twoAction: false, threeAction: false)
                        //                        self.present(alertVC, animated: true, completion: nil)
                        guard appDelegate.nomineeController != nil else{
                            return
                        }
                        
                        if let view = appDelegate.nomineeController {
                            self.goldenAlert(title: "Congratulations", message: alertMessage, view: view)
                        }
                        self.navigationController?.dismiss(animated: false, completion:nil);
                        
                    } else {
                        var totalNom = self.currentUser.purchasedNoms
                        self.currentUser.purchasedNoms = totalNom - 1
                        self.currentUser.updatePurchasedNom()
                        alertMessage = "Your nomination is awaiting approval from the nominee and our nomination sponsors and it will be up! You will be notified as it goes through this process, would you like to personally share with the nominee that you have nominated them? If not, we will text them a link that they have been nominated and to download the app!"
                        // MARK: - Put in iMessage here with PDF generator
                        
                        guard appDelegate.nomineeController != nil else{
                            return
                        }
                        
                        if let view = appDelegate.nomineeController {
                            self.goldenAlert(title: "Congratulations", message: alertMessage, view: view)
                        }
                        self.navigationController?.dismiss(animated: false, completion:nil);
                        
                    }
                    
                }
            }
        })
        
        
    }
    
    // Checks for the person they are nominating to be a full user --> If so returns the uid
    func checkForExisting(phone: String, completion: @escaping (Bool, String?) -> Void) {
        let ref = DBRef.userPhoneNumber(phoneNumber: phone).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let uid = snapshot.value as? String ?? "none"
                completion(true, uid)
            } else {
                completion(false, nil)
            }
        }
    }
    
    @objc func purchaseDidTap() {
        self.submitButton.reactive.tap.observeNext {
            guard self.errorCheck() else {
                return
            }
            if self.freeNominations != nil && self.freeNominations > 0 {
                self.changeNominationTransact()
                
            } else {
                print("User click on purchaseed noms")
            }
            
            
            
        }
    }
    
    func errorCheck() -> Bool {
        guard self.storyView.text == self.storyPlaceholder || self.storyView.text != "" else {
            self.error(title: "Please enter a story for the nominee", message: nil, error: nil)
            return false
        }
        guard self.samplePics != [] else {
            self.error(title: "Please enter at least one photo for the nominee", message: nil, error: nil)
            return false
        }
        return true
    }
    func manageNomEnum() {
        
    }
    func saveImages(imgs: [UIImage], completion: ([String], Bool, Error)) {
        
    }
    
    // MARK: -- DESIGNING the Confirm Nomination VC
    func setupDelegates() {
        self.designCollectionView(collection: self.collectionView)
        self.storyView.delegate = self
        self.storyView.backgroundColor = UIColor.clear
        self.storyView.isUserInteractionEnabled = true
    }
    
    func designCharityLabel(){
        self.charityDiscription.backgroundColor = .clear
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.charityTapped(_:)))
        self.charityDiscription.addGestureRecognizer(gesture)
    }
    
    func designTextView(storyTextView:UITextView){
        storyTextView.layer.cornerRadius = 15.0
        storyTextView.layer.masksToBounds = true
        storyTextView.layer.shadowColor = Colors.app_text.generateColor().cgColor
        storyTextView.layer.shadowOpacity = 0.9
        storyTextView.layer.shadowRadius = 3
        storyTextView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func designButtons() {
        self.designButton(button: self.backButton)
        self.designButton(button: self.submitButton)
        self.backButton.setTitle("Back", for: [])
        self.submitButton.setTitle("Submit", for: [])
    }
    
    func designButton(button:UIButton) {
        let imageColor = self.gradient(size: button.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        button.setBackgroundColor(.clear, for: [])
        button.setTitleColor(.white, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        button.layer.masksToBounds = false
    }
    
    func setupMultiLineField(scrollView: UIScrollView) {
        let textFieldDefaultCharMax = UITextView()//MDCMultilineTextField()
        scrollView.addSubview(textFieldDefaultCharMax)
        textFieldDefaultCharMax.text = "You may enter up to 250 characters, show the world how great this person is..."
        textFieldDefaultCharMax.delegate = self
        
        // Second the controller is created to manage the text field
        //        let textFieldControllerDefaultCharMax = MDCTextInputControllerUnderline(textInput: textFieldDefaultCharMax) // Hold on as a property
        //        textFieldControllerDefaultCharMax.characterCountMax = 250
        //        textFieldControllerDefaultCharMax.isFloatingEnabled = true
    }
    // MARK: - Fetching Functions
    func checkForFreeNominations() {
        let ref = DBRef.free_nominations.reference()
        ref.observe(.value) { (snapshot) in
            let number = snapshot.value as? Int ?? 0
            self.freeNominations = number
        }
    }
    
    func changeNominationTransact() {
        let ref = DBRef.free_nominations.reference()
        /*ref.runTransactionBlock({ (updated) -> TransactionResult in
         let val = updated.value as? Int ?? 0
         if val != 0 {
         updated.value = val - 1
         }
         return TransactionResult.success(withValue: updated)
         }, andCompletionBlock: { (error, complete, ref) in
         guard error == nil else {
         print(error!.localizedDescription)
         return
         }
         }, withLocalEvents: false) */
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension ConfirmCreateNominationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func designCollectionView(collection: UICollectionView) {
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.isUserInteractionEnabled = true
        collection.layer.masksToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.samplePics.count > 0 ? (self.samplePics.count + 1) : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = CellId.create_nom_collection.id
        let addPhotoId = CellId.addPhoto_cell.id
        
        let cell      = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! NomCreateCollectionViewCell
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: addPhotoId, for: indexPath)
        
        if indexPath.row == 0 {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(changePicture(recognizer:)))
            photoCell.addGestureRecognizer(gesture)
            return photoCell
        }else{
            let img = self.samplePics[indexPath.row - 1]
            let gesture = UITapGestureRecognizer(target: self, action: #selector(changePicture(recognizer:)))
            cell.configureCell(img: img)
            cell.createNomImage.tag = indexPath.row - 1
            cell.createNomImage.isUserInteractionEnabled = true
            cell.createNomImage.addGestureRecognizer(gesture)
            return cell
        }
    }
    
    // MARK: - Segue to Detail Gesture Recognizer
    @objc func changePicture(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapCell = recognizer.location(in: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: tapCell) {
                if indexPath.row == 0 {
                    self.addPhotoMethod()
                }else{
                    if let tapCell = self.collectionView.cellForItem(at: indexPath) as? NomCreateCollectionViewCell {
                        selectedCollectionCell = tapCell
                        self.showAttachmentActionSheet()
                        
                    }
                }
            }
        }
    }
    
    @objc func addPhotoMethod(){
        selectedCollectionCell = nil
        self.showAttachmentActionSheet()
    }
    
}


extension ConfirmCreateNominationViewController{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == self.storyView{
            if self.storyView.text == storyPlaceholder {
                self.storyView.text = ""
            }
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.lightGray
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == self.storyView{
            if textView.text.isEmpty {
                textView.text = storyPlaceholder
                textView.textColor = UIColor.lightGray
            }
        }
        
    }
    
}

extension ConfirmCreateNominationViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    func showAttachmentActionSheet() {
        if self.samplePics.count == 5{
            self.goldenAlert(title: "Profile picture", message: "You can upload 5 photo.", view: self)
            return
        }
        
        let actionSheet = UIAlertController(title: "Select Profile Picture!", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Phone Library", style: .default, handler: { (action) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // To handle image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if selectedCollectionCell == nil {
                self.samplePics.append(image)
            }else{
                self.samplePics.remove(at: selectedCollectionCell.createNomImage.tag)
                self.samplePics.insert(image, at: selectedCollectionCell.createNomImage.tag)
            }
            self.collectionView.reloadData()
            
        } else{
            print("Something went wrong in  image")
        }
        // To handle video
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            print("videourl: ", videoUrl)
            //trying compression of video
            let data = NSData(contentsOf: videoUrl as URL)!
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            //self.videoPickedBlock?(videoUrlFromPhone, size)
        }
        else{
            print("Something went wrong in video")
        }
        //self.dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
}

enum AttachmentType: String{
    case camera, video, photoLibrary
}

extension Date {
    var millisecondsSince1970:Double {
        //return Double((self.timeIntervalSince1970 * 1000.0).rounded())
        return self.timeIntervalSince1970
    }
    
    init(milliseconds:Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1)
    }
}
