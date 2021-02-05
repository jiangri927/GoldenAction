//
//  NominationFinishedViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/24/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SAConfettiView
import Toucan

class NominationFinishedViewController: UIViewController {

    @IBOutlet weak var medalView: UIView!
    @IBOutlet weak var alertMainView: UIView!
    @IBOutlet weak var confettiView: SAConfettiView!
    @IBOutlet weak var charityName: UILabel!
    @IBOutlet weak var amountDonated: UILabel!
    @IBOutlet weak var nominationCoin: UIImageView!
    @IBOutlet weak var congratsTextView: UITextView!
    @IBOutlet weak var awesomeButton: UIButton!
    
    var nomination: Nominations!
    var nominations: [Nominations]!
    
    var startIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.awesomeButton.layer.cornerRadius = 10.0
        self.awesomeButton.layer.masksToBounds = true
        self.awesomeButton.addTarget(self, action: #selector(awesomeButtonDidTap(_:)), for: .touchUpInside)
        
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.32)
        self.confettiView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.32)
        
        self.implementGestures()
        
        self.setUpMedalView()
        self.setupConfetti()
        self.setUpCongratsView()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func load() {
        self.setupConfetti()
        self.setUpMedalView()
        self.setUpCongratsView()
    }
    func setupConfetti() {
       // self.confettiView.type = .Image(self.generateAwardImage(awardType: nominations[self.startIndex].awardType!, currentCategory: nominations[self.startIndex].category))
        var finalColor: UIColor!
        if nominations[self.startIndex].awardType == AwardType.bronze.str {
            finalColor = UIColor(displayP3Red: 250/255, green: 163/255, blue: 117/255, alpha: 0.85)
        } else if nomination.awardType == AwardType.silver.str {
            finalColor = UIColor(displayP3Red: 191/255, green: 193/255, blue: 193/255, alpha: 0.85)
        } else {
            finalColor = UIColor(displayP3Red: 231/255, green: 216/255, blue: 140/255, alpha: 0.85)
        }
        self.confettiView.colors = [finalColor]
        self.confettiView.intensity = 0.60
        self.confettiView.startConfetti()
    }
    func setUpMedalView() {
        if self.nominations.count >= 2 {
            self.awesomeButton.setAttributedTitle(Strings.buttons.generateString(text: "Go to next Nomination!"), for: [])
        } else {
            self.awesomeButton.setAttributedTitle(Strings.buttons.generateString(text: "I really am Awesome!"), for: [])
        }
        self.charityName.text = self.nominations[self.startIndex].charity!.charityName
        self.amountDonated.text = "$\(self.nominations[self.startIndex].amountDonated!).00"
       // self.nominationCoin.image = Toucan(image: self.generateAwardImage(awardType: self.nominations[self.startIndex].awardType!, currentCategory: self.nominations[self.startIndex].category)).maskWithEllipse().image
    }
    func setUpCongratsView() {
        let congratsText = "It is our pleasure here at The Golden Action Awards to offer you this \(self.nominations[self.startIndex].awardType!.capitalized) Action Coin in the \(self.nominations[self.startIndex].category.capitalized) Category. You will be recieving an official coin in the mail so you will be able to show off to all of your friends how awesome you actually are because our community sure says so! In addition, you have been able to donate $\(self.nominations[self.startIndex].amountDonated!).00 to the charity of \(self.nominations[self.startIndex].charity!.charityName.capitalized). As always, the best Golden Actions will happen again so make sure to tell your friends!"
        self.congratsTextView.text = congratsText
        self.congratsTextView.layer.borderColor = Colors.app_text.generateColor().cgColor
        self.congratsTextView.layer.borderWidth = 1.0
        self.congratsTextView.layer.masksToBounds = false
        self.congratsTextView.clipsToBounds = true
        
    }
    func generateAwardImage(awardType: String, currentCategory: String) -> UIImage {
        switch currentCategory {
        case FilterStrings.hand_category.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_hand_small")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_hand_small")!
            } else {
                return UIImage(named: "gold_hand_small")!
            }
        case FilterStrings.head_category.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_head_small")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_head_small")!
            } else {
                return UIImage(named: "gold_head_small")!
            }
        case FilterStrings.heart_category.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_heart_small")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_heart_small")!
            } else {
                return UIImage(named: "gold_heart_small")!
            }
        case FilterStrings.health_category.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "bronze_health_small")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_health_small")!
            } else {
                return UIImage(named: "gold_health_small")!
            }
        default:
            return UIImage(named: "gold_heart_small")!
        }
    }
    
    @objc func awesomeButtonDidTap(_ sender: UIButton!) {
        if self.startIndex == self.nominations.count {
            if self.confettiView.isActive() {
                self.confettiView.stopConfetti()
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            self.startIndex += 1
            self.load()
        }
    }
    // MARK: - Gesture Recognizer Delegate
    func implementGestures() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .down
        self.confettiView.isUserInteractionEnabled = true
        self.confettiView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                if self.confettiView.isActive() {
                    self.confettiView.stopConfetti()
                }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
