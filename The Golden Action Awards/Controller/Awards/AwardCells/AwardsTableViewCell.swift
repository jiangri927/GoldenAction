//
//  AwardsTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Toucan
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

class AwardsTableViewCell: UITableViewCell {
    @IBOutlet weak var awardeePic: UIImageView!
    @IBOutlet weak var charityPic: UIImageView!
    @IBOutlet weak var awardeeName: UILabel!
    @IBOutlet weak var awardeeLocation: UILabel!
    @IBOutlet weak var nominatedBy: UILabel!
    
    var award: Nominations!
    var keychain = KeychainWrapper.standard
    
    func configureCell(awardee: [String : Any]) {
        self.awardeeName.text = awardee["name"] as? String ?? ""
        self.awardeeLocation.text = awardee["location"] as? String ?? ""
        let nomBy = awardee["nominatedBy"] as? String ?? ""
        self.nominatedBy.text = "Nominated By \(nomBy)"
        self.setUpCharityPic()
        self.setUpAwardeePic()
    }
    func configureAward(awardee: Nominations) {
        self.setUpCharityPic()
        self.setUpAwardeePic()
        
        self.awardeeName.text = awardee.nominee.fullName
        if awardee.anonoymous {
            self.nominatedBy.text = "Anonymous"
        } else {
            self.nominatedBy.text = awardee.nominatedBy.fullName
        }
        self.awardeeLocation.text = awardee.nominee.cityState
        
        self.downloadImageFromFirebase(awardee:awardee)
            awardee.loadNomVotes { (votes) in
                print("===============\(votes)")
                if votes < 5 {
                    self.charityPic.image = self.generateAwardImage(awardType: AwardType.bronze.str, currentCategory: awardee.category)
                } else if votes > 4 || votes < 10  {
                    self.charityPic.image = self.generateAwardImage(awardType: AwardType.silver.str, currentCategory: awardee.category)
                } else {
                    self.charityPic.image = self.generateAwardImage(awardType: AwardType.gold.str, currentCategory: awardee.category)
                }
            }
    }
    
    func downloadImageFromFirebase(awardee: Nominations){
        if awardee.urls != [] {
            let valueWorkItem = DispatchWorkItem {
                if awardee.urls.count > 0{
                    let imageUrl = awardee.nominee.profilePictureURL
                    
                    if AppFileManager.sharedInstance.imageExistInDcoumentDirectory(imageName: imageUrl){
                        let image = AppFileManager.sharedInstance.getImageFromDocumentDirectory(imageName: imageUrl)
                        DispatchQueue.main.async {
                            self.awardeePic.image = image
                        }
                        return
                    }
                    let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
                   // let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
                    let storageRef = Storage.storage().reference(forURL: completeUrl)
                    storageRef.downloadURL(completion: { (url, error) in
                        guard url != nil else {
                            return
                        }
                        do{
                            let data = try Data(contentsOf: url!)
                            let image = UIImage(data: data as Data)
                            self.awardeePic.image = image
                            AppFileManager.sharedInstance.saveImageDocumentDirectory(image: image!, imageName: imageUrl)
                            
                        }catch{
                            print(error)
                        }
                    })
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() /*+ .milliseconds(100) */, execute: valueWorkItem)
        }
    }
    
    
    func generateAwardImage(awardType: String, currentCategory: String) -> UIImage {
        switch currentCategory {
        case FilterStrings.hand.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_hand")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_hand")!
            } else {
                return UIImage(named: "gold_hand")!
            }
        case FilterStrings.head.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_head")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_head")!
            } else {
                return UIImage(named: "gold_head")!
            }
        case FilterStrings.heart.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_heart")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_heart")!
            } else {
                return UIImage(named: "gold_heart")!
            }
        case FilterStrings.health.id:
            if awardType == AwardType.bronze.str {
                return UIImage(named: "copper_health")!
            } else if awardType == AwardType.silver.str {
                return UIImage(named: "silver_health")!
            } else {
                return UIImage(named: "gold_health")!
            }
        default:
            return UIImage(named: "gold_heart")!
        }
    }
    
    func setUpCharityPic() {
       // self.charityPic.image = UIImage(named: "samplePic")!
        self.charityPic.contentMode = UIViewContentMode.scaleAspectFit
        self.charityPic.layer.cornerRadius = 10.0
        self.charityPic.layer.masksToBounds = true
        
    }
    func setUpAwardeePic() {
        //self.awardeePic.image = UIImage(named: "headLogo")!
        self.awardeePic.contentMode = UIViewContentMode.scaleAspectFill
        
        self.awardeePic.layer.masksToBounds = true
        self.awardeePic.layer.cornerRadius = self.awardeePic.frame.height/2
        
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

class AwardNotFoundTableCell:UITableViewCell{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
