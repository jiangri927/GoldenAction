//
//  UserGoldenCollectionViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/18/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class UserGoldenCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var nominatorName: UILabel!
    @IBOutlet weak var statusLabel: UILabel! // Approval status, time left etc.
    @IBOutlet weak var charityChosen: UILabel!
    
    var nomUID: String!
    var categoryPicture: UIImage!
    
    
    func configureCell(nom: UserNominee) {
        self.categoryIcon.image = self.categoryPicture
        self.nominatorName.text = nom.nominatedByName
        self.nomUID = nom.nominationUID
        self.charityChosen.text = nom.charityName
        self.setUpPic()
    }
    
    func setUpPic() {
        self.categoryIcon.isUserInteractionEnabled = true
        self.categoryIcon.contentMode = UIViewContentMode.scaleAspectFill
        
        self.categoryIcon.layer.masksToBounds = false
        self.categoryIcon.layer.cornerRadius = self.categoryIcon.frame.height/2
        
        // ---> This puts a border around the image
        /*
         self.profilePic.clipsToBounds = true
         self.profilePic.layer.borderWidth = 4.0
         self.profilePic.layer.borderColor = UIColor.white.cgColor
         */
    }
    
}
