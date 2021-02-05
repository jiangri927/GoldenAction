//
//  SearchTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nominatedByLogo: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var numVotes: UIButton!
    
    
    var nomUID: String!
    var awardUID: String!
    var userUID: String!
    
    func configureCell(item: Nominations) {
        self.numVotes.setTitle("\(item.numberOfVotes)", for: [])
        self.fullNameLabel.text = item.nominee.fullName
        self.locationLabel.text = item.cityState
        self.nominatedByLogo.text = item.nominatedBy.fullName
        if item.finished {
            self.typeLabel.text = "Award"
        } else {
            self.typeLabel.text = "Nomination"
        }
        let category = item.category
        self.categoryLabel.text = category
        
        item.nominee.getProfilePicture { (image, error) in
            guard error == nil && image != nil else {
                print(error!.localizedDescription)
                self.profPic.image = self.getImage(category: category)
                return
            }
            self.profPic.image = image
            
        }
    }
    func configureAward(item: Nominations) {
        self.fullNameLabel.text = item.nominee.fullName
        self.locationLabel.text = item.cityState
        self.nominatedByLogo.text = item.nominatedBy.fullName
        self.numVotes.setTitle("\(item.numberOfVotes)", for: [])
        let category = item.category
        self.categoryLabel.text = category
        item.nominee.getProfilePicture { (image, error) in
            guard error == nil && image != nil else {
                print(error!.localizedDescription)
                self.profPic.image = self.getImage(category: category)
                return
            }
            self.profPic.image = image
            
        }
    }
    func configureUser(item: Person) {
        self.fullNameLabel.text = item.fullName
        self.locationLabel.text = item.cityState
        
        item.getProfilePicture { (image, error) in
            guard error == nil && image != nil else {
                print(error!.localizedDescription)
                self.profPic.image = self.getImage(category: "Head")
                return
            }
            self.profPic.image = image
            
        }
    }
    func getImage(category: String) -> UIImage {
        switch category {
        case "Head":
            return StaticPictures.head_logo.generatePic()
        case "Heart":
            return StaticPictures.heart_logo.generatePic()
        case "Hand":
            return StaticPictures.hand_logo.generatePic()
        case "Health":
            return StaticPictures.health_logo.generatePic()
        default:
            return StaticPictures.head_logo.generatePic()
        }
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
