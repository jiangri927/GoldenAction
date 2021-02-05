//
//  CharityViewControler.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 08/02/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit
import SwiftEventBus
import PhoneNumberKit
import SwiftyContacts
import SearchTextField
import DropDown
import DGActivityIndicatorView

class CharityViewControler: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var charityNameField: UITextField! //SearchTextField!
    @IBOutlet weak var charityDetails:UILabel!
    
    @IBOutlet weak var newCharityView:UIView!
    @IBOutlet weak var existingCharityView:UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var selectedItem: SearchTextFieldItem!
    var searches = [SearchTextFieldItem]()
    
    var charitySearches = [Charity]()
    var charityDropDown = DropDown()
    
    var currentUser: Person!
    var personType: Int! // 0 for new, 1 for contacts, 2 to search someone
    var nominationType: String!
    
    var selectedPersonCityState: String?
    var selectedPersonCluster: String?
    var selecteduid: String?
    var selectedPhone: String?
    var selectedEmail: String?
    var selectedName: String?
    var selectedCharity : Charity?
    let app_text = Colors.app_text.generateColor()
    var activityView:DGActivityIndicatorView!
    
    var doneClouser: ((Charity) -> Void)?
    
  /*  lazy var ExistingCharityViewController: NewCharityViewController = {
        
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NewCharityViewController") as! NewCharityViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        viewController.parentController = self
        return viewController
        
    }() */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpTitleLbl()
        self.loadIndicatorView()
        self.designButtons()
        self.swipeDismiss()
        self.tapDismiss()
        self.setTextField()
        setupView()
        self.hideFields()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chooseSelectedCharity), name: NSNotification.Name(rawValue: "SelectCharity"), object: nil)
        
        self.segmentedControl.tintColor = Colors.nom_detail_innerBorder.generateColor()
        self.setupSegmentedControl()
        self.newCharityView.isHidden = true
    }
    
    @objc func refreshList(notification: NSNotification){
        print("parent method is called")
        self.nextButtonSetup()
    }
    
    @objc func chooseSelectedCharity(notification: NSNotification){
        print("parent method is called")
        let userInfo : [String:Charity!] = notification.userInfo as! [String:Charity!]
        self.selectedCharity = userInfo["charity"]!
    }
    
    func setUpTitleLbl(){
        let imageColor = self.gradient(size: self.titleLbl.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
       self.titleLbl.textColor = UIColor.init(patternImage: imageColor!)
        
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        //activityView.startAnimating()
    }
    
    func swipeDismiss() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureRight(_:)))
        gesture.direction = .right
        self.view.addGestureRecognizer(gesture)
    }
    func hideFields() {
        // self.locationField.isHidden = true
//        self.charityNameField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Search for User Here")
    }
    func showFields() {
        // self.locationField.isHidden = false
     //   self.charityNameField.attributedPlaceholder = LoginStrings.placeholder_text.generateString(text: "Enter first name here...")
    }
    
    func designSearchField() {
        // Adding textfield as a anchore vire to drop down
      //  self.charityDropDown.anchorView = self.charityNameField
    }
    
    func startQuery() {
        self.charityNameField.reactive.text.observeNext { (text) in
            guard text != nil else {
                self.activityView.stopAnimating()
                return
            }
            if text!.count >= 2 {
                self.activityView.startAnimating()
                SearchFirebaseDB.instance.loadCharityQueryFromCollection(query: self.charityNameField.text!){(searches, nomsName) in
                    guard searches != nil else {
                        self.activityView.stopAnimating()
                        return
                    }
                    self.charitySearches = searches!
                    self.charityDropDown.dataSource = nomsName!
                    self.charityDropDown.show()
                    self.activityView.stopAnimating()
                    self.charityNameField.resignFirstResponder()
                }
            }
        }
    }
    
    
    func nextButtonSetup() {
        guard self.selectedCharity != nil else {
            goldenAlert(title: "Charity Error!", message: "Charity should not be blanked. Please select the charity.", view: self)
            return
        }
        doneClouser!(self.selectedCharity!)
        self.dismiss(animated: true, completion: nil)
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
    
    func designAllInputViews(outer: UIView, inner: UIView, main: UIView){
        // Inherited
        main.backgroundColor = Colors.nom_detail_firstBackground.generateColor()
        // Outer
        outer.backgroundColor = Colors.nom_detail_outerBackground.generateColor()
        outer.layer.cornerRadius = 15.0
        outer.layer.masksToBounds = true
        // Inner
        inner.backgroundColor       = Colors.nom_detail_innerBackground.generateColor()
        inner.layer.borderColor     = Colors.nom_detail_innerBorder.generateColor().cgColor
        inner.layer.borderWidth     = 1.0
        inner.layer.cornerRadius    = 15.0
        inner.layer.masksToBounds   = true
    }
    
    func designButtons() {
        self.designButton(button: self.nextButton, isFill:true)
        self.designButton(button: self.backButton, isFill:false)
        
        self.backButton.reactive.tap.observeNext {
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        self.nextButton.reactive.tap.observeNext {
            self.nextButtonSetup()
        }
    }
    
    func designButton(button:UIButton, isFill:Bool ) {
        let imageColor = self.gradient(size: button.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        if isFill {
            button.backgroundColor = UIColor.init(patternImage: imageColor!)
        }else{
            button.setBackgroundColor(UIColor.clear, for: [])
        }
        
        button.setTitleColor(UIColor.white, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        button.layer.masksToBounds = true
    }
    
    func buttonShadow(button: UIButton) {
        button.layer.shadowColor = Colors.app_color.generateColor().cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 1, height: 3)
    }
    func designCard(cardView: UILabel) {
        cardView.textColor = Colors.app_text.generateColor()
        cardView.backgroundColor = UIColor.black
        cardView.layer.cornerRadius = 10.0
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = Colors.app_text.generateColor().cgColor
        cardView.layer.shadowOpacity = 0.7
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = true
        cardView.layer.shadowOffset = CGSize(width: 1, height: 3)
    }
    func setTextField() {
        
        // self.firstName.becomeFirstResponder()
        //self.charityNameField.delegate = self
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

extension CharityViewControler: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.charityNameField {
            self.resignFirstResponder()
        }
        print(textField.text!)
        return true
    }
    
    
}

extension CharityViewControler{
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        self.segmentedControl.removeAllSegments()
        self.segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        self.segmentedControl.layer.borderWidth = 2
        self.segmentedControl.layer.masksToBounds = true
        self.segmentedControl.layer.cornerRadius = 8
        self.segmentedControl.selectedSegmentIndex = 0

        segmentedControl.insertSegment(withTitle: "Existing", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "New", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
        
        let imageColor = self.gradient(size: self.segmentedControl.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.segmentedControl.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        self.segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: .selected)
       self.updateGradientBackground()
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        self.updateGradientBackground()
        if sender.selectedSegmentIndex == 0 {
            self.newCharityView.isHidden  = true
            self.existingCharityView.isHidden = false
            
        }else{
            self.existingCharityView.isHidden = true
            self.newCharityView.isHidden  = false
        }
    }

}

extension CharityViewControler{
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
           // self.externalView.isHidden = true
            //remove(asChildViewController: ExistingCharityViewController)
        } else {
            //add(asChildViewController: ExistingCharityViewController)
            //self.externalView.isHidden = false
            //ExistingCharityViewController.parentController = self
            //NewCharityPopup.instance.enterNewCharity(view: self)
        }
    }

    func setupView() {
        setupSegmentedControl()
        updateView()
    }
    
}

extension CharityViewControler{
    
    fileprivate func updateGradientBackground() {
        let image = self.gradient(size: self.segmentedControl.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])!
        
        let sortedViews = self.segmentedControl.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        for (index, view) in sortedViews.enumerated() {
            if index == self.segmentedControl.selectedSegmentIndex {
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
