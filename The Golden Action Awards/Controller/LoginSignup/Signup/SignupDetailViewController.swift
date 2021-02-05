//
//  SignupDetailViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SearchTextField
import SwiftKeychainWrapper
import Firebase
import PhoneNumberKit
import Toucan
import FaceAware
import DGActivityIndicatorView

class SignupDetailViewController: UIViewController, UITextFieldDelegate {
    

    // MARK: - Outlet Declaration
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    
    // Prof Pic
    @IBOutlet weak var profPic: UIImageView!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var locationField: SearchTextField!
    @IBOutlet weak var phoneField: PhoneNumberTextField!
    
    var phoneNumberVerification = PhoneNumberTextField()
    
    var currentUser: Person!
    var profImg: UIImage!
    var imgPick: GoldenImagePicker!
    var searches = [SearchTextFieldItem]()
    var selectedItem: SearchTextFieldItem!
    
    var pickedLocation: Cities!
    var acctType: String!
    var admin: Bool!
    var adminDescription: String!
    var adminAddress: String!
    var isEditProfile : Bool!
    var isUpdateOrCreate: Bool!
    
    var email: String!
    var password: String!
    
    var phoneNumber: String!
    var credentialPhone: AuthCredential!
    
    let titleLabel = LoginStrings.signup_titles.generateString(text: "User Profile")
    let submitTitle = LoginStrings.login_text.generateString(text: "Create Account")
    let submitTitle1 = LoginStrings.login_text.generateString(text: "Update Profile")
    
    let firstField = LoginStrings.login_text.generateString(text: "First Name")
    let lastField = LoginStrings.login_text.generateString(text: "Last Name")
    let locField = LoginStrings.login_text.generateString(text: "Location")
    let phonePlaceholder = LoginStrings.login_text.generateString(text: "(xxx) xxx-xxxx")
    
    let lineColor = LoginColors.view_lines.generateColor()
    let submitBGCOlor = LoginColors.signup_button.generateColor()
    let textColor = Colors.app_text.generateColor()
    let textfieldBackgroundColor = LoginColors.text_field.generateColor()
    
    let picPlaceholder = StaticPictures.picture_selection.generatePic()
    
    let app_text = Colors.app_text.generateColor()
    
    var activityView:DGActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadIndicatorView()
        
        let fields: [UITextField] = [self.firstNameField, self.lastNameField]
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        let createGesture = UITapGestureRecognizer(target: self, action: #selector(createDidTap(recognizer:)))
        
        
        self.tapDismiss()
        // Design Elements
        self.designScreen()
        //self.designButton()
        self.designProfPic()
        self.designTextFields(txtFields: fields)
        self.implementTextFields()
//        self.submitButton.addGestureRecognizer(createGesture)
        // Add back button gesture
        self.view.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
        self.backgroundScrollView.updateContentView()
        self.view.backgroundColor = Constants.background
        
        
        
        
        
        
        
        // get cities from firebase
        
        activityView.startAnimating()
        
        SearchFirebaseDB.instance.loadCityQuery(query: self.locationField.text!){(searches) in
            guard searches != nil else {
                return
            }
            
            print("**** 0 ****")
            self.searches = searches!
            self.activityView.stopAnimating()
        }
        
        //********
        designButton()
        self.overridedViewWillAppear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func overridedViewWillAppear() {
        if(isEditProfile == true){
        
        var fullNameArr = self.currentUser.fullName.components(separatedBy: " ")
        
        let firstName: String = fullNameArr[0]
        let lastName: String? = fullNameArr[1]
        
        self.firstNameField.text  = firstName
        self.lastNameField.text = lastName
        self.locationField.text   = self.currentUser.cityState
        self.phoneField.text = self.currentUser.phone
        // self.selectedItem.title = self.locationField.text ?? <#default value#>
        
        if self.currentUser?.profilePictureURL != nil{
        let imageUrl = self.currentUser.profilePictureURL
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        //profPic.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "profileicon"))
        
        storageRef.downloadURL(completion: { (url, error) in
        guard url != nil else
        {
        return
        }
        do
        {
        let data = try Data(contentsOf: url!)
        let image = UIImage(data: data as Data)
        
        self.profPic.image = image
        }
        catch
        {
        print(error)
        }
        })
        
        
        }
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //designButton()
        
    }
    
   
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        //activityView.startAnimating()
    }
    
    func designScreen() {
        let imageColor = self.gradient(size: self.detailTitle.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])

        self.detailTitle.textColor = UIColor.init(patternImage: imageColor!)
        //self.detailTitle.attributedText = self.titleLabel
    }
    func designLines(views: [UIView]) {
        for view in views {
            view.backgroundColor = self.lineColor
        }
    }
    func designButton() {
        
        if(isEditProfile == true){
            self.submitButton.setAttributedTitle(self.submitTitle1, for: [])
        }else{
            self.submitButton.setAttributedTitle(self.submitTitle, for: [])
        }
        
        
        self.submitButton.layer.cornerRadius = 10.0
        self.submitButton.layer.masksToBounds = true
        self.submitButton.backgroundColor = self.submitBGCOlor
        let imageColor = self.gradient(size: self.submitButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.submitButton.backgroundColor = UIColor.init(patternImage: imageColor!)
    }
    func designProfPic() {
      //  self.profPic.image = self.picPlaceholder
        self.profPic.contentMode = UIViewContentMode.scaleToFill
        self.profPic.layer.masksToBounds = true
        self.profPic.layer.cornerRadius = self.profPic.frame.height / 2
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profPicTapped(recognizer:)))
        self.profPic.isUserInteractionEnabled = true
        self.profPic.addGestureRecognizer(gesture)
        self.profPic.focusOnFaces = true
    }
    func implementTextFields() {
        
        self.firstNameField.attributedPlaceholder = NSMutableAttributedString(string: "First Name", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.firstNameField.backgroundColor = .black
        self.firstNameField.borderStyle = .none
        self.firstNameField.textColor = Constants.loginFontColor
        self.firstNameField.setBottomBorder()
        self.firstNameField.delegate = self
        self.firstNameField.returnKeyType = .default
        
        self.lastNameField.attributedPlaceholder = NSMutableAttributedString(string: "Last Name", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.lastNameField.backgroundColor = .black
        self.lastNameField.borderStyle = .none
        self.lastNameField.textColor = Constants.loginFontColor
        self.lastNameField.setBottomBorder()
        self.lastNameField.delegate = self
        self.lastNameField.returnKeyType = .default
        self.lastNameField.keyboardType = .default
        
        self.locationField.attributedPlaceholder = NSMutableAttributedString(string: "Location", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.locationField.backgroundColor = .black
        self.locationField.borderStyle = .none
        self.locationField.textColor = .white
        self.locationField.setBottomBorder()
        self.locationField.delegate = self
        self.locationField.returnKeyType = .default
        
        self.phoneField.attributedPlaceholder = NSMutableAttributedString(string: "(xxx) xxx-xxxx", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : Fonts.hira_pro_six.generateFont(size: 17.0)])
        self.phoneField.backgroundColor = .black
        self.phoneField.borderStyle = .none
        self.phoneField.textColor = Constants.loginFontColor
        self.phoneField.setBottomBorder()
        self.phoneField.delegate = self
        self.phoneField.returnKeyType = .default
        
        self.phoneField.isPartialFormatterEnabled = true
        
        if self.acctType == AcctType.phone.type {
            self.phoneField.text = self.phoneNumber
            self.phoneField.isUserInteractionEnabled = false
        }
        
        self.designSearchField()
        
        
    }
    
    func designTextFields(txtFields: [UITextField]) {
        for field in txtFields {
            field.isUserInteractionEnabled = true
            field.textColor = self.textColor
            field.backgroundColor = .clear
            //field.borderStyle = .none
        }
    }
    
    func designSearchField() {
        self.locationField.textColor = UIColor.white
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.locationField.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title), \(item.subtitle!)")
            self.selectedItem = item
            self.resignFirstResponder()
        }
       // self.locationField.direction = .up
        self.locationField.theme.bgColor = .clear
        self.locationField.theme.fontColor = app_text
        self.locationField.theme.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        self.locationField.itemSelectionHandler = closure
        self.locationField.borderStyle = .none
    }
    
    
    
    @IBAction func userTyping(_ sender: Any) {
        self.locationField.showLoadingIndicator()
        
        if(self.searches.count != 0){
            
            print("**** 1 ****")
            self.locationField.filterItems(self.searches)
            self.locationField.startSuggestingInmediately = true
            self.locationField.stopLoadingIndicator()
        }
        else
        {
            SearchFirebaseDB.instance.loadCityQuery(query: self.locationField.text!){(searches) in
                guard searches != nil else {
                    return
                }
                
                print("**** 0 ****")
                self.searches = searches!
                self.locationField.filterItems(searches!)
                self.locationField.startSuggestingInmediately = true
                self.locationField.stopLoadingIndicator()
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        
        if(isEditProfile == true)
        {
            updateProfile()
        }
        else
        {
            self.activityView.startAnimating()
            guard self.firstNameField.text != "" else {
                self.goldenAlert(title: "Error", message: "Please enter your first name", view: self)
                self.activityView.stopAnimating()
                self.submitButton.isUserInteractionEnabled = true
                
                return
            }
            guard self.lastNameField.text != "" else {
                self.goldenAlert(title: "Error", message: "Please enter your last name", view: self)
                self.activityView.stopAnimating()
                self.submitButton.isUserInteractionEnabled = true
                
                return
            }
            guard self.phoneField.text != "" else{
                self.goldenAlert(title: "Error", message: "Please enter a valid phone number", view: self)
                self.activityView.stopAnimating()
                self.submitButton.isUserInteractionEnabled = true
                
                return
            }
            guard self.selectedItem != nil else {
                self.goldenAlert(title: "Error", message: "Please select a city from the dropdown", view: self)
                self.activityView.stopAnimating()
                self.submitButton.isUserInteractionEnabled = true
                
                return
            }
            //        guard self.profImg != nil else {
            //            self.goldenAlert(title: "Error", message: "Please input a profile picture", view: self)
            //            self.activityView.stopAnimating()
            //            self.submitButton.isUserInteractionEnabled = true
            //
            //            return
            //        }
            
            if self.adminDescription == nil {
                self.adminDescription = "N/A"
            }
            //"+1 704-557-0145"
            let trimmedString = self.phoneField.text!.trimmingCharacters(in: .whitespacesAndNewlines) as String
            let phoneNumber = trimmedString.replacingOccurrences(of: " ", with: "")
            
            print(phoneNumber)
            
            checkForExisting(phone: self.phoneField.text ?? "") { (isFound, message) in
                if isFound == true {
                    self.activityView.stopAnimating()
                    self.goldenAlert(title: "Error", message: "Phone is already associated with another account", view: self)
                }else{
                    // MARK:- #irshad +1
                    PhoneAuthProvider.provider().verifyPhoneNumber("+1\(phoneNumber))", uiDelegate: nil) { (verificationID, error) in
                        self.activityView.stopAnimating()
                        self.submitButton.isUserInteractionEnabled = true
                        
                        guard error == nil else {
                            self.goldenAlert(title: "Error", message: "There was an error authing the phone, please try again", view: self)
                            return
                        }
                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                        let smsVerify: VerifySMSViewController = self.storyboard!.instantiateViewController(withIdentifier: "VerifySMSViewController") as! VerifySMSViewController
                        smsVerify.signUpController = self
                        self.navigationController?.pushViewController(smsVerify, animated: true)
                    }
                }
            }
        }
    }
    
    
    //First create sms verification and then creating user account
    @objc func createDidTap(recognizer: UITapGestureRecognizer) {
        
        print("gesture tap")
        
        
       
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
    
    func submitUserDataToServer(){
        
        let fullName = "\(self.firstNameField.text!) \(self.lastNameField.text!)"
        let cluster = selectedItem.cluster!
        let cityState = "\(selectedItem.title) \(selectedItem.subtitle!)"
        if self.adminDescription == nil {
            self.adminDescription = "N/A"
        }
        
        Auth.auth().signInAnonymously(completion: { (user, error) in
            guard error == nil else {
                self.goldenAlert(title: "Error Signing Up", message: "There was an error signing up please check your internet", view: self)
                print(error!.localizedDescription)
                self.activityView.stopAnimating()
                return
            }
            let uid = Auth.auth().currentUser!.uid
            
            var credential: AuthCredential!
            if self.acctType == AcctType.email.type {
                let emailCred = EmailAuthProvider.credential(withEmail: self.email!, password: self.password!)
                credential = emailCred
            } else if self.acctType == AcctType.phone.type {
                credential = self.credentialPhone
            } else {
            }
            
            if self.profImg == nil {
                self.profImg = UIImage.init(named: "profpic_placeholder")!
            }
            Authorize.instance.createUser(acctType: self.acctType, credential: credential, email: self.email, password: self.password, fullName: fullName, region: cluster, cityState: cityState, phone: self.phoneField.text!, admin: false, adminStage: AdminStatus.none.status, sponsorDescription: self.adminDescription, profilePic: self.profImg,  view: self, completion: { (error, existingNoms) in
                if error == nil {
                    self.activityView.stopAnimating()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let legalView: SignupLegalViewController = self.storyboard!.instantiateViewController(withIdentifier: "SignupLegalViewController") as! SignupLegalViewController
                    self.navigationController?.pushViewController(legalView, animated: true)

                } else {
                    print(error!.localizedDescription)
                    self.activityView.stopAnimating()
                    self.goldenAlert(title: "Error loading user", message: "Please try again!", view: self)
                }
            })
            
        })
    }

    func createReturn() {
        self.activityView.startAnimating()
        guard self.firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            self.goldenAlert(title: "Error", message: "Please enter your first name", view: self)
            self.activityView.stopAnimating()
            return
        }
        guard self.lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            self.goldenAlert(title: "Error", message: "Please enter your last name", view: self)
            self.activityView.stopAnimating()
            return
        }
        guard self.phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && self.phoneField.isValidNumber else {
            self.goldenAlert(title: "Error", message: "Please enter a valid phone number", view: self)
            self.activityView.stopAnimating()
            return
        }
        guard self.selectedItem != nil else {
            self.goldenAlert(title: "Error", message: "Please select a city from the dropdown", view: self)
            self.activityView.stopAnimating()
            return
        }
        guard self.profImg != nil else {
            self.goldenAlert(title: "Error", message: "Please input a profile picture", view: self)
            self.activityView.stopAnimating()
            return
        }
        if self.adminDescription == nil {
            self.adminDescription = "N/A"
        }
        let fullName = "\(self.firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) \(self.lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines))"
        // let uid = Auth.auth().currentUser!.uid
        let cluster = selectedItem.cluster!
        let cityState = "\(selectedItem.title) \(selectedItem.subtitle!)"
        if Auth.auth().currentUser != nil {
            // let uid = Auth.auth().currentUser!.uid
            
            var credential: AuthCredential!
            if self.acctType == AcctType.email.type {
                let emailCred = EmailAuthProvider.credential(withEmail: self.email!, password: self.password!)
                credential = emailCred
            } else if self.acctType == AcctType.phone.type {
                credential = self.credentialPhone
            } else {
            }
           
            Authorize.instance.createUser(acctType: self.acctType, credential: credential, email: self.email, password: self.password, fullName: fullName, region: cluster, cityState: cityState, phone: self.phoneField.text!, admin: false, adminStage: AdminStatus.none.status, sponsorDescription: self.adminDescription, profilePic: self.profImg, view: self, completion: { (error, existingNoms) in
                if error != nil {
                    self.activityView.stopAnimating()
                    self.performSegue(withIdentifier: SegueId.signupDetail_signupLegal.id, sender: self)
                    /*let nomVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.nominee_screen.id) as! NomineesViewController
                     self.navigationController?.pushViewController(nomVC, animated: true) */
                }
            })
            
        } else {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                guard error == nil else {
                    self.goldenAlert(title: "Error Signing Up", message: "There was an error signing up please check your internet", view: self)
                    self.activityView.stopAnimating()
                    print(error!.localizedDescription)
                    return
                }
                let uid = Auth.auth().currentUser!.uid
                
                var credential: AuthCredential!
                if self.acctType == AcctType.email.type {
                    let emailCred = EmailAuthProvider.credential(withEmail: self.email!, password: self.password!)
                    credential = emailCred
                } else if self.acctType == AcctType.phone.type {
                    credential = self.credentialPhone
                } else {
                }
                var adminStage: Int!
                if self.admin != nil {
                    adminStage = AdminStatus.not_accepted.status
                } else {
                    adminStage = AdminStatus.none.status
                }
                // var adminDescription: String!
                if self.adminDescription == nil {
                    self.adminDescription = "N/A"
                }
                if self.admin == nil {
                    self.admin = false
                }
                if self.acctType == AcctType.phone.type {
                    
                } else {
                    Authorize.instance.createUser(acctType: self.acctType, credential: credential, email: self.email, password: self.password, fullName: fullName, region: cluster, cityState: cityState, phone: self.phoneField.text!, admin: false, adminStage: adminStage, sponsorDescription: self.adminDescription, profilePic: self.profImg,  view: self, completion: { (error, existingNoms) in
                        if error == nil {
                            if adminStage == AdminStatus.not_accepted.status {
                                DBRef.user(uid: uid).reference().child("adminAddress").setValue(self.adminAddress)
                                DBRef.admin_pending(region: cluster).reference().child(uid).child("adminAddress").setValue(self.adminAddress)
                            }
                            self.activityView.stopAnimating()
                            self.performSegue(withIdentifier: SegueId.signupDetail_signupLegal.id, sender: self)
                        } else {
                            self.activityView.stopAnimating()
                            print(error!.localizedDescription)
                            self.goldenAlert(title: "Error loading user", message: "Please try again!", view: self)
                        }
                    })
                }
                
                
            })
        }
    }
    // MARK: - Gesture Recognizer Delegate
    @objc func profPicTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            self.imgPick = GoldenImagePicker(viewController: self, type: CropType.prof_pic.type, completion: { (image) in
                guard image != nil else {
                    self.profPic.image = self.picPlaceholder
                    return
                }
                self.profPic.set(image: image, focusOnFaces: true)
                self.profPic.layer.cornerRadius  = self.profPic.frame.width / 2.0
                self.profPic.layer.masksToBounds = true
               // self.profPic.image = Toucan(image: image!).maskWithEllipse().image
                self.profImg = image!
                self.imgPick.alertView.hideView()
            })
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstNameField {
            self.lastNameField.becomeFirstResponder()
        } else if textField == self.lastNameField {
            self.locationField.becomeFirstResponder()
        } else if textField == self.locationField {
            self.phoneField.becomeFirstResponder()
        } else if textField == self.phoneField {
            self.resignFirstResponder()
            self.createReturn()
        }
        return true
    }
    
   
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.navigationController?.popViewController(animated: true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.signupDetail_signupLegal.id {
            let destinationVC = segue.destination as! SignupLegalViewController
            destinationVC.admin = self.admin
        }
    }
 

    var needsUpdated: Bool = false
    
}

extension SignupDetailViewController{
    
    func updateProfile()
    {
        var dict = [String : Any]()
        
        //                    if self.currentUser.email != self.emailField.text && self.emailField.text != "" {
        //                        guard RegexChecker.email(text: self.emailField.text!).check() else {
        //                            self.goldenAlert(title: "Error", message: "Please enter a valid email address", view: self)
        //                            return
        //                        }
        //                        dict["email"] = self.emailField.text!
        //                        self.needsUpdated = true
        //                    }
        
        
        
        if self.currentUser.fullName != "\(self.firstNameField.text ?? "") \(self.lastNameField.text ?? "")" && "\(self.firstNameField.text ?? "") \(self.lastNameField.text ?? "")" != " " {
            dict["fullName"] = "\(self.firstNameField.text ?? "") \(self.lastNameField.text ?? "")"
            self.currentUser.fullName = "\(self.firstNameField.text ?? "") \(self.lastNameField.text ?? "")"
            self.needsUpdated = true
        }
        
        if self.locationField.text != "" {
//            guard self.selectedItem != nil else {
//                self.goldenAlert(title: "Error", message: "If you would like to change your location, please choose a location from the dropdown", view: self)
//                return
//            }
            let cityState = self.locationField.text ?? ""
            if self.currentUser.cityState != cityState {
                dict["cityState"] = cityState
                self.currentUser.region = cityState
                self.needsUpdated = true
                if self.currentUser.region != self.selectedItem.cluster! {
                    dict["region"] = self.selectedItem.cluster!
                    self.currentUser.region = self.selectedItem.cluster!
                }
            }
        }
        if dict["email"] != nil {
            Auth.auth().currentUser?.updateEmail(to: self.currentUser.email, completion: { (error) in
                guard error == nil else {
                    self.goldenAlert(title: "Error", message: error!.localizedDescription, view: self)
                    return
                }
                self.currentUser.email = self.currentUser.email
                self.updateUser(dict: dict)
            })
        } else {
            self.updateUser(dict: dict)
        }
    }
    
    func updateUser(dict: [String : Any]) {
        
         let ref = DBRef.user(uid: self.currentUser.uid).reference().child("url")
        ImageSaving(image: profPic.image!).saveProfPic(userUID: self.currentUser.uid, completion: { (error, url) in
            guard error == nil && url != nil else {
                let err = error! as NSError
                
                print(err)
                
               // completion(err)
                return
            }
            ref.setValue(url!)
            
            
            if let view = appDelegate.nomineeController {
                self.goldenAlert(title: "Congratulations", message: "Your profile update successfully", view: view)
            }
            //self.navigationController?.dismiss(animated: false, completion:nil);
            self.navigationController?.popViewController(animated: true)
            //completion(nil)
            print("nil")
        })
        
        
        
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
            
            guard appDelegate.nomineeController != nil else{
                return
            }
            
            if let view = appDelegate.nomineeController {
                self.goldenAlert(title: "Congratulations", message: "Your profile update successfully", view: view)
            }
            //self.navigationController?.dismiss(animated: false, completion:nil);
            self.navigationController?.popViewController(animated: true)
            
            
            // })
        }
    }
}

