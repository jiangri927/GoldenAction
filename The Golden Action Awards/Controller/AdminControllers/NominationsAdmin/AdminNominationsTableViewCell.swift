//
//  AdminNominationsTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import RAMAnimatedTabBarController

class AdminNominationsTableViewCell: UITableViewCell {

    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var nomineeName: UILabel!
    @IBOutlet weak var nomineePic: UIImageView!
    @IBOutlet weak var nomineeStatus: UILabel!
    @IBOutlet weak var btnFinish: UIButton!
    var nom:Nominations!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        btnFinish.clipsToBounds = true
        btnFinish.layer.cornerRadius = 5
        btnFinish.layer.borderWidth = 1
        btnFinish.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func downloadImageFromFirebase(){
        self.setUpPic()
        if self.nom.urls.count > 0{
            let imageUrl = self.nom.urls[0]
            //let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            self.nomineePic.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
            
            
//            storageRef.downloadURL(completion: { (url, error) in
//                guard url != nil else {
//                    return
//                }
//                do{
//                    let data = try Data(contentsOf: url!)
//                    let image = UIImage(data: data as Data)
//                    self.nomineePic.image = image
//                    
//                }catch{
//                    print(error)
//                }
//            })
        }
        
    }
    
    func setUpPic() {
        self.nomineePic.isUserInteractionEnabled = true
        self.nomineePic.contentMode = UIViewContentMode.scaleAspectFill
        
        self.nomineePic.layer.masksToBounds = true
        self.nomineePic.layer.cornerRadius = self.nomineePic.frame.height/2
    }
    
    @IBAction func actionFinish(_ sender: UIButton) {
        let vc = self.findViewController() as! AdminNominationsViewController
        let animatedTabBar = vc.tabBarController as! RAMAnimatedTabBarController
        
        let ref = CollectionFireRef.nominations.reference()
        ref.whereField("uid", isEqualTo: nom.uid).getDocuments { (snapshot, error) in
            if error == nil {
                if let data = snapshot?.documents {
                    for d in data {
                        let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                        docRef.updateData(["finished":true])
                        docRef.updateData(["charityDone":false])
                    }
                }
            }
        }
        
        animatedTabBar.setSelectIndex(from: vc.tabBarController!.selectedIndex, to: 2)
    }
    
}
