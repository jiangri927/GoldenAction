//
//  NomCreateCollectionViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 4/19/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class NomCreateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var createNomImage: UIImageView!
    
    
    override func awakeFromNib() {
        self.createNomImage.layer.cornerRadius = 5
        self.createNomImage.clipsToBounds = true
        
    }
    
    func configureCell(img: UIImage) {
        self.createNomImage.image = img
        //self.createNomImage.contentMode = UIViewContentMode.scaleAspectFit
    }
}
