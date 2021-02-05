//
//  FileManager.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 12/04/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit

final class AppFileManager{
    static let sharedInstance = AppFileManager()
    private init() {
        
    }
    
    func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("GoldenActionFolder")
        let url = NSURL(string: path)
        return url!
    }
    
    func saveImageDocumentDirectory(image: UIImage, imageName: String) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("GoldenActionFolder")
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let url = NSURL(string: path)
        let nameComponent = imageName.components(separatedBy: "/")
        let imagePath = url!.appendingPathComponent(nameComponent[1])
        let urlString: String = imagePath!.absoluteString
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)
    }
    
    func imageExistInDcoumentDirectory(imageName: String)->Bool{
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("GoldenActionFolder")
        let url = NSURL(string: path)
        
        let nameComponent = imageName.components(separatedBy: "/")
        if nameComponent.count > 1 {
            let imagePath = url!.appendingPathComponent(nameComponent[1])
            let urlString: String = imagePath!.absoluteString
            return fileManager.fileExists(atPath: urlString)
        }
        
        return false
      
    }
    
    func getImageFromDocumentDirectory(imageName: String)->UIImage {
        let fileManager = FileManager.default
        
        let nameComponent = imageName.components(separatedBy: "/")

            let imagePath = (self.getDirectoryPath() as NSURL).appendingPathComponent(nameComponent[1])
            let urlString: String = imagePath!.absoluteString
            if fileManager.fileExists(atPath: urlString) {
                let image = UIImage(contentsOfFile: urlString)
                return image ?? UIImage(named: "gold_hand_small")!
            }
        return UIImage(named: "gold_hand_small")!
    }
    
}
