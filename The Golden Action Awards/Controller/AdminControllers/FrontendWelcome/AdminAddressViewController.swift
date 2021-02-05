//
//  AdminAddressViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/27/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SearchTextField
import Firebase
import NYAlertViewController

class AdminAddressViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var aptField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: SearchTextField!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var whyButton: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    var adminDescription: String!
    var currentUser: Person!
    var returningUser: Bool!
    var emailField: UITextField!
    
    var sts = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MA", "MD", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designInputViews(outer: outerView, inner: innerView, main: self.view)
        self.designButtons()
        self.designSpecificFields()
        self.tapDismiss()
        self.addressField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    func designButtons() {
        self.whyButton.setBackgroundColor(UIColor.clear, for: [])
        self.designButton(button: self.submitButton)
        self.designButton(button: self.backButton)
        self.backButton.addTarget(self, action: #selector(backDidTap(_:)), for: .touchUpInside)
        self.submitButton.addTarget(self, action: #selector(self.submitDidTap(_:)), for: .touchUpInside)
        self.whyButton.addTarget(self, action: #selector(displayWhyButton(_:)), for: .touchUpInside)
        
    }
    func designButton(button: UIButton) {
        button.setBackgroundColor(Colors.app_text.generateColor(), for: [])
        button.setTitleColor(UIColor.black, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
    }
    @objc func backDidTap(_ sender: UIButton!) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func displayWhyButton(_ sender: UIButton!) {
        self.goldenAlert(title: "Info", message: "As a nomination sponsor you will be tasked with shipping awards to individuals houses, in order to properly do this, we will auto generate the shipping label for you. Therefore, we will need your address. Thanks!", view: self)
    }
    
    @objc func submitDidTap(_ sender: UIButton!) {
        guard self.stateField.text != "" && self.sts.contains(self.stateField.text!) else {
            self.goldenAlert(title: "Please enter a proper state abbreviation", message: "", view: self)
            return
        }
        guard self.cityField.text != "" else {
            self.goldenAlert(title: "Please enter you city", message: "", view: self)
            return
        }
        guard self.addressField.text != "" else {
            self.goldenAlert(title: "Please enter you address", message: "", view: self)
            return
        }
        guard self.zipField.text != "" else {
            self.goldenAlert(title:  "Please enter you zip code", message: "", view: self)
            return
        }
        
        if self.currentUser != nil && self.currentUser.acctType != AcctType.anonymous.type {
            if self.currentUser.acctType == AcctType.phone.type && !RegexChecker.email(text: self.currentUser.email).check() {
                self.displayEmailAlert(sponsorDescription: self.adminDescription)
            } else {
                self.currentUser.saveAdminPending(sponsorDescription: self.adminDescription) { (complete) in
                    if complete! {
                        self.performSegue(withIdentifier: SegueId.sponsoraddress_congrats.id, sender: self)
                    }
                }
            }
        } else {
            self.performSegue(withIdentifier: SegueId.sponsoraddress_create.id, sender: self)
        }
    }
    func designSearchField() {
        
    }
    func designSpecificFields() {
        self.designFields(field: self.addressField)
        self.designFields(field: self.cityField)
        self.designFields(field: self.stateField)
        self.designFields(field: self.zipField)
        self.designFields(field: self.aptField)
        self.zipField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter Zip Code...")
        self.cityField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter City...")
        self.aptField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter Apt/Suite...")
        self.stateField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter State...")
        self.addressField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter Address...")
        self.zipField.keyboardType = .numberPad
        self.cityField.keyboardType = .default
        self.aptField.keyboardType = .default
        self.addressField.keyboardType = .default
        self.stateField.keyboardType = .alphabet
        self.stateField.filterStrings(self.sts)
        self.stateField.theme.bgColor = UIColor.black
        self.stateField.theme.font = Fonts.hira_pro_six.generateFont(size: 14.0)
        self.stateField.theme.fontColor = Colors.app_text.generateColor()
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.stateField.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title)")
            self.resignFirstResponder()
        }
        self.stateField.itemSelectionHandler = closure
    }
    func designFields(field: UITextField) {
        field.borderStyle = .none
        field.textColor = Colors.app_text.generateColor()
        field.backgroundColor = UIColor.clear
        field.keyboardAppearance = .dark
        field.delegate = self
        
    }
    
    func findAcctType() {
        if Auth.auth().currentUser != nil {
            let ref = DBRef.user(uid: Auth.auth().currentUser!.uid).reference()
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : Any] {
                    let person = Person(dict: dict)
                    self.currentUser = person
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func displayEmailAlert(sponsorDescription: String) {
        // Set a title and message
        // Customize appearance as desired
        let workItem = DispatchWorkItem {
            let alertVC = NYAlertViewController()
            let app_color = Colors.app_text.generateColor()
            
            // Background Color and Corner Design
            alertVC.alertViewBackgroundColor = Colors.black.generateColor()
            
            alertVC.buttonCornerRadius = 10.0
            // Title and Message Designs
            alertVC.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
            alertVC.titleColor = app_color
            alertVC.messageFont = Fonts.hira_pro_three.generateFont(size: 17.0)
            alertVC.messageColor = app_color
            
            // Cancel Then Default Button Designs
            alertVC.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
            alertVC.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
            alertVC.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
            alertVC.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
            alertVC.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
            alertVC.buttonColor = Colors.nom_detail_innerBorder.generateColor()
            
            alertVC.title = "Last Thing!"
            alertVC.message = "We need your email to become a nomination sponsor to email your acceptance and instructions!"
            alertVC.buttonCornerRadius = 20.0
            
            
            
            // Actions
            alertVC.swipeDismissalGestureEnabled = true
            alertVC.backgroundTapDismissalGestureEnabled = true
            alertVC.addTextField(configurationHandler: { (textField) in
                self.emailField = textField
                self.emailField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Enter email here:")
                self.emailField.borderStyle = .roundedRect
                self.emailField.layer.cornerRadius = 10.0
                self.emailField.layer.masksToBounds = false
            })
            let okayAction = NYAlertAction(title: "Add!", style: .default) { (_) in
                guard self.emailField.text != "" && RegexChecker.email(text: self.emailField.text).check() else {
                    alertVC.dismiss(animated: true, completion: nil)
                    self.goldenAlert(title: "Error", message: "Please enter a valid email address", view: self)
                    return
                }
                let workItem = DispatchWorkItem {
                    self.currentUser.saveAdminPending(sponsorDescription: sponsorDescription) { (complete) in
                        if complete! {
                            alertVC.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: SegueId.sponsordescription_congrats.id, sender: self)
                        }
                    }
                    
                }
                self.currentUser.email = self.emailField.text!
                DBRef.user(uid: self.currentUser.uid).reference().updateChildValues(["email" : self.emailField.text!])
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: workItem)
            }
            let cancelAction = NYAlertAction(title: "Cancel", style: .default) { (_) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okayAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: workItem)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == SegueId.sponsoraddress_create.id {
//            let destinationVC = segue.destination as! SignupEmailViewController
//            destinationVC.admin = true
//            destinationVC.adminDescription = self.adminDescription
//            
//        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressField {
            self.aptField.becomeFirstResponder()
        } else if textField == aptField {
            self.cityField.becomeFirstResponder()
        } else if textField == cityField {
            self.stateField.becomeFirstResponder()
            self.stateField.becomeFirstResponder()
        } else if textField == stateField {
            self.zipField.becomeFirstResponder()
        } else if textField == zipField {
            self.submitDidTap(self.submitButton)
        }
        return true
    }

}










