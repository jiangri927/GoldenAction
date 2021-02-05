//
//  ThreeCreateNominationViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SwiftEventBus
import PhoneNumberKit
import SwiftyContacts
import SearchTextField
import DropDown
import DGActivityIndicatorView

extension UIScrollView {
    func updateContentView() {
        let height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
        contentSize.height = height + (height * 0.5)
    }
}

class ThreeCreateNominationViewController: UIViewController {
    
    @IBOutlet weak var titleLbl :UILabel!
    @IBOutlet weak var backButton: UIButton! //MDCRaisedButton!
    @IBOutlet weak var nextButton: UIButton! //MDCRaisedButton!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var cardView: ShadowedView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: PhoneNumberTextField!
    @IBOutlet weak var titleView: ShadowedView!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var locationField: SearchTextField!
    
    @IBOutlet weak var scrollView:UIScrollView!
    
    var selectedItem: SearchTextFieldItem!
    var searches = [SearchTextFieldItem]()
    
    var personSearches = [Person]()
    var userNameDropDown = DropDown()
    
    var currentUser: Person!
    var personType: Int? // 0 for new, 1 for contacts, 2 to search someone
    var nominationType: String!
    
    var selectedPersonCityState: String?
    var selectedPersonCluster: String?
    var selecteduid: String?
    var selectedPhone: String?
    var selectedEmail: String?
    var selectedName: String?
    let app_text = Colors.app_text.generateColor()
    
    
    var activityView:DGActivityIndicatorView!
    
    var tabOnUserText : String?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.updateContentView()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadIndicatorView()
        self.designSearchField()
        self.designButtons()
        // self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.designCard(cardView: self.cardView)
        self.swipeDismiss()
        self.tapDismiss()
        self.setTextField()
        
        tabOnUserText = "initial"
        if self.personType != PersonType.new.id {
            self.hideFields()
            self.startQuery()
        } else {
            self.showFields()
        }
        
        tabOnUserText = "Ontap"
        self.configureTitleView()
        
        self.scrollView.updateContentView()
        
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
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        //activityView.startAnimating()
    }
    
    func configureTitleView(){
        
        let imageColor = self.gradient(size: self.titleLbl.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.titleLbl.textColor = UIColor.init(patternImage: imageColor!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func swipeDismiss() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureRight(_:)))
        gesture.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(gesture)
    }
    
    func hideFields() {
        self.firstName.attributedPlaceholder     = LoginStrings.placeholder_text.generateString(text: "Search for User Here")
        self.lastName.attributedPlaceholder      = LoginStrings.placeholder_text.generateString(text: "Full Name")
        self.emailField.attributedPlaceholder    = LoginStrings.placeholder_text.generateString(text: "Email")
        self.phoneField.attributedPlaceholder    = LoginStrings.placeholder_text.generateString(text: "Phone")
        self.locationField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: " Location")
        
    }
    
    func showFields() {
        self.firstName.attributedPlaceholder     = LoginStrings.placeholder_text.generateString(text: "First name")
        self.lastName.attributedPlaceholder      = LoginStrings.placeholder_text.generateString(text: "Last name")
        self.emailField.attributedPlaceholder    = LoginStrings.placeholder_text.generateString(text: "Email")
        self.phoneField.attributedPlaceholder    = LoginStrings.placeholder_text.generateString(text: "Contact")
        self.locationField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Location")
    }
    
    func designSearchField() {
        self.userNameDropDown.anchorView = self.firstName
        
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.locationField.textColor = UIColor.white
            self.locationField.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title), \(item.subtitle!)")
            self.selectedItem = item
            self.resignFirstResponder()
        }
        
        self.locationField.theme.bgColor        = UIColor.black
        self.locationField.backgroundColor      = UIColor.black
        self.locationField.theme.fontColor      = app_text
        self.locationField.theme.font           = Fonts.hira_pro_three.generateFont(size: 17.0)
        self.locationField.itemSelectionHandler = closure
        self.locationField.borderStyle          = .none
    }
    
    @IBAction func userTyping(_ sender: Any) {
        self.locationField.showLoadingIndicator()
        
        
//        SearchFirebaseDB.instance.loadCityQuery(query: self.locationField.text!){(searches) in
//            guard searches != nil else {
//                return
//            }
//            self.searches = searches!
//            self.locationField.filterItems(searches!)
//            self.locationField.startSuggestingInmediately = true
//            self.locationField.stopLoadingIndicator()
//        }
        
        
        
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
    
    func startQuery() {
        self.firstName.reactive.text.observeNext { (text) in
            guard text != nil else {
                return
            }
            
            if(self.tabOnUserText == "initial"){
                 return
            }
            
           // if text!.count >= 2 {
                
                let oneCreate1 = self.storyboard?.instantiateViewController(withIdentifier: "ExistingUserList") as! ExistingUserList
                let nav = UINavigationController.init(rootViewController: oneCreate1)
                nav.navigationBar.backgroundColor = .yellow 
                self.present(nav, animated: true, completion: {
                    oneCreate1.doneClouser = { person in
                        
                        self.lastName.text = person.fullName
                        self.emailField.text = person.email
                        self.phoneField.text = person.phone
                        self.locationField.text = person.cityState
                        
                        self.selectedPersonCluster = person.region
                        self.selecteduid = person.uid
                        self.selectedPersonCityState = person.cityState
                        self.personType = 0
                        print(self.personType ?? 0)
                        
                    }
                })
           // }
        }
    }
    
    func nextButtonSetup() {
        
        self.selectedName = "\(self.firstName.text ?? "") \(self.lastName.text ?? "")"
        self.selectedPhone = "\(self.phoneField.text!)"
        self.selectedPersonCityState = "\(self.locationField.text!)"
        self.selectedEmail = "\(self.emailField.text!)"
        
        
        let perT = self.personType
        let perExirId = PersonType.exisiting.id
        
        
        if perT != perExirId {
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
//            self.selectedPersonCluster = selectedItem.cluster!
//            self.selectedPersonCityState = "\(selectedItem.title) \(selectedItem.subtitle!)"
            
            
            guard self.selectedPersonCluster != nil || self.selectedPersonCityState != nil else {
                self.error(title: "Error", message: "Please enter the location of the person you would like to nominate. City, State", error: nil)
                return
            }
            let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.confirm_create_nom.id) as! ConfirmCreateNominationViewController
            
            confirmVC.selectedPhone           = self.selectedPhone
            confirmVC.selectedName            = self.selectedName
            confirmVC.selectedEmail           = self.selectedEmail
            confirmVC.selectedPersonCluster   = self.selectedPersonCluster
            confirmVC.selectedPersonCityState = self.selectedPersonCityState
            confirmVC.nominationType          = self.nominationType
            confirmVC.personType              = self.personType
            self.navigationController?.pushViewController(confirmVC, animated: true)
            
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
    
    func designButton(button: UIButton) {
        let imageColor = self.gradient(size: button.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        button.setBackgroundColor(.clear, for: [])
        button.setTitleColor(.white, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        button.layer.masksToBounds = true
    }
    
    func designCard(cardView: ShadowedView) {
        cardView.backgroundColor = .clear
        cardView.layer.masksToBounds = true
    }
    
    func setTextField() {
        
        self.firstName.delegate = self
        self.firstName.backgroundColor = .black
        self.firstName.setBottomBorder()
        
        self.lastName.delegate = self
        self.lastName.backgroundColor = .black
        self.lastName.setBottomBorder()
        
        self.emailField.delegate = self
        self.emailField.keyboardType = .emailAddress
        self.emailField.backgroundColor = .black
        self.emailField.setBottomBorder()
        
        self.phoneField.delegate = self
        self.phoneField.keyboardType = .numberPad
        self.phoneField.backgroundColor = .black
        self.phoneField.setBottomBorder()
        
        self.locationField.delegate = self
        self.locationField.backgroundColor = .black
        self.locationField.setBottomBorder()
        
        
    }
    
    func txtField(textField: UITextField) {
        let imageColor = self.gradient(size: textField.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        textField.backgroundColor = .clear
        textField.textColor = .white
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
extension ThreeCreateNominationViewController: UITextFieldDelegate {
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
