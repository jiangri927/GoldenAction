//
//  ProfileTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/1/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SearchTextField

class ProfileTableViewCell: UITableViewCell {

    // Input View
    @IBOutlet weak var outerInputView: UIView!
    @IBOutlet weak var innerInputView: UIView!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: SearchTextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var nameLine: UIView!
    @IBOutlet weak var locationLine: UIView!
    
    
    func configureCell(currentUser: Person) {
        currentUser.getProfilePicture { (image, error) in
            guard error == nil && image != nil else {
                self.profPic.image = StaticPictures.head_logo.generatePic()
                return
            }
            self.profPic.image = image
        }
        
        self.emailField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: currentUser.email)
        self.locationField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: currentUser.cityState)
        self.nameField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: currentUser.fullName)
        self.saveButton.setTitle("Save Changes", for: [])
        self.saveButton.layer.masksToBounds = true
        self.saveButton.layer.cornerRadius = 10.0
        self.changePasswordButton.layer.masksToBounds = true
        self.changePasswordButton.layer.cornerRadius = 10.0
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
