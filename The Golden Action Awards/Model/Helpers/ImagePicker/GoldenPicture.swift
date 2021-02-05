//
//  GoldenPicture.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/27/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import ALCameraViewController
import MobileCoreServices


class GoldenPicture: NSObject {
    
    
    weak var viewController: UIViewController!
    var completion: ImageCompletion
    var type: Int!
    var source: String!
    
    
    var imgPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    
    init(viewController: UIViewController, type: Int, completion: @escaping CameraViewCompletion) {
        super.init()
        self.viewController = viewController
        self.type = type
        self.showPhotoSource(completion: completion)
        
        
        //self.showPhotoActionSheet(completion: completion)
        
    }
    func showPhotoActionSheet(completion: @escaping CameraViewCompletion) {
        let actionSheet = UIAlertController(title: "Photo", message: "Open photo library or camera?", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
           // self.showPhotoSource(sourceType: .camera, completion: completion)
            self.source = "camera"
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
           // self.showPhotoSource(sourceType: .photoLibrary, completion: completion)
            self.source = "library"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        self.viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    // viewController.present(cameraVC, animated: true, completion: nil)
    func showPhotoSource(completion: @escaping CameraViewCompletion) {
        CameraView().autoresizingMask = UIViewAutoresizing.flexibleHeight
        CameraView().autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        let cameraVC = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] (image, asset) in
            completion(image, asset)
            self?.viewController.dismiss(animated: true, completion: nil)
        }
        viewController.present(cameraVC, animated: true, completion: nil)
        /*if sourceType == .camera {
            let cameraVC = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] (image, asset) in
                //self?.imageView.image = image
                completion(image, asset)
                self?.viewController.dismiss(animated: true, completion: nil)
            }*/
            /*let cameraViewController = CameraViewController(croppingParameters: self.croppingParameters, allowsLibraryAccess: false) { [weak self] image, asset in
                //self?.imageView.image = image
                completion(image, asset)
                self?.viewController.dismiss(animated: true, completion: nil)
            }*/
            
            /*viewController.present(cameraVC, animated: true, completion: nil)
        } else if sourceType == .photoLibrary {
            let libraryVC = CameraViewController.imagePickerViewController(croppingParameters: self.croppingParameters) { [weak self] (image, asset) in
                completion(image, asset)
                self?.viewController.dismiss(animated: true, completion: nil)
            }*/
            /*let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: self.croppingParameters) { [weak self] image, asset in
                completion(image, asset)
                self?.viewController.dismiss(animated: true, completion: nil)
            } */
            
            //viewController.present(libraryVC, animated: true, completion: nil)
        //}
    }
    
}
