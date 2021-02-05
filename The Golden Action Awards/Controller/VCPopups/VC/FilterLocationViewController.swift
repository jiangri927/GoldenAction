//
//  FilterLocationViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SearchTextField
import Firebase
import FirebaseDatabase

class FilterLocationViewController: UIViewController {

    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchField: SearchTextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var searchLine: UIView!
    var searches = [SearchTextFieldItem]()
    var selectedItem: SearchTextFieldItem!
    
    var nominationVC: NomineesViewController!
    var awardsVC: AwardsViewController!
    
    var nomination: Bool!
    var uid: String!
    var cityState: String!
    var cluster: String!
    var currentUserCity: String!
    var currentUserCluster: String!
    
    var currentLocationRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapDismiss()
        if self.uid != nil {
            if self.nomination {
                self.currentLocationRef = DBRef.userLastNomLocation(uid: self.uid).reference()
            } else {
                self.currentLocationRef = DBRef.userLastAwardLocation(uid: self.uid).reference()
            }
        } else {
            // MARK: - Put something that resigns someone in if they someone fuck up or if I fucked up somewhere --> either or :P
        }
        
        //let popularSearch = SearchTextFieldItem(title: "Popular", subtitle: "", cluster: "000")
        //self.searches.append(popularSearch)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        self.locationView.backgroundColor = UIColor.black
        self.locationView.layer.cornerRadius = 10.0
        self.locationView.layer.masksToBounds = true
        
        self.titleLabel.font = Fonts.hira_pro_six.generateFont(size: 21.0)
        self.titleLabel.textColor = Colors.app_text.generateColor()
        self.titleLabel.text = "Filter Location"
        
        self.popularButton.backgroundColor = Colors.nom_detail_innerBorder.generateColor()
        self.popularButton.setAttributedTitle(Strings.buttons.generateString(text: "Popular"), for: [])
        self.popularButton.layer.cornerRadius = 10.0
        self.popularButton.layer.masksToBounds = true
        self.popularButton.addTarget(self, action: #selector(popularDidTap(_:)), for: .touchUpInside)
        
        self.searchButton.backgroundColor = Colors.nom_detail_innerBorder.generateColor()
        self.searchButton.setAttributedTitle(Strings.buttons.generateString(text: "Search"), for: [])
        self.searchButton.layer.cornerRadius = 10.0
        self.searchButton.layer.masksToBounds = true
        
        self.cancelButton.backgroundColor = Colors.nom_detail_firstBackground.generateColor()
        self.cancelButton.setAttributedTitle(Strings.buttons.generateString(text: "Cancel"), for: [])
        self.cancelButton.layer.cornerRadius = 10.0
        self.cancelButton.layer.masksToBounds = true
        
        self.searchLine.backgroundColor = Colors.app_text.generateColor()
        self.searchField.theme.bgColor = UIColor.black
        self.searchField.theme.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        self.searchField.theme.fontColor = Colors.app_text.generateColor()
        self.searchField.borderStyle = .none
        self.searchField.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: self.cityState)
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.searchField.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title), \(item.subtitle!)")
            self.selectedItem = item
            self.resignFirstResponder()
        }
        self.searchField.itemSelectionHandler = closure
        self.implementGestures()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func popularDidTap(_ sender: UIButton!) {
        self.setUpLocationController(popular: true)
    }
    @IBAction func searchDidTap(_ sender: Any) {
        guard self.selectedItem != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.setUpLocationController(popular: false)
    }
    func setUpLocationController(popular: Bool) {
        if popular {
            let city = Cities(cluster: "000", cityState: "Popular")
            self.currentLocationRef.setValue(city.toDictionary())
            let refreshControl = UIRefreshControl()
            if "000" != self.cluster {
                if self.nomination {
                    self.nominationVC.refresh(refreshControl)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.awardsVC.refresh(refreshControl)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            let cityState = "\(self.selectedItem.title), \(self.selectedItem.subtitle!)"
            let obj: Cities!
            if self.selectedItem.cluster! == "000" {
                obj = Cities(cluster: self.selectedItem.cluster!, cityState: self.selectedItem.title)
            } else {
                obj = Cities(cluster: self.selectedItem.cluster!, cityState: cityState)
            }
            self.currentLocationRef.setValue(obj.toDictionary())
            let refreshControl = UIRefreshControl()
            if self.selectedItem.cluster! != self.cluster {
                if self.nomination {
                    self.nominationVC.refresh(refreshControl)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.awardsVC.refresh(refreshControl)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func locationTyping(_ sender: Any) {
        self.searchField.showLoadingIndicator()
//        SearchAlg.instance.loadCityQuery(query: self.searchField.text!) { (searches) in
//            guard searches != nil else {
//                return
//            }
//            self.searches = searches!
//            self.searchField.filterItems(searches!)
//            self.searchField.startSuggestingInmediately = true
//            self.searchField.stopLoadingIndicator()
//        }
    }
    
    // MARK: - Gesture Recognizer Delegate
    func implementGestures() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        gesture.direction = .down
        self.locationView.isUserInteractionEnabled = true
        self.locationView.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            switch gesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
        
    }
    

}
extension FilterLocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.searchField {
            if self.selectedItem == nil {
                self.searchField.placeholder = nil
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.searchField {
            if self.selectedItem == nil {
                self.searchField.placeholder = nil
            }
        }
    }
    
    
}

