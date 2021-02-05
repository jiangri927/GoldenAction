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


extension UIButton {
    
    func centerVertically(padding: CGFloat = 0.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height + 20),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
    }
    
}


class OneCreateNominationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var buttonBoxCard: UIView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var head: UIButton!
    @IBOutlet weak var heart: UIButton!
    @IBOutlet weak var health: UIButton!
    @IBOutlet weak var hand: UIButton!
    
    
    
    
    var phaseOne = true
    
    var currentUser: Person!
    // Step 2: Create or get a button scheme
    //let buttonScheme = MDCButtonScheme()
    let appColor = Colors.app_text.generateColor()
    let blackColor = Colors.black.generateColor()
    
    var nominationType: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.checkVerification(currentUser: self.currentUser, message: "You must have an account to create a nomination")
        /*let backWorkItem = DispatchWorkItem {
         self.dismiss(animated: true, completion: nil)
         } */
        // self.checkVerification(currentUser: self.currentUser, message: "You must have an account to create a nomination", workitem: backWorkItem)
        // self.checkNominations(currentUser: self.currentUser, messages: "You need to purchase a nomination to create one", workitem: backWorkItem)
        self.designBoxView()
        self.tapDismiss()
        self.designButtons()
        //self.designCard()
        self.swipeDismiss()
        self.designRoots()
        // self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.setupDownGesture()
        //self.setupNextButton()
        self.setTitleViewColor()
        
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
    
    func setTitleViewColor(){
        let imageColor = self.gradient(size: self.titleLabel.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.titleLabel.textColor = UIColor.init(patternImage: imageColor!)
    }
    
    func designBoxView(){
        // Inner
        // self.buttonBoxCard.backgroundColor = Colors.nom_detail_innerBackground.generateColor()
        // self.buttonBoxCard.layer.borderColor = Colors.nom_detail_innerBorder.generateColor().cgColor
        // self.buttonBoxCard.layer.borderWidth = 1.0
        self.buttonBoxCard.layer.cornerRadius = 10.0
        self.buttonBoxCard.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swipeDismiss() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureDown(_:)))
        gesture.direction = .down
        //   self.innerView.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        //  self.innerView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
        
        
    }
    func designRoots() {
        self.head.setImage(UIImage(named: "head-outline.png"), for: UIControlState.normal)
        self.hand.setImage(UIImage(named: "hand-outline.png"), for: UIControlState.normal)
        self.heart.setImage(UIImage(named: "hear-outline.png"), for: UIControlState.normal)
        self.health.setImage(UIImage(named: "care-outline.png"), for: UIControlState.normal)
        
        self.designRootButton(button: self.head)
        self.designRootButton(button: self.heart)
        self.designRootButton(button: self.hand)
        self.designRootButton(button: self.health)
    }
    
    func designButtons() {
        self.designButton(button: self.backButton)
        let imageColor = self.gradient(size: self.backButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.backButton.layer.borderWidth = 1.0
        self.backButton.backgroundColor = .clear
        self.backButton.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        self.backButton.layer.cornerRadius = 10.0
        self.backButton.reactive.tap.observeNext {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func designButton(button: UIButton) {
        let imageColor = self.gradient(size: button.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        button.setTitleColor(.white, for: []) //Colors.app_text.generateColor()
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        button.layer.masksToBounds = true
    }
    
    func buttonShadow(button: UIButton) {
        button.layer.shadowColor = Colors.app_color.generateColor().cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 1, height: 3)
    }
    func designCard() {
        self.cardView.backgroundColor = UIColor.white
        self.cardView.layer.cornerRadius = 10.0
        self.cardView.layer.masksToBounds = true
        self.cardView.layer.shadowColor = Colors.white.generateColor().cgColor
        self.cardView.layer.shadowOpacity = 0.9
        self.cardView.layer.shadowRadius = 3
        self.cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    @objc func headClicked(_ sender:UIButton ) {
        if self.head.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.head.key
            self.buttonClicked(button: self.head)
            self.buttonUnclicked(button: self.heart)
            self.buttonUnclicked(button: self.hand)
            self.buttonUnclicked(button: self.health)
            self.setupNextButton()
        }
    }
    @objc func handClicked(_ sender: UIButton) {
        if self.hand.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.hand.key
            self.buttonClicked(button: self.hand)
            self.buttonUnclicked(button: self.heart)
            self.buttonUnclicked(button: self.head)
            self.buttonUnclicked(button: self.health)
            self.setupNextButton()
        }
    }
    @objc func heartClicked(_ sender: UIButton) {
        if self.heart.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.heart.key
            self.buttonClicked(button: self.heart)
            self.buttonUnclicked(button: self.hand)
            self.buttonUnclicked(button: self.head)
            self.buttonUnclicked(button: self.health)
            self.setupNextButton()
        }
    }
    @objc func healthClicked(_ sender: UIButton) {
        //        let tutorialVC = self.storyboard?.instantiateViewController(withIdentifier: "CharityViewControler") as! CharityViewControler
        //        self.present(tutorialVC, animated: true, completion: {
        //            tutorialVC.doneClouser = { charity in
        //
        //            }
        //        })
        
        if self.health.backgroundColor != self.appColor {
            self.nominationType = NominationTypes.health.key
            self.buttonClicked(button: self.health)
            self.buttonUnclicked(button: self.hand)
            self.buttonUnclicked(button: self.head)
            self.buttonUnclicked(button: self.heart)
            self.setupNextButton()
        }
        
    }
    
    func buttonUnclicked(button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: [])
    }
    
    func buttonClicked(button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: [])
    }
    
    func designRootButton(button: UIButton) {
        let imageColor = self.gradient(size: button.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.init(patternImage: imageColor!).cgColor
        button.layer.borderWidth = 1.0
        button.setTitleColor(.white, for: [])
        button.layer.cornerRadius = 10.0
        button.centerVertically()
        
    }
    
    func setupNextButton() {
        //        self.nextButton.reactive.tap.observeNext {
        //            guard self.nominationType != nil else {
        //                self.error(title: "Error", message: "Please press the type of nomination you would like to create", error: nil)
        //                return
        //            }
        // self.checkNominations(currentUser: self.currentUser, messages: "You currently do not have an nominations")
        print(self.nominationType)
        let twoVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.three_create_nom.id) as! ThreeCreateNominationViewController
        twoVC.currentUser = self.currentUser
        twoVC.nominationType = self.nominationType
        self.navigationController?.pushViewController(twoVC, animated: true)
        
        //}
    }
}

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













