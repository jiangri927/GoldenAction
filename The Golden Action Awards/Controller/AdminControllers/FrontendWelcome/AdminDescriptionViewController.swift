//
//  AdminDescriptionViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import NYAlertViewController
import Bond

class AdminDescriptionViewController: UIViewController {

    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    let placeholderText = "Enter why here..."
    var currentUser: Person!
    var returningUser: Bool!
    var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designButtons()
        self.tapDismiss()
        self.designDescriptionView()
        self.designInputViews(outer: self.outerView, inner: self.innerView, main: self.view)
        self.designTitle()
        // Do any additional setup after loading the view.
        
    }
    
    func designTitle() {
        self.descriptionTitle.textColor = Colors.app_text.generateColor()
    }
    
    func designDescriptionView() {
        self.descriptionTextView.textColor = Colors.app_text.generateColor()
        self.descriptionTextView.layer.borderColor = Colors.app_text.generateColor().cgColor
        self.descriptionTextView.layer.masksToBounds = false
        self.descriptionTextView.layer.cornerRadius = 10.0
        self.descriptionTextView.layer.borderWidth = 1.0
        self.descriptionTextView.delegate = self
    }
    
    func designButtons() {
        self.designButton(button: self.submitButton)
        self.designButton(button: self.backButton)
        self.submitButton.addTarget(self, action: #selector(descriptionDidTap(_:)), for: .touchUpInside)
        self.backButton.addTarget(self, action: #selector(backDidTap(_:)), for: .touchUpInside)
    }
    func designButton(button: UIButton) {
        button.setBackgroundColor(Colors.app_text.generateColor(), for: [])
        button.setTitleColor(UIColor.black, for: [])
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
    }
    @objc func backDidTap(_ sender: UIButton!) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func descriptionDidTap(_ sender: UIButton!) {
        guard self.descriptionTextView.text != self.placeholderText else {
            self.goldenAlert(title: "Error", message: "Please enter a description of why you want to be a nomination sponsor", view: self)
            return
        }
        guard self.descriptionTextView.text != "" else {
            self.goldenAlert(title: "Error", message: "Please enter a description of why you want to be a nomination sponsor", view: self)
            return
        }
        self.performSegue(withIdentifier: SegueId.sponsordescription_address.id, sender: self)
        
    }
    
    func findAcctType() {
        if Auth.auth().currentUser != nil {
            let ref = DBRef.user(uid: Auth.auth().currentUser!.uid).reference()
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : Any] {
                    let person = Person(dict: dict)
                    self.currentUser = person
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.sponsordescription_address.id {
            let destinationVC = segue.destination as! AdminAddressViewController
            destinationVC.adminDescription = self.descriptionTextView.text
            destinationVC.currentUser = self.currentUser
            destinationVC.returningUser = self.returningUser
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension AdminDescriptionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.descriptionTextView {
            self.changeTitle(textView: self.descriptionTextView, start: true)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.descriptionTextView {
            self.changeTitle(textView: self.descriptionTextView, start: false)
        }
    }
    func changeTitle(textView: UITextView, start: Bool) {
        if start {
            if textView.text == self.placeholderText {
                textView.text = ""
            }
        } else {
            if textView.text == "" {
                textView.text = self.placeholderText
            }
        }
    }
}
















