//
//  AwardDetailCollectionViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/31/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class AwardDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var awardeePhoto: UIImageView!
    
    
    func configureCell(img: UIImage) {
        self.awardeePhoto.image = img
        self.awardeePhoto.contentMode = UIViewContentMode.scaleAspectFit
    }
}
