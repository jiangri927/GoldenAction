//
//  AdminDonationsTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class AdminDonationsTableViewCell: UITableViewCell {

    @IBOutlet weak var amountDonated: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var nomineePic: UIImageView!
    @IBOutlet weak var nomineeName: UILabel!
    @IBOutlet weak var charityName: UILabel!
    var nominations:Nominations!
    var viewController : AdminDonationsViewController!
    
    func loadNomineeImage(){
        self.designNomineePic()
        //self.viewController.activityView.startAnimating()
        let imageUrl = self.nominations.nominee.profilePictureURL
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"

        //let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        self.nomineePic.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
        
//        storageRef.downloadURL(completion: { (url, error) in
//            guard url != nil else {
//                return
//            }
//            do{
//                let data = try Data(contentsOf: url!)
//                let image = UIImage(data: data as Data)
//                self.nomineePic.image = image
//                self.viewController.activityView.stopAnimating()
//                
//            }catch{
//                print(error)
//                self.viewController.activityView.stopAnimating()
//            }
//        })
        
    }
    
    func designNomineePic(){
        self.nomineePic.layer.borderWidth = 1
        self.nomineePic.layer.masksToBounds = false
        self.nomineePic.layer.borderColor = UIColor.black.cgColor
        self.nomineePic.layer.cornerRadius = self.nomineePic.frame.height/2
        self.nomineePic.clipsToBounds = true
    }
    
    func totalCalculatedAmount()-> Int{
        let totalVotes = self.nominations.numberOfVotes
        if totalVotes > 30 && totalVotes <= 50 {
            return 10
        }else if totalVotes > 50 {
            let extraVotesAmount = ((totalVotes - 50) / 30) * 10
            return 10 + extraVotesAmount
        }
        return 10
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
