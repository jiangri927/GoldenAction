//
//  PhotoGall.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/22/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftPhotoGallery



class PhotoGall {
    
    var images: [UIImage]
    var vc: UIViewController
    
    init(images: [UIImage], vc: UIViewController) {
        self.images = images
        self.vc = vc
    }
    
    
    
}
