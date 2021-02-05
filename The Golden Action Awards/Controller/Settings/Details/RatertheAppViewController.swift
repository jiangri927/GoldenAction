//
//  RatertheAppViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 9/11/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class RatertheAppViewController: UIViewController {

    @IBOutlet weak var backButton: UINavigationItem!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var notnowButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

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
