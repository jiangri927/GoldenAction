//
//  NomDetailCollectionViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/17/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class NomDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nomineeSuppPhoto: UIImageView!
    
    
//    func configureCell(img: UIImage) {
//        
//        self.nomineeSuppPhoto.layer.cornerRadius = 5
//        self.nomineeSuppPhoto.layer.borderWidth = 1
//        self.nomineeSuppPhoto.layer.borderColor = UIColor.black.cgColor
//        self.nomineeSuppPhoto.clipsToBounds = true
//        
//        self.nomineeSuppPhoto.image = img
//        //self.nomineeSuppPhoto.contentMode = UIViewContentMode.scaleAspectFit
//    }
    
    
    override func awakeFromNib() {
        self.nomineeSuppPhoto.layer.cornerRadius = 5
        self.nomineeSuppPhoto.layer.borderWidth = 1
        self.nomineeSuppPhoto.layer.borderColor = UIColor.black.cgColor
        self.nomineeSuppPhoto.clipsToBounds = true
    }
}
