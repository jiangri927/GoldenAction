//
//  NewCharityPopup.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 03/04/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import NYAlertViewController
import Firebase
import SwiftKeychainWrapper
import SCLAlertView

class NewCharityViewController:UIViewController, UITextFieldDelegate{
    
    @IBOutlet var charityName: UITextField!
    @IBOutlet var charityClassification: UITextField!
    @IBOutlet var charityEin: UITextField!
    @IBOutlet var charityAddress: UITextField!
    @IBOutlet var scrollView:UIScrollView!
    
    var selectedCharity:Charity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func configureFields(){
                
            self.charityName.textColor = .gray
            self.charityName.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Charity Name")
            self.charityName.backgroundColor = UIColor.black
            self.charityName.isSecureTextEntry = false
            self.charityName.setBottomBorder()
            self.charityName.delegate = self
            self.charityName.returnKeyType = .default
            
            self.charityClassification.textColor = .gray
            self.charityClassification.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Charity Classification")
            self.charityClassification.backgroundColor = .black
            self.charityClassification.isSecureTextEntry = false
            self.charityClassification.setBottomBorder()
            self.charityClassification.delegate = self
            self.charityClassification.returnKeyType = .default

        
            self.charityEin.textColor = .gray
            self.charityEin.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "EIN")
            self.charityEin.backgroundColor = .black
            self.charityEin.isSecureTextEntry = false
            self.charityEin.setBottomBorder()
            self.charityEin.delegate = self
            self.charityEin.returnKeyType = .default

        
            self.charityAddress.textColor = .gray
            self.charityAddress.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: "Full Address")
            self.charityAddress.backgroundColor = .black
            self.charityAddress.isSecureTextEntry = false
            self.charityAddress.setBottomBorder()
            self.charityAddress.delegate = self
            self.charityAddress.returnKeyType = .default
            self.scrollView.updateContentView()
            print(self.scrollView)
    }
    
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == self.charityName {
                self.charityClassification.becomeFirstResponder()
            }else if textField == self.charityClassification {
                self.charityEin.becomeFirstResponder()
            }else if textField == self.charityAddress {
                self.validateValue()
            }
            print(textField.text!)
            return true
        }
    
    func validateValue(){
        
        let name            = self.charityName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let classification  = self.charityClassification.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let ein             = self.charityEin.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let fulladdress     = self.charityAddress.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if (name.count) <= 0 {
         self.goldenAlert(title: "Charity Details!", message: "Please check charity name!", view: self)
         return
            
        }else if (classification.count) <= 0 {
         self.goldenAlert(title: "Charity Details!", message: "Please check charity classification!", view: self)
         return
            
        }else if (ein.count) <= 0 {
         self.goldenAlert(title: "Charity Details!", message: "Please check charity ein number!", view: self)
         return
            
        }else if (fulladdress.count) <= 0{
         self.goldenAlert(title: "Charity Details!", message: "Please check charity fulladdress!", view: self)
         return
        }
        
        self.selectedCharity = Charity.init(charityName: name, classification: classification, address: fulladdress, ein: ein, uid: "")
        
        let userData = ["charity" : self.selectedCharity]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectCharity"), object: nil, userInfo: userData as [AnyHashable : Any])
    }
    
}

