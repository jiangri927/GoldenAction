//
//  OneCreateNominationViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import MaterialComponents
import Spruce
import Bond
import TwicketSegmentedControl
class OneCreateNominationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var cardView: ShadowedView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var backButton: MDCRaisedButton!
    @IBOutlet weak var nextButton: MDCRaisedButton!
    @IBOutlet weak var head: UIButton!
    @IBOutlet weak var heart: UIButton!
    @IBOutlet weak var health: UIButton!
    @IBOutlet weak var hand: UIButton!
    
    
    
    
    var phaseOne = true
    
    var currentUser: Person!
    // Step 2: Create or get a button scheme
    let buttonScheme = MDCButtonScheme()
    let appColor = Colors.app_text.generateColor()
    let blackColor = Colors.black.generateColor()
    
    var nominationType: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard self.currentUser != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        print(self.currentUser.acctType)
        print(self.currentUser.purchasedNoms)
        // self.checkVerification(currentUser: self.currentUser, message: "You must have an account to create a nomination")
        /*let backWorkItem = DispatchWorkItem {
            self.dismiss(animated: true, completion: nil)
        } */
        // self.checkVerification(currentUser: self.currentUser, message: "You must have an account to create a nomination", workitem: backWorkItem)
        // self.checkNominations(currentUser: self.currentUser, messages: "You need to purchase a nomination to create one", workitem: backWorkItem)
        self.tapDismiss()
        self.designButtons()
        self.designCard()
        self.swipeDismiss()
        self.designRoots()
        self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.setupDownGesture()
        self.setupNextButton()
        self.head.addTarget(self, action: #selector(headClicked(_:)), for: .touchUpInside)
        self.hand.addTarget(self, action: #selector(handClicked(_:)), for: .touchUpInside)
        self.heart.addTarget(self, action: #selector(heartClicked(_:)), for: .touchUpInside)
        self.health.addTarget(self, action: #selector(healthClicked(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // self.moveToPage(0)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swipeDismiss() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureDown(_:)))
        gesture.direction = .down
        self.innerView.isUserInteractionEnabled = true
        self.outerView.isUserInteractionEnabled = true
        self.innerView.addGestureRecognizer(gesture)
        self.outerView.addGestureRecognizer(gesture)
        
        
    }
    func designRoots() {
        self.designRootButton(button: self.head)
        self.designRootButton(button: self.heart)
        self.designRootButton(button: self.hand)
        self.designRootButton(button: self.health)
    }
    func themeButton(button: UIButton) {
        //self.buttonScheme.layer.cornerRadius = 15.0
        self.buttonScheme.cornerRadius = 15.0
        self.buttonScheme.minimumHeight = 30.0
        // let scheme = MatTheming.instance.generateColorScheme()
        // MDCTextButtonThemer.applyScheme(MatTheming.instance.generateColorScheme() as! MDCButtonScheming, to: button)
    }
    func designButtons() {
        self.designButton(button: self.nextButton)
        self.designButton(button: self.backButton)
        /*self.nextButton.reactive.tap.observeNext {
            let twoVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.two_create_nom.id) as! TwoCreateNominationViewController
            twoVC.currentUser = self.currentUser
            self.navigationController?.pushViewController(twoVC, animated: true)
        }*/
        self.backButton.reactive.tap.observeNext {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func designButton(button: UIButton) {
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
    func designCard() {
        self.cardView.backgroundColor = UIColor.white
        self.cardView.layer.cornerRadius = 15.0
        self.cardView.layer.masksToBounds = true
        self.cardView.layer.shadowColor = Colors.white.generateColor().cgColor
        self.cardView.layer.shadowOpacity = 0.9
        self.cardView.layer.shadowRadius = 3
        self.cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    @objc func headClicked(_ sender:MDCRaisedButton ) {
        if self.head.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.head.key
            self.buttonClicked(button: self.head)
            self.buttonUnclicked(button: self.heart)
            self.buttonUnclicked(button: self.hand)
            self.buttonUnclicked(button: self.health)
        }
    }
    @objc func handClicked(_ sender: MDCRaisedButton) {
        if self.hand.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.hand.key
            self.buttonClicked(button: self.hand)
            self.buttonUnclicked(button: self.heart)
            self.buttonUnclicked(button: self.head)
            self.buttonUnclicked(button: self.health)
        }
    }
    @objc func heartClicked(_ sender: MDCRaisedButton) {
        if self.heart.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.heart.key
            self.buttonClicked(button: self.heart)
            self.buttonUnclicked(button: self.hand)
            self.buttonUnclicked(button: self.head)
            self.buttonUnclicked(button: self.health)
        }
    }
    @objc func healthClicked(_ sender: MDCRaisedButton) {
        if self.health.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.health.key
            self.buttonClicked(button: self.health)
            self.buttonUnclicked(button: self.hand)
            self.buttonUnclicked(button: self.head)
            self.buttonUnclicked(button: self.heart)
        }
    }
    func buttonUnclicked(button: UIButton) {
        button.backgroundColor = self.blackColor
        button.setTitleColor(self.appColor, for: [])
    }
    func buttonClicked(button: UIButton) {
        button.backgroundColor = self.appColor
        button.setTitleColor(self.blackColor, for: [])
    }
    func designRootButton(button: UIButton) {
        button.backgroundColor = self.blackColor
        button.layer.borderColor = Colors.app_text.generateColor().cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(Colors.app_text.generateColor(), for: [])
        button.layer.cornerRadius = 10.0
    }
    
    func setupNextButton() {
        self.nextButton.reactive.tap.observeNext {
            guard self.nominationType != nil else {
                self.error(title: "Error", message: "Please press the type of nomination you would like to create", error: nil)
                return
            }
            // self.checkNominations(currentUser: self.currentUser, messages: "You currently do not have an nominations")
            print(self.nominationType)
            let twoVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.two_create_nom.id) as! TwoCreateNominationViewController
            twoVC.currentUser = self.currentUser
            twoVC.nominationType = self.nominationType
            self.navigationController?.pushViewController(twoVC, animated: true)
            
        }
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
/*class MySwipeVC: EZSwipeController {
    var currentUser: Person!
    var phaseOne: Bool!
    override func setupView() {
        datasource = self
        navigationBarShouldNotExist = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
    }
} */
/*extension OneCreateNominationViewController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        let oneVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.one_create_nom.id) as? OneCreateNominationViewController
        //oneVC.view.backgroundColor = UIColor.red
        //oneVC.currentUser = self.currentUser
        //oneVC.phaseOne = self.phaseOne
        
        let twoVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.two_create_nom.id) as? TwoCreateNominationViewController
        //blueVC.view.backgroundColor = UIColor.blue
        
        let threeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.three_create_nom.id) as? ThreeCreateNominationViewController
        
        let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.confirm_create_nom.id) as? ConfirmCreateNominationViewController
        //greenVC.view.backgroundColor = UIColor.green
        
        return [oneVC!, twoVC!, threeVC!, confirmVC!]
    }
    
    func titlesForPages() -> [String] {
        return ["one", "two", "three", "confirm"]
    }
    func indexOfStartingPage() -> Int {
        return 0 // EZSwipeController starts from 2nd, green page
    }
    func changedToPageIndex(index: Int) {
        // You can do anything from here, for now we'll just print the new index
        print(index)
        
    }
} */
enum CoinTypes {
    case head
    case heart
    case health
    case hand
    
    var key: String {
        switch self {
        case .head:
            return "Head"
        case .heart:
            return "Heart"
        case .health:
            return "Health"
        case .hand:
            return "Hand"
        }
    }
}
extension OneCreateNominationViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        print("Selected index: \(segmentIndex)")
    }
}













