//
//  Extention+String.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 13/06/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit


//extension String {
//    func firstCharacterUpperCase() -> String {
//        let lowercaseString = self.lowercased
//        
//        return lowercaseString().stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString)
//    }
//}


extension UILabel
{
    func setGradiantColor()
    {
        let colorImage = gradient1(size: self.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.textColor = UIColor.init(patternImage: colorImage!)
    }
    
}


func gradient1(size:CGSize,color:[UIColor]) -> UIImage?{
    //turn color into cgcolor
    let colors = color.map{$0.cgColor}
    //begin graphics context
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }
    // From now on, the context gets ended if any return happens
    defer {UIGraphicsEndImageContext()}
    //create core graphics context
    let locations:[CGFloat] = [0.0,1.0]
    guard let gredient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as NSArray as CFArray, locations: locations) else {
        return nil
    }
    
    //draw the gradient
    context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width,y:size.height), options: [])
    // Generate the image (the defer takes care of closing the context)
    return UIGraphicsGetImageFromCurrentImageContext()
}




extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Float.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    func endRotate() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
}



extension UIViewController {
    
    func gradient(size:CGSize,color:[UIColor]) -> UIImage?{
        //turn color into cgcolor
        let colors = color.map{$0.cgColor}
        //begin graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        // From now on, the context gets ended if any return happens
        defer {UIGraphicsEndImageContext()}
        //create core graphics context
        let locations:[CGFloat] = [0.0,1.0]
        guard let gredient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as NSArray as CFArray, locations: locations) else {
            return nil
        }
        
        //draw the gradient
        context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width,y:size.height), options: [])
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func setBarTint() {
        let colorImage = gradient(size: (self.navigationController?.navigationBar.frame.size)!, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.navigationController?.navigationBar.barTintColor = UIColor.init(patternImage: colorImage!)
    }
    
    func setBarButtonTint() {
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func checkInternet() -> Bool{
        guard InternetConnection.instance.isInternetAvailable() else {
            self.error(title: "No Internet", message: "Golden Action Awards requires internet connection, please make sure you have internet before proceeding", error: nil)
            return false
        }
        return true
    }
    
    func generateTitleView(currentCategory: String) -> UIImage {
        switch currentCategory {
        case FilterStrings.hand_category.id:
            return StaticPictures.titleview_hand.generatePic()
        case FilterStrings.head_category.id:
            return StaticPictures.titleview_head.generatePic()
        case FilterStrings.heart_category.id:
            return StaticPictures.titleview_heart.generatePic()
        case FilterStrings.health_category.id:
            return StaticPictures.titleview_health.generatePic()
        default:
            return StaticPictures.titleview_head.generatePic()
        }
    }
    func generateIcon(currentCategory: String) -> UIImage {
        switch currentCategory {
        case FilterStrings.hand_category.id:
            return StaticPictures.gold_hand.generatePic()
        case FilterStrings.head_category.id:
            return StaticPictures.gold_head.generatePic()
        case FilterStrings.heart_category.id:
            return StaticPictures.gold_heart.generatePic()
        case FilterStrings.health_category.id:
            return StaticPictures.gold_health.generatePic()
        default:
            return StaticPictures.gold_head.generatePic()
        }
    }
    
    func tabBarButtonEdit(enabled: Bool) {
        let count = [0, 1, 2]
        if enabled {
            for c in count {
                if let items = self.tabBarController?.tabBar.items as Any as? NSArray, let item = items[c] as? UITabBarItem {
                    item.isEnabled = true
                } else {
                    print("Item does not exist!!!")
                }
            }
        } else {
            for c in count {
                if let items = self.tabBarController?.tabBar.items as Any as? NSArray, let item = items[c] as? UITabBarItem {
                    item.isEnabled = false
                } else {
                    print("Item does not exist!!!")
                }
            }
        }
    }
    
    func tapDismissSearch(searchVC: UISearchController) {
        
    }
    
    func tapDismiss() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
