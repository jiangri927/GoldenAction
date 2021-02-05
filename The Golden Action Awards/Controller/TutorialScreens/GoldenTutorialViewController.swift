//
//  GoldenTutorialViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/23/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import paper_onboarding

class GoldenTutorialViewController: UIViewController {

    
    let goldHead = UIImage(named: "gold_head")
    let goldHand = UIImage(named: "gold_hand")
    let goldHeart = UIImage(named: "gold_heart")
    let goldHealth = UIImage(named: "gold_health")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(onboarding)
        
        // add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: self.view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            self.view.addConstraint(constraint)
        }*/
        // Do any additional setup after loading the view.
    }
    /*func onboardingItemsCount() -> Int {
        return 4
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
       /* return [
            OnboardingItemInfo(informationImage: self.goldHead!,
                               title: "title",
                               description: "description",
                               pageIcon: IMAGE,
                               color: UIColor.RANDOM,
                               titleColor: UIColor.RANDOM,
                               descriptionColor: UIColor.RANDOM,
                               titleFont: UIFont.FONT,
                               descriptionFont: UIFont.FONT),
            
            OnboardingItemInfo(informationImage: self.goldHeart!,
                               title: "title",
                               description: "description",
                               pageIcon: IMAGE,
                               color: UIColor.RANDOM,
                               titleColor: UIColor.RANDOM,
                               descriptionColor: UIColor.RANDOM,
                               titleFont: UIFont.FONT,
                               descriptionFont: UIFont.FONT),
            
            OnboardingItemInfo(informationImage: self.goldHand!,
                               title: "title",
                               description: "description",
                               pageIcon: IMAGE,
                               color: UIColor.RANDOM,
                               titleColor: UIColor.RANDOM,
                               descriptionColor: UIColor.RANDOM,
                               titleFont: UIFont.FONT,
                               descriptionFont: UIFont.FONT),
            
            OnboardingItemInfo(informationImage: self.goldHealth!,
                               title: "title",
                               description: "description",
                               pageIcon: IMAGE,
                               color: UIColor.RANDOM,
                               titleColor: UIColor.RANDOM,
                               descriptionColor: UIColor.RANDOM,
                               titleFont: Fonts.hira_pro_six.generateFont(size: 21.0)!,
                               descriptionFont: Fonts.hira_pro_three.generateFont(size: 19.0)!)
            ][index] */
    } */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
