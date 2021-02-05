//
//  NotificationTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/15/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var notifDescription: UILabel!
    @IBOutlet weak var notifImage: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    
    func configureNotif(notification: GoldenNotifications) {
       // self.configureButton()
       // self.setUpPic()
      //  self.downloadPic(notification: notification)
        self.notifDescription.attributedText = Strings.cell_notification_description.generateString(text: notification.notifText)
    }
//    func downloadPic(notification: GoldenNotifications) {
//        self.notifImage.image = nil
//        ImageSaving.downloadProfilePicture(notification.senderUID, url: notification.senderURL) { (image, error) in
//            guard error == nil && image != nil else {
//                self.notifImage.image = StaticPictures.heart_logo.generatePic()
//                return
//            }
//            self.notifImage.image = image
//        }
//    }
//    func setUpPic() {
//        self.notifImage.contentMode = UIViewContentMode.scaleAspectFill
//        
//        self.notifImage.layer.masksToBounds = false
//        self.notifImage.layer.cornerRadius = self.notifImage.frame.height/2
//        
//        // ---> This puts a border around the image
//        /*
//         self.profilePic.clipsToBounds = true
//         self.profilePic.layer.borderWidth = 4.0
//         self.profilePic.layer.borderColor = UIColor.white.cgColor
//         */
//    }
//    func configureButton() {
//        self.viewButton.layer.cornerRadius = 10.0
//        self.viewButton.layer.masksToBounds = true
//        self.viewButton.backgroundColor = Colors.app_color.generateColor()
//        self.viewButton.setTitleColor(UIColor.black, for: [])
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
