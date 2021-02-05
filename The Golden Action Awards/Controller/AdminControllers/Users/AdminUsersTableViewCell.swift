//
//  AdminUsersTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase

class AdminUsersTableViewCell: UITableViewCell {

    @IBOutlet weak var profileSubTitle: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    var person:Person!
    
    var personUID: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func downloadImageFromFirebase(){
        
            let imageUrl = self.person.profilePictureURL
        
//            if AppFileManager.sharedInstance.imageExistInDcoumentDirectory(imageName: imageUrl){
//                let image = AppFileManager.sharedInstance.getImageFromDocumentDirectory(imageName: imageUrl)
//                self.profilePicture.image = image
//                return
//            }
        
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
        
        
            self.profilePicture.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
//         AppFileManager.sharedInstance.saveImageDocumentDirectory(image: self.profilePicture.image!, imageName: imageUrl)
        
//            storageRef.downloadURL(completion: { (url, error) in
//                guard url != nil else {
//                    return
//                }
//                do{
//                    let data = try Data(contentsOf: url!)
//                    let image = UIImage(data: data as Data)
//                    self.profilePicture.image = image
//                    AppFileManager.sharedInstance.saveImageDocumentDirectory(image: image!, imageName: imageUrl)
//
//                }catch{
//                    print(error)
//                }
//            })
    }
    
    func setUpPic() {
        self.profilePicture.isUserInteractionEnabled = true
        self.profilePicture.contentMode = UIViewContentMode.scaleAspectFill
        
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.height / 2
    }
    

}
