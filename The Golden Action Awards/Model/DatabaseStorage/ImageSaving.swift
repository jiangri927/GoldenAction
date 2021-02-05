//
//  ImageSaving.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftKeychainWrapper

class ImageSaving {
    var image: UIImage
    var downloadURL: URL?
    var downloadLink: String!
    var ref: StorageReference!
    
    init(image: UIImage) {
        self.image = image
    }
    
    
}
extension ImageSaving {
    
    
    func saveProfPic(userUID: String, completion: @escaping (Error?, String?) -> Void) {
        let data = UIImageJPEGRepresentation(self.image, 0.9)
        ref = GoldenStorage.profile_pics.reference().child(userUID)
        downloadLink = ref.description
        print(downloadLink)
        ref.putData(data!, metadata: nil) { (meta, error) in
            guard error == nil else {
                completion(error, nil)
                print(error!.localizedDescription)
                return
            }
            if let url = meta?.path {
                completion(nil, url)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func saveNomPic(completion: @escaping (Error?, StorageMetadata?) -> Void) {
        let data = UIImageJPEGRepresentation(self.image, 0.9)
        let imageUID = NSUUID().uuidString
        ref = GoldenStorage.nomination_pics.reference().child(imageUID)
        downloadLink = ref.description
        ref.putData(data!, metadata: nil) { (meta, error) in
            guard error == nil else {
                completion(error, nil)
                print(error!.localizedDescription)
                return
            }
            completion(nil, meta)
            
        }
    }
}

// MARK: - Download Images
extension ImageSaving {
    class func downloadProfilePicture(_ uid: String, url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        if let data = KeychainWrapper.standard.data(forKey: Keys.profile_pic(url: url).key) {
            let image = UIImage(data: data)
            completion(image, nil)
        } else {
            GoldenStorage.profile_pics.reference().child(uid).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                guard error == nil && data != nil else {
                    completion(nil, error)
                    return
                }
                let key = Keys.profile_pic(url: url).key
                let workItem = DispatchWorkItem {
                    let image = UIImage(data: data!)
                    completion(image, nil)
                }
                KeychainWrapper.standard.set(data!, forKey: key)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: workItem)
                
            }
        }
    }
    class func downloadNominationPicture(_ imageUID: String, completion: @escaping (UIImage?, Error?) -> Void) {
        if let data = KeychainWrapper.standard.data(forKey: Keys.nom_pics(url: imageUID).key) {
            let image = UIImage(data: data)
            completion(image, nil)
        } else {
            GoldenStorage.nomination_pics.reference().child(imageUID).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                guard error == nil && data != nil else {
                    completion(nil, error)
                    return
                }
                let key = Keys.nom_pics(url: imageUID).key
                let workItem = DispatchWorkItem {
                    let image = UIImage(data: data!)
                    completion(image, nil)
                }
                KeychainWrapper.standard.set(data!, forKey: key)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: workItem)
            }
        }
    }
}
private extension UIImage {
    func resized(profilePic: Bool) -> UIImage {
        let height: CGFloat = 800.0
        let ratio = self.size.width / self.size.height
        let width = height * ratio
        
        let newSize = CGSize(width: width, height: height)
        let newRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: newRectangle)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}
/*
 // MARK: - Storing Profile Picture with uid (Used)
 
 func saveProfPicNext(_ userUID: String, _ completion: @escaping (StorageMetadata?, Error?, String) -> Void) {
 let resizedImage = image.resized()
 let imageData = UIImageJPEGRepresentation(resizedImage, 0.9)
 ref = FIRStore.studentProfilePictures.reference().child(userUID)
 ref.putData(imageData!, metadata: nil) { (meta, error) in
 completion(meta, error, userUID)
 }
 
 }
 
 */
