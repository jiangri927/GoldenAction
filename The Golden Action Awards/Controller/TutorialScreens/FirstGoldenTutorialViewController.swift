//
//  FirstGoldenTutorialViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/24/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import BWWalkthrough
import SAConfettiView

class FirstGoldenTutorialViewController: BWWalkthroughPageViewController {

    @IBOutlet weak var gradientView: UIView!
    
    let bronze = UIColor(displayP3Red: 250/255, green: 163/255, blue: 117/255, alpha: 0.85)
    let silver = UIColor(displayP3Red: 191/255, green: 193/255, blue: 193/255, alpha: 0.85)
    let gold = UIColor(displayP3Red: 231/255, green: 216/255, blue: 140/255, alpha: 0.85)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.confettiView.type = .Image(UIImage(named: "gold_head_small")!)
       // self.confettiView.colors = [self.bronze, self.silver, self.gold]
       // self.confettiView.intensity = 0.50
        
        // Do any additional setup after loading the view.
    }

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
