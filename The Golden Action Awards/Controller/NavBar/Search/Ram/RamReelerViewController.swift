//
//  RamReelViewController.swift
//  Bonita-Admin
//
//  Created by Michael Kunchal on 9/3/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import RAMReel
enum SearchReason {
    case location
    case users
    case nominations
    case awards
    case admins
    case charities
    
    var id: Int {
        switch self {
        case .location:
            return 0
        case .users:
            return 1
        case .nominations:
            return 2
        case .awards:
            return 3
        case .admins:
            return 4
        case .charities:
            return 5
        }
    }
    
    
    
    
}
class RamReelViewController: UIViewController, UICollectionViewDelegate {
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    var reason: Int!
    var pickedUID: String!
    var pickedCity: String!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var data: [String] = ["Hey", "Sup", "Bro", "Name", "Wassup"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = SimplePrefixQueryDataSource(data)
        
        self.ramReel = RAMReel(frame: view.bounds, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: true) {
            print("Plain:", $0)
        }
        // self.ramReel.theme.listBackgroundColor = UIColor.black
        // self.ramReel.theme.textColor = Colors.app_text.generateColor()
        self.ramReel.hooks.append {
            let r = Array($0.reversed())
            let j = String(r)
            print("Reversed:", j)
        }
        self.view.addSubview(ramReel.view)
        self.ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupBondBarButton() {
        self.submitButton.reactive.tap.observeNext {
            let workItem = self.parseReason()
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    func parseReason() -> DispatchWorkItem {
        switch reason {
        case SearchReason.location.id:
            let workItem = DispatchWorkItem {
                print("Location Reason")
            }
            return workItem
            // Do Something that invloves storing Location (Cluster Somewhere)
            
        case SearchReason.users.id:
            let workItem = DispatchWorkItem {
                print("Users Reason")
            }
            return workItem
        case SearchReason.nominations.id:
            let workItem = DispatchWorkItem {
                print("Nomintaions Reason")
            }
            return workItem
        case SearchReason.awards.id:
            let workItem = DispatchWorkItem {
                print("Awards Reason")
            }
            return workItem
        case SearchReason.admins.id:
            let workItem = DispatchWorkItem {
                print("Admin Reason")
            }
            return workItem
        case SearchReason.charities.id:
            let workItem = DispatchWorkItem {
                print("Charities Reason")
            }
            return workItem
        default:
            let workItem = DispatchWorkItem {
                print("Unknown Reason")
            }
            return workItem
        }
    }
    /*
    fileprivate let data: [String] = {
        do {
            guard let dataPath = Bundle.main.path(forResource: "data", ofType: "txt") else {
                return []
            }
            
            let data = try RamReader(filepath: dataPath)
            return data.words
        }
        catch let error {
            print(error)
            return []
        }
    }()*/
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
