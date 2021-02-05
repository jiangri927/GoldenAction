//
//  UserNomsCollectionViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/18/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class UserNomsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var nomineeName: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var charityLabel: UILabel!
    
    var nomUID: String!
    var categoryIcon: UIImage!
    
    func configureCell(nom: UserNominations) {
        Person.getProfilePicture(uid: nom.nomineeUID, url: nom.nomineeURL) { (image, error) in
            guard error == nil && image != nil else {
                self.categoryImage.image = self.categoryIcon
                return
            }
            self.categoryImage.image = image
        }
        self.statusLabel.text = nom.status
        self.nomUID = nom.nominationUID
        self.setUpPic()
    }
    func setUpPic() {
        self.categoryImage.isUserInteractionEnabled = true
        self.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
        
        self.categoryImage.layer.masksToBounds = false
        self.categoryImage.layer.cornerRadius = self.categoryImage.frame.height/2
        
        // ---> This puts a border around the image
        /*
         self.profilePic.clipsToBounds = true
         self.profilePic.layer.borderWidth = 4.0
         self.profilePic.layer.borderColor = UIColor.white.cgColor
         */
    }
    
}
