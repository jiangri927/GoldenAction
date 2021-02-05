//
//  AdminInfoViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Spruce

class AdminInfoViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sponsorInfoView: UITextView!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    var returningUser: Bool!
    var currentUser: Person!
    let changeFunc = LinearSortFunction(direction: .leftToRight, interObjectDelay: 0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.designButtons()
        self.designInfoView(view: self.sponsorInfoView)
        self.tapDismiss()
        self.implementGestures()
        //let spruceAnimation = SpringAnimation(duration: 1, changes: self.changeFunc)
        
        // Do any additional setup after loading the view.
    }
    func designButtons() {
        self.designButton(button: self.nextButton)
        self.designButton(button: self.backButton)
        self.nextButton.addTarget(self, action: #selector(toDescriptionTapped(_:)), for: .touchUpInside)
        self.backButton.addTarget(self, action: #selector(backDidTap(_:)), for: .touchUpInside)
    }
    func designButton(button: UIButton) {
        button.setBackgroundColor(Colors.app_text.generateColor(), for: [])
        button.setTitleColor(UIColor.black, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
    }
    
    
    func designInfoView(view: UITextView) {
        view.textColor = Colors.app_text.generateColor()
        view.layer.borderColor = Colors.app_text.generateColor().cgColor
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 10.0
        view.layer.borderWidth = 1.0
        view.backgroundColor = UIColor.black
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func backDidTap(_ sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func toDescriptionTapped(_ sender: UIButton!) {
        self.performSegue(withIdentifier: SegueId.sponsorinfo_description.id, sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == SegueId.sponsorinfo_description.id {
            let destinationVC = segue.destination as! AdminDescriptionViewController
            destinationVC.currentUser = self.currentUser
            destinationVC.returningUser = self.returningUser
        }
    }
    // MARK: - Gesture Recognizer Delegate
    func implementGestures() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .right
        self.innerView.addGestureRecognizer(gesture)
        self.outerView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                //self.view.spruce.animate([.fadeIn, .expand(.slightly)], sortFunction: self.changeFunc)
                //self.navigationController?.popViewController(animated: true)
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.view.spruce.animate([.slide(.down, .severely)], sortFunction: self.changeFunc)
                self.dismiss(animated: true, completion: nil)
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

    

}
