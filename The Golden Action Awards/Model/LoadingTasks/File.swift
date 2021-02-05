//
//  File.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/22/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Nuke
import UIKit
import Toucan
import SwiftKeychainWrapper

enum NukeLoad {
    
    case nomination_cell // --> W84xH84
    case nomination_detail // --> W97xH97
    case nomination_detail_profile // --> W100xH100
    
    
    case profile_pic // --> W98xH98
    case profile_items // --> W37xH37
    case notification_cell // --> W68xH68
    case search_cell // ---> W84xH84
    case accept_nomination_cell // --> W97xH97
    case accept_nomination_profile // --> W49xH49
    
    
    case admin_cells // --> W50xH50
    
    func imageLoadFinish(view: UIImageView, urlString: String) {
        guard urlString != "" else {
            return
        }
        guard urlString != "N/A" else {
            return
        }
        let url = URL(string: urlString)
        guard url != nil else {
            return
        }
        let options = ImageLoadingOptions(placeholder: StaticPictures.head_logo.generatePic(), transition: .fadeIn(duration: 0.33), failureImage: StaticPictures.head_logo.generatePic(), failureImageTransition: .fadeIn(duration: 0.33), contentModes: ImageLoadingOptions.ContentModes.init(success: .scaleAspectFit, failure: .scaleAspectFit, placeholder: .scaleAspectFit))
        var req = ImageRequest(url: url!, targetSize: size, contentMode: .aspectFit)
        req.priority = .high
        
        switch self {
        case .nomination_cell:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .nomination_detail:
            req.process(key: "squares") {
                let data = UIImageJPEGRepresentation($0, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return $0
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .nomination_detail_profile:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case.profile_pic:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .profile_items:
            req.process(key: "squares") {
                let data = UIImageJPEGRepresentation($0, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return $0
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .search_cell:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .accept_nomination_cell:
            req.process(key: "squares") {
                let data = UIImageJPEGRepresentation($0, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return $0
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .accept_nomination_profile:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .admin_cells:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        case .notification_cell:
            req.process(key: "circular") {
                let img = Toucan(image: $0).maskWithEllipse().image
                let data = UIImageJPEGRepresentation(img!, 0.9)
                KeychainWrapper.standard.set(data!, forKey: urlString)
                return img
            }
            Nuke.loadImage(with: req, options: options, into: view)
        }
    }
    
    private var size: CGSize {
        switch self {
        case .nomination_cell:
            return CGSize(width: 84.0, height: 84.0)
        case .nomination_detail:
            return CGSize(width: 291.0, height: 291.0)
        case .nomination_detail_profile:
            return CGSize(width: 100.0, height: 100.0)
        case .profile_pic:
            return CGSize(width: 98.0, height: 98.0)
        case .profile_items:
            return CGSize(width: 37.0, height: 37.0)
        case .notification_cell:
            return CGSize(width: 68.0, height: 68.0)
        case .search_cell:
            return CGSize(width: 84.0, height: 84.0)
        case .accept_nomination_cell:
            return CGSize(width: 97.0, height: 97.0)
        case .accept_nomination_profile:
            return CGSize(width: 49.0, height: 49.0)
        case .admin_cells:
            return CGSize(width: 50.0, height: 50.0)
        }
    }
}

