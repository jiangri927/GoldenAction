//
//  ThreeExistingUserCreateNomination.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 25/01/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
//import MaterialComponents
//import MaterialComponents.MaterialTextFields
import SwiftEventBus
import PhoneNumberKit
import SwiftyContacts
import SearchTextField
class ThreeExistingUserCreateNomination: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var cardView: ShadowedView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: PhoneNumberTextField!
    @IBOutlet weak var titleView: ShadowedView!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var locationField: SearchTextField!
    var selectedItem: SearchTextFieldItem!
    var searches = [SearchTextFieldItem]()
    
    var currentUser: Person!
    var personType: Int! // 0 for new, 1 for contacts, 2 to search someone
    var nominationType: String!
    
    var selectedPersonCityState: String?
    var selectedPersonCluster: String?
    var selecteduid: String?
    var selectedPhone: String?
    var selectedEmail: String?
    var selectedName: String?
    let app_text = Colors.app_text.generateColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designSearchField()
        self.designButtons()
        self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.designCard(cardView: self.cardView)
        self.designCard(cardView: self.titleView)
        self.swipeDismiss()
        self.tapDismiss()
        self.setTextField()
        if self.personType != PersonType.new.id {
            self.hideFields()
            self.startQuery()
        } else {
            self.showFields()
        }
        // Do any additional setup after loading the view.
    }
    func swipeDismiss() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureRight(_:)))
        gesture.direction = .right
        self.innerView.isUserInteractionEnabled = true
        self.outerView.isUserInteractionEnabled = true
        self.innerView.addGestureRecognizer(gesture)
        self.outerView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
    }
    func hideFields() {
        // self.locationField.isHidden = true
        self.firstName.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Search for User Here")
        self.lastName.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Full Name")
        self.emailField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Email")
        self.phoneField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Phone")
        self.locationField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Location")
        
    }
    func showFields() {
        // self.locationField.isHidden = false
        self.firstName.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Enter first name here...")
        self.lastName.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Enter last name here...")
        self.emailField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Enter email here...")
        self.phoneField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Enter phone here...")
        self.locationField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Enter location here...")
    }
    
    func designSearchField() {
        self.locationField.textColor = self.app_text
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.locationField.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title), \(item.subtitle!)")
            self.selectedItem = item
            self.resignFirstResponder()
        }
        // self.locationField.direction = .up
        self.locationField.theme.bgColor = UIColor.black
        self.locationField.theme.fontColor = app_text
        self.locationField.theme.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        self.locationField.itemSelectionHandler = closure
        self.locationField.borderStyle = .none
    }
    
    @IBAction func userTyping(_ sender: Any) {
        self.locationField.showLoadingIndicator()
        SearchFirebaseDB.instance.loadCityQuery(query: self.locationField.text!){(searches) in
            guard searches != nil else {
                return
            }
            self.searches = searches!
            self.locationField.filterItems(searches!)
            self.locationField.startSuggestingInmediately = true
            self.locationField.stopLoadingIndicator()
        }
    }
    
    func startQuery() {
        self.firstName.reactive.text.observeNext { (text) in
            guard text != nil else {
                return
            }
            if text!.count >= 2 {
                //                SearchAlg.instance.loadUserQuery(query: text, completion: { (searches) in
                //                    guard searches != nil else {
                //                        return
                //                    }
                //                    let relevant = searches![0]
                //                    self.lastName.text = relevant.title
                //                    self.emailField.text = relevant.email!
                //                    self.phoneField.text = relevant.phone!
                //                    self.locationField.text = relevant.subtitle!
                //                    self.selectedPersonCluster = relevant.cluster!
                //                    self.selecteduid = relevant.uidPerson!
                //                    self.selectedPersonCityState = relevant.subtitle!
                //
                //                })
            }
        }
    }
    
    
    func nextButtonSetup() {
        self.selectedName = "\(self.firstName.text ?? "sudesh")"
        self.selectedPhone = "\(self.phoneField.text!)"
        self.selectedPersonCityState = "\(self.locationField.text!)"
        self.selectedEmail = "\(self.emailField.text!)"
        
        if self.personType != PersonType.exisiting.id {
            guard self.selectedPhone != "" else {
                self.error(title: "Error", message: "Please enter in the phone number of the person you would like to nominate", error: nil)
                return
            }
            guard self.selectedName != "" else {
                self.error(title: "Error", message: "Please enter in the name of the person you would like to nominate", error: nil)
                return
            }
            guard self.selectedEmail != "" else {
                self.error(title: "Error", message: "Please enter in the email of the person you would like to nominate", error: nil)
                return
            }
            
            //sudesh
            self.selectedPersonCluster = selectedItem.cluster!
            self.selectedPersonCityState = "\(selectedItem.title) \(selectedItem.subtitle!)"
            guard self.selectedPersonCluster != nil || self.selectedPersonCityState != nil else {
                self.error(title: "Error", message: "Please enter the location of the person you would like to nominate. City, State", error: nil)
                return
            }
            let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.confirm_create_nom.id) as! ConfirmCreateNominationViewController
            
            confirmVC.selectedPhone = self.selectedPhone
            confirmVC.selectedName  = self.selectedName
            confirmVC.selectedEmail = self.selectedEmail
            confirmVC.selectedPersonCluster = self.selectedPersonCluster
            confirmVC.selectedPersonCityState = self.selectedPersonCityState
            confirmVC.nominationType = self.nominationType
            confirmVC.personType = self.personType
            self.navigationController?.pushViewController(confirmVC, animated: true)
            
            /*   let finalItem = DispatchWorkItem {
             self.navigationController?.pushViewController(confirmVC, animated: true)
             }
             let workItem = DispatchWorkItem {
             confirmVC.selectedPhone = self.selectedPhone
             confirmVC.selectedName = self.selectedName
             confirmVC.selectedEmail = self.selectedEmail
             confirmVC.selectedPersonCluster = self.selectedPersonCluster
             confirmVC.selectedPersonCityState = self.selectedPersonCityState
             confirmVC.nominationType = self.nominationType
             confirmVC.personType = self.personType
             // confirmVC.currentUser = self.currentUser
             DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: finalItem)
             }
             DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: workItem) */
        } else {
            guard self.selectedPhone != "" else {
                self.error(title: "Error", message: "Please use the top bar to search for an exisiting user to nominate", error: nil)
                return
            }
            guard self.selecteduid != nil else {
                self.error(title: "Error", message: "Please use the top bar to search for an exisiting user to nominate", error: nil)
                return
            }
            self.findAndConfirmPerson(uid: self.selecteduid!)
        }
    }
    
    func findAndConfirmPerson(uid: String) {
        let ref = DBRef.user(uid: uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let person = Person(dict: dict)
                self.segueToConfirm(person: person)
            }
        }
    }
    
    func segueToConfirm(person: Person) {
        let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.confirm_create_nom.id) as! ConfirmCreateNominationViewController
        let finalItem = DispatchWorkItem {
            self.navigationController?.pushViewController(confirmVC, animated: true)
        }
        let workItem = DispatchWorkItem {
            confirmVC.selectedPerson = person
            confirmVC.nominationType = self.nominationType
            confirmVC.personType = self.personType
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: finalItem)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: workItem)
        
    }
    func designButtons() {
        self.designButton(button: self.nextButton)
        self.designButton(button: self.backButton)
        
        self.backButton.reactive.tap.observeNext {
            self.navigationController?.popViewController(animated: true)
        }
        self.nextButton.reactive.tap.observeNext {
            self.nextButtonSetup()
        }
    }
    func designButton(button: UIButton) { //MDCRaisedButton
        button.setBackgroundColor(UIColor.white, for: [])
        button.setTitleColor(UIColor.black, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 2.0
        button.layer.borderColor = Colors.black.generateColor().cgColor
        button.layer.masksToBounds = false
    }
    
    func buttonShadow(button: UIButton) {
        button.layer.shadowColor = Colors.app_color.generateColor().cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 1, height: 3)
    }
    func designCard(cardView: ShadowedView) {
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 15.0
        cardView.layer.masksToBounds = true
        cardView.layer.shadowColor = Colors.white.generateColor().cgColor
        cardView.layer.shadowOpacity = 0.9
        cardView.layer.shadowRadius = 3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    func setTextField() {
        
        // self.firstName.becomeFirstResponder()
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.emailField.delegate = self
        self.phoneField.delegate = self
        self.locationField.delegate = self
        self.txtField(textField: self.locationField)
        self.txtField(textField: self.firstName)
        self.txtField(textField: self.lastName)
        self.txtField(textField: self.emailField)
        self.txtField(textField: self.phoneField)
        //textFieldControllerFloating = MDCTextInputControllerUnderline(textInput: self.firstName) // Hold on as a property
    }
    func txtField(textField: UITextField) {
        textField.layer.borderColor = Colors.app_text.generateColor().cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 15.0
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor.black
        textField.textColor = Colors.app_text.generateColor()
    }
    func colors() {
        // Step 2: Create or get a color scheme
        // let colorScheme = MDCSemanticColorScheme()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension ThreeExistingUserCreateNomination: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstName {
            self.lastName.becomeFirstResponder()
        } else if textField == self.lastName {
            self.locationField.becomeFirstResponder()
        } else if textField == self.locationField {
            self.emailField.becomeFirstResponder()
        } else if textField == self.emailField {
            self.phoneField.becomeFirstResponder()
        } else if textField == self.phoneField {
            self.resignFirstResponder()
        }
        
        print(textField.text!)
        return true
    }
    
    
}
