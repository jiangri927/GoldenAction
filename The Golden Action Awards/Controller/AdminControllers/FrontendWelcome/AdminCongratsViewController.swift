//
//  AdminCongratsViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/1/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Bond

class AdminCongratsViewController: UIViewController {

    @IBOutlet weak var congratsMessage: UITextView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var congratsTitle: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    
    var currentUser: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.designInfoView(view: self.congratsMessage)
        self.designButtons()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func designInfoView(view: UITextView) {
        view.textColor = Colors.app_text.generateColor()
        view.layer.borderColor = Colors.app_text.generateColor().cgColor
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 10.0
        view.layer.borderWidth = 1.0
        view.backgroundColor = UIColor.black
    }
    func designButtons() {
        self.designButton(button: self.returnButton)
        self.returnButton.reactive.tap.observeNext {
            self.returnProfile()
        }
    }
    func designButton(button: UIButton) {
        button.setBackgroundColor(Colors.app_text.generateColor(), for: [])
        button.setTitleColor(UIColor.black, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
    }
    func returnProfile() {
        print("I love Bond")
        self.dismiss(animated: true, completion: nil)
    }
    @objc func returnProfiles(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    

}
