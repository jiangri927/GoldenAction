//
//  PendingDonationTableViewCell.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 17/06/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase

class PendingDonationTableViewCell: UITableViewCell {
    
    @IBOutlet var viewBg: UIView!
    @IBOutlet weak var lblCharity: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblNominatedBy: UILabel!
    @IBOutlet var lblVoteCount: UILabel!
    @IBOutlet var lblAmount: UILabel!
    @IBOutlet var viewDonationAction: UIView!
    @IBOutlet var viewAwardAction: UIView!
    @IBOutlet var btnAward: UIButton!
    @IBOutlet var btnDonation: UIButton!
    @IBOutlet var imgCheckDonation: UIImageView!
    @IBOutlet var imgCheckAward: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    
    
    var nominations:Nominations!
    var viewController : AdminDonationsViewController!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewDonationAction.layer.borderWidth = 1
        viewDonationAction.layer.borderColor = UIColor.black.cgColor
        viewDonationAction.layer.cornerRadius = 5
        
        viewAwardAction.layer.borderWidth = 1
        viewAwardAction.layer.borderColor = UIColor.black.cgColor
        viewAwardAction.layer.cornerRadius = 5
        
        imgProfile.layer.cornerRadius = 25
        imgProfile.clipsToBounds = true
    }
    
    func loadNomineeImage(){
       
        let imageUrl = self.nominations.nominee.profilePictureURL
        let nominator = self.nominations.nominatedBy.fullName
        self.lblNominatedBy.text = nominator
        
        self.imgCheckAward.image = UIImage(named: "uncheckBox")
        self.imgCheckDonation.image = UIImage(named: "uncheckBox")
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        self.imgProfile.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
        self.lblAddress.text = self.nominations.nominee.address 
    }

    func totalCalculatedAmount()-> Int{
        let totalVotes = self.nominations.numberOfVotes
        if totalVotes > 30 && totalVotes <= 50 {
            return 10
        } else if totalVotes > 50 {
            let extraVotesAmount = ((totalVotes - 50) / 30) * 10
            return 10 + extraVotesAmount
        }
        return 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
