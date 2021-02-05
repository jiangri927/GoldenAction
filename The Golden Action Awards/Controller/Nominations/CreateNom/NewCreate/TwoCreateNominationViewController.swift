//
//  TwoCreateNominationViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/7/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Spruce
import Bond
import EZSwipeController

import MaterialComponents

enum PersonType {
    case exisiting
    case new
    case contact
    
    var id: Int {
        switch self {
        case .exisiting:
            return 0
        case .new:
            return 1
        case .contact:
            return 2
        }
    }
}
class TwoCreateNominationViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var newUser: UIButton!
    @IBOutlet weak var exisitingUser: UIButton!

    var phaseOne = true
    var currentUser: Person!
    var nominationType: String!
    var personType: Int!
    
    let appColor = Colors.app_text.generateColor()
    let blackColor = Colors.black.generateColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapDismiss()
        self.swipeDismiss()
        self.designButtons()
        self.designRoots()
        
        let imageColor = self.gradient(size: self.titleLabel.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.titleLabel.textColor = UIColor.init(patternImage: imageColor!)
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
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureRight(_:)))
        gesture.direction = .right
        self.innerView.isUserInteractionEnabled = true
        self.innerView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
    }
    
    func designRoots() {
        self.designRootButton(button: self.newUser)
        self.designRootButton(button: self.exisitingUser)
        self.clickNewUser()
        self.clickExisitingUser()
    }
    
    func designButtons() {
        self.designButton(button: self.backButton)
        
        self.backButton.reactive.tap.observeNext {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func designNextButton() {
        
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
    
    func buttonShadow(button: UIButton) {
        button.layer.shadowColor = Colors.app_color.generateColor().cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 1, height: 3)
    }
    
    func designCard() {
        self.innerView.backgroundColor = .clear
        self.innerView.layer.cornerRadius = 15.0
        self.innerView.layer.masksToBounds = true
    }
    
    func clickNewUser() {
        self.newUser.reactive.tap.observeNext {
            if self.newUser.backgroundColor != self.appColor {
                self.personType = PersonType.new.id
                self.buttonClicked(button: self.newUser)
                self.buttonUnclicked(button: self.exisitingUser)
                self.nextScreenPresent()
                //self.buttonUnclicked(button: self.contactsUser)
            }
        }
    }
    
    func clickExisitingUser() {
        self.exisitingUser.reactive.tap.observeNext {
            if self.exisitingUser.backgroundColor != self.appColor {
                self.personType = PersonType.exisiting.id
                self.buttonClicked(button: self.exisitingUser)
                self.buttonUnclicked(button: self.newUser)
                self.nextScreenPresent()
                // self.buttonUnclicked(button: self.contactsUser)
            }
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
    }
    
    func nextScreenPresent(){
        let threeVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.three_create_nom.id) as! ThreeCreateNominationViewController
        threeVC.currentUser = self.currentUser
        threeVC.nominationType = self.nominationType
        threeVC.personType = self.personType
        self.navigationController?.pushViewController(threeVC, animated: true)
    }
    
    func setUpTwicket() {
        //let control = Twicket.create_users(view: self.cardContent).generate()
        //control.delegate = self
        //self.cardContent.addSubview(control)
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

