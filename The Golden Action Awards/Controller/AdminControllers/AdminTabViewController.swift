//
//  AdminTabViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/24/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SideMenu
import RAMAnimatedTabBarController

class AdminTabViewController: RAMAnimatedTabBarController {

    let layerGradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSideMenu()
        self.showCustomCherityMessage()
        // Do any additional setup after loading the view.
    }
    func gradientFactory() {
        layerGradient.colors = [Colors.app_color.generateColor().cgColor, Colors.black.generateColor().cgColor]
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        self.tabBar.layer.addSublayer(layerGradient)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func setupSideMenu() {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: VCID.side_table.id) as! AdminSideMenuTableViewController
//        let menuLeftNav = UISideMenuNavigationController(rootViewController: vc)
//        SideMenuManager.default.menuLeftNavigationController = menuLeftNav
    }
    
    func showCustomCherityMessage(){
        let ref = CollectionFireRef.charity.reference()
        ref.whereField("isAdminVerified", isEqualTo: false).getDocuments(completion: {(snapshot, error) in
            if error == nil {
                if let data = snapshot?.documents {
                    for d in data {
                        let singleData = d.data()
                        var isVerified = singleData["isAdminVerified"] as! Bool ?? true
                        if isVerified == false {
                           // self.goldenAlert(title: "Charity!", message: "Charity contains one custom entry, please verify it.", view: self)
                        }
                    }
                }
            }
            
        })
        
    }
}

