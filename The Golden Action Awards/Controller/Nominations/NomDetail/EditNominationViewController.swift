//
//  EditProfileViewController.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 17/06/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import DGActivityIndicatorView

class EditNominationViewController: UIViewController {
    
    var nomination: Nominations!
    var notificationType: Int?
    var currentUser: Person?
    var saveSelectedCharity:Charity!
    var activityView:DGActivityIndicatorView!
    
    var selectedCollectionCell : NomCreateCollectionViewCell!
    var newImgPick: GoldenPicture!
    var samplePics = [UIImage]()
    var nomPics = [String]()
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet var tv_story: UITextView!
    @IBOutlet var lblCharity: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    let storyPlaceholder = "Why should this person be nominated?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBarTint()
        configureTitleLbl()
        designButtons()
        designCharityLabel()
        setupDelegates()
        loadIndicatorView()
        
        self.tv_story.text = storyPlaceholder
        self.tv_story.textColor = .white
        self.tv_story.backgroundColor = .clear
        
        print(nomination.charity.charityName)
        print(nomination.story)
        print(nomination.uid)
        
        
        saveSelectedCharity = nomination.charity
        lblCharity.text = nomination.charity.charityName
        tv_story.text = nomination.story
        nomPics = nomination.urls
        
        downloadImageFromFirebase()
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        // self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        //activityView.startAnimating()
    }
    
    //    @IBAction func btnActionOnback(_ sender: UIBarButtonItem) {
    //        self.dismiss(animated: true, completion: nil)
    //    }
    
    
    func configureTitleLbl(){
        let imageColor = self.gradient(size: self.lblTitle.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.lblTitle.textColor = UIColor.init(patternImage: imageColor!)
        
    }
    
    func designButtons() {
        self.designButton(button: self.btnBack)
        self.designButton(button: self.btnSubmit)
        self.btnBack.setTitle("Back", for: [])
        self.btnSubmit.setTitle("Update", for: [])
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
    
    func setupDelegates() {
        self.designCollectionView(collection: self.collectionView)
        self.tv_story.delegate = self
        self.tv_story.backgroundColor = UIColor.clear
        self.tv_story.isUserInteractionEnabled = true
    }
    
    func designCharityLabel(){
        self.lblCharity.backgroundColor = .clear
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.charityTapped(_:)))
        self.lblCharity.addGestureRecognizer(gesture)
    }
    
    @objc func charityTapped(_ gesture: UITapGestureRecognizer){
        let tutorialVC = self.storyboard?.instantiateViewController(withIdentifier: "CharityViewControler") as! CharityViewControler
        self.present(tutorialVC, animated: true, completion: {
            tutorialVC.doneClouser = { charity in
                self.lblCharity.text = "\(charity.charityName)"
                self.saveSelectedCharity = Charity(charityName: charity.charityName, address: charity.fullAddress, ein: charity.ein, uid:charity.uid)
            }
        })
    }
    
    func downloadImageFromFirebase()
    {
        for picUrl in nomPics{
            let imageUrl = picUrl
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            
            
            
            //let imageV = UIImageView.self
            
            
            storageRef.downloadURL(completion: { (url, error) in
                guard url != nil else {
                    return
                }
                do{
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    self.samplePics.append(image!)
                    
                }catch{
                    print(error)
                }
                
                self.collectionView.reloadData()
            })
        }
        
    }
    
    @IBAction func btnActionOnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnActionOnSubmit(_ sender: UIButton) {
        
        self.activityView.startAnimating()
        
        Nominations.saveNomPics(nomPics: self.samplePics) { (urls) in
            print(urls)
            DispatchQueue.main.async {
                self.getPerticulerPendingNomination(completion: {
                    (error, noms) in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    for nom in noms {
                        print(nom)
                    }
                    
                    
//                    let charityDic = ["charityName" : self.saveSelectedCharity.charityName, "classification" :self.saveSelectedCharity.classification, "address" : self.saveSelectedCharity.fullAddress, "ein" : self.saveSelectedCharity.ein, "uid" :self.saveSelectedCharity.uid]
                    
                    
                    let ref = CollectionFireRef.nominations.reference()
                    ref.document(globleDocumentID!).updateData([
                        "story" : self.tv_story.text, "charity" : self.saveSelectedCharity.toDictionary(), "urls" : urls
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                        
                        self.activityView.stopAnimating()
                    }
                    
                    let alertMessage = "Your nomination is update"
                    
                    guard appDelegate.nomineeController != nil else{
                        self.activityView.stopAnimating()
                        return
                    }
                    
                    if let view = appDelegate.nomineeController {
                        self.goldenAlert(title: "Congratulations", message: alertMessage, view: view)
                    }
                    //self.activityView.stopAnimating()
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                    print("total pending Noms Got")
                    print(noms.count)
                })
            }
        }
    }
    
    
    
    
    
    
}



extension EditNominationViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == self.tv_story{
            if self.tv_story.text == storyPlaceholder {
                self.tv_story.text = ""
            }
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.lightGray
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == self.tv_story{
            if textView.text.isEmpty {
                textView.text = storyPlaceholder
                textView.textColor = UIColor.lightGray
            }
        }
        
    }
    
}



extension EditNominationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
    
    
    
    
    func getPerticulerPendingNomination(completion: @escaping (Error?, [Nominations]) -> Void){
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("uid", isEqualTo: nomination.uid).getDocuments { (snapshot, error) in
            Nominations.handleInnerSnapshot(snapshot: snapshot, error: error, completion: { (error, noms) in
                completion(error, noms)
            })
        }
    }
    
}



extension EditNominationViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    func showAttachmentActionSheet() {
        if self.samplePics.count == 5 {
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

//enum AttachmentType: String{
//    case camera, video, photoLibrary
//}
