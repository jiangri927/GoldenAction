//
//  MainTabViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/8/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

class MainTabViewController: RAMAnimatedTabBarController {

    let layerGradient = CAGradientLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gradientFactory()
        self.gradientButtonFactory(button: nil, navigationBar: self.navigationController?.navigationBar)
        //self.tabBar.barTintColor = Colors.black.generateColor()
        // Do any additional setup after loading the view.
    }
    func gradientFactory() {
//        layerGradient.colors = [Colors.app_color.generateColor().cgColor, UIColor.black.cgColor]
//        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
//        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
//        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        self.tabBar.layer.addSublayer(layerGradient)
        
        let imageColor1 = self.gradient(size: self.layerGradient.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        //self.nominationSponsorButton.layer.borderColor = UIColor.init(patternImage: imageColor1!).cgColor
        self.tabBar.layer.backgroundColor = UIColor.black.cgColor

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Helper functions
    override var shouldAutorotate: Bool {
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
 /*   func gradient(size:CGSize,color:[UIColor]) -> UIImage?{
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
        context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width ,y:size.height), options: [.drawsAfterEndLocation,.drawsBeforeStartLocation])
        
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    } */

}
extension UIViewController {
    var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    func gradientButtonFactory(button: UIButton?, navigationBar: UINavigationBar?) {
        let layerGradient = CAGradientLayer()
        layerGradient.colors = [Colors.app_color.generateColor().cgColor, UIColor.black.cgColor]
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        if button != nil {
            button!.layer.addSublayer(layerGradient)
        } else {
            navigationBar?.layer.addSublayer(layerGradient)
        }
        //self.tabBar.layer.addSublayer(layerGradient)
    }
}
