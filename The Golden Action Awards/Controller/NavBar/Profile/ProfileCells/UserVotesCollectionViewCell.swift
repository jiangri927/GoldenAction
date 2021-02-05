//
//  UserVotesCollectionViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/18/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class UserVotesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var nomineeName: UILabel!
    @IBOutlet weak var votesStatus: UILabel!
    @IBOutlet weak var charityChosen: UILabel!
    
    var nomUID: String!
    var categoryImage: UIImage!
    
    func configureCell(votes: Votes) {
        // Set category in other vc
        self.nomUID = votes.nomUID
        self.nomineeName.text = votes.nomineeName
        self.charityChosen.text = "Charity: \(votes.charityName)"
        Person.getProfilePicture(uid: votes.nomineeUID, url: votes.nomineeURL, completion: { (image, error) in
            guard error == nil && image != nil else {
                self.categoryIcon.image = self.categoryImage
                return
            }
            self.categoryIcon.image = image
        })
        votes.findIfAward { (isAward) in
            if isAward {
                Nominations.loadDonatedNom(uid: votes.nomUID, completion: { (amount) in
//                    self.votesStatus.text = "$\(amount).00 Donated"
                })
            } else {
                Nominations.loadVotesNom(uid: votes.nomUID, completion: { (amount) in
                    if amount == 1 {
                        self.votesStatus.text = "This action has \(amount) vote"
                    } else {
                        self.votesStatus.text = "This action has \(amount) votes"
                    }
                })
            }
        }
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
