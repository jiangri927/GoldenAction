//
//  ImagePicker.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import ImagePicker
import CropViewController
import MobileCoreServices
import SCLAlertView

typealias ImageCompletion = ((UIImage?) -> Void)?
class GoldenImagePicker: NSObject {
    
    let phoneApperance = SCLAlertView.SCLAppearance(kDefaultShadowOpacity: 0.7, kCircleHeight: 85, kCircleIconHeight: 75, showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false, contentViewCornerRadius: 10.0, fieldCornerRadius: 10.0, buttonCornerRadius: 10.0, hideWhenBackgroundViewIsTapped: false, circleBackgroundColor: UIColor.black, contentViewColor: UIColor.white, contentViewBorderColor: Colors.app_text.generateColor(), titleColor: Colors.app_text.generateColor(), dynamicAnimatorActive: true, disableTapGesture: false, buttonsLayout: .vertical, activityIndicatorStyle: .gray)
    weak var viewController: UIViewController!
    var completion: ImageCompletion
    var type: Int! // Use CropType Enum
    var source: String!
    var alertView:SCLAlertView!
    
    var imgPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    var customImgPicker: ImagePickerController = {
        let picker = ImagePickerController()
        picker.preferredImageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        picker.galleryView.isHidden = true
        return picker
    }()
    
    init(viewController: UIViewController, type: Int, completion: ImageCompletion) {
        super.init()
        self.viewController = viewController
        self.type = type
        self.completion = completion
        self.showPhotoAlert()
        
    }
    func showPhotoAlert() {
        self.alertView = SCLAlertView(appearance: self.phoneApperance)
        self.alertView.addButton("Camera", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            self.showPhotoSource(sourceType: .camera)
            self.source = "camera"
        }
        self.alertView.addButton("Photo Library", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            self.showPhotoSource(sourceType: .photoLibrary)
            self.source = "library"
        }
        self.alertView.addButton("Cancel", backgroundColor: Colors.app_text.generateColor(), textColor: Colors.black.generateColor(), showTimeout: nil) {
            self.alertView.hideView()
        }
        self.alertView.showInfo("Photos", subTitle: "")
    }
    func showPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Photo", message: "Open photo library or camera?", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.showPhotoSource(sourceType: .camera)
            self.source = "camera"
            
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.showPhotoSource(sourceType: .photoLibrary)
            self.source = "library"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    func showPhotoSource(sourceType: UIImagePickerControllerSourceType) {
        if sourceType == .camera {
            //let imagePicker = ImagePickerController()
            self.alertView.hideView()
            self.customImgPicker.delegate = self
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureRecognizer(gesture:)))
            self.customImgPicker.bottomContainer.addGestureRecognizer(gesture)
            self.customImgPicker.topView.addGestureRecognizer(gesture)
            self.viewController.present(customImgPicker, animated: true, completion: nil)
            /* imagePicker.navigationItem.hidesBackButton = true
             viewController.navigationController?.setNavigationBarHidden(true, animated: false)
             let gesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureRecognizer(gesture:)))
             imagePicker.bottomContainer.addGestureRecognizer(gesture)
             imagePicker.topView.addGestureRecognizer(gesture)
             imagePicker.view.addGestureRecognizer(gesture)
             imagePicker.preferredImageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
             imagePicker.galleryView.isHidden = true
             viewController.navigationController?.pushViewController(imagePicker, animated: true) */
        } else if sourceType == .photoLibrary {
            self.alertView.hideView()
            imgPicker.delegate = self
            viewController.present(imgPicker, animated: true, completion: nil)
            /*  let imagePicker = UIImagePickerController()
             imagePicker.allowsEditing = true
             imagePicker.sourceType = sourceType
             imagePicker.allowsEditing = false
             imagePicker.mediaTypes = [kUTTypeImage as String]
             imagePicker.delegate = self
             viewController.present(imagePicker, animated: true, completion: nil) */
        }
    }
    @objc func gestureRecognizer(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            self.viewController.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension GoldenImagePicker : ImagePickerDelegate, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images != [] else {
            // Add Alert
            self.viewController.dismiss(animated: true, completion: nil)
            
            return
        }
        self.setUpCrop(img: images[images.count - 1], type: self.type)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images != [] else {
            self.viewController.dismiss(animated: true, completion: nil)
            
            return
        }
        self.setUpCrop(img: images[images.count - 1], type: self.type)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Crop Delegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        if self.source == "camera" {
            self.customImgPicker.delegate = self
            
            self.customImgPicker.dismiss(animated: false, completion: nil)
            self.viewController.dismiss(animated: false, completion: nil)
            completion!(image)
        } else {
            self.imgPicker.delegate = self
            self.imgPicker.dismiss(animated: false, completion: nil)
            self.viewController.dismiss(animated: false, completion: nil)
            completion!(image)
        }
    }
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled {
            if self.source == "camera" {
                self.customImgPicker.delegate = self
                let gesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureRecognizer(gesture:)))
                self.customImgPicker.bottomContainer.addGestureRecognizer(gesture)
                self.customImgPicker.topView.addGestureRecognizer(gesture)
                self.customImgPicker.dismiss(animated: false, completion: nil)
            } else {
                self.imgPicker.delegate = self
                self.imgPicker.dismiss(animated: false, completion: nil)
            }
        }
    }
    // MARK: - Photo Library Support for Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.viewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.setUpCrop(img: img!, type: self.type)
    }
    
    // MARK: - Setting up Crop Function
    func setUpCrop(img: UIImage, type: Int) {
        let cropVC: CropViewController!
        if type == CropType.prof_pic.type {
            cropVC = CropViewController(croppingStyle: .circular, image: img)
            cropVC.delegate = self
        } else {
            cropVC = CropViewController(croppingStyle: .default, image: img)
            cropVC.delegate = self
        }
        
        if self.source == "camera" {
            self.customImgPicker.delegate = self
            
            self.customImgPicker.present(cropVC, animated: true, completion: nil)
        } else {
            self.imgPicker.delegate = self
            self.imgPicker.present(cropVC, animated: true, completion: nil)
            
        }
    }
}
enum CropType {
    case prof_pic
    case nominee_supp_pic
    
    var type: Int {
        switch self {
        case .prof_pic:
            return 0
            
        case .nominee_supp_pic:
            return 1
        }
    }
    
    
}






