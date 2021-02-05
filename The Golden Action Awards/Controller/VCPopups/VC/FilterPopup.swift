//
//  FilterPopup.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/31/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Firebase
import NYAlertViewController
import SearchTextField
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging



enum FilterStrings {
    
    case heart
    case head
    case all
    case hand
    case health
    
    case heart_category
    case health_category
    case head_category
    case hand_category
    case all_category
    case popular_location
    
    var id: String {
        switch self {
        case .head_category:
            return "Head Category"
        case .health_category:
            return "Health Category"
        case .heart_category:
            return "Heart Category"
        case .hand_category:
            return "Hand Category"
        case .all_category:
            return "All"
        case .popular_location:
            return "Popular"
        case .heart:
            return "HEART"
        case .head:
            return "HEAD"
        case .health:
            return "HEALTH"
        case .hand:
            return "HAND"
        case .all:
            return "All"
        }
    }
}
class FilterPopup: NSObject, NSCoding {
    
    var vc: UIViewController!
    var popup: NYAlertViewController!
    var filterType: String!
    var currentCategoryRef: DatabaseReference!
    var currentLocationRef: DatabaseReference!
    var nomination: Bool!
    var uid: String!
    var selectedItem: SearchTextFieldItem! // Edited function to have city as title, state as subtitle and then added cluster as cluster
    var searches = [SearchTextFieldItem]()
    var locationField: SearchTextField!
    var locatiField: SearchTextField {
        let field = SearchTextField()
        field.theme.bgColor = UIColor.black
        field.theme.fontColor = Colors.app_text.generateColor()
        field.theme.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        field.borderStyle = .roundedRect
        return field
    }
    
    
    init(vc: UIViewController, filterType: String, nomination: Bool, uid: String) {
        self.vc = vc
        self.filterType = filterType
        self.nomination = nomination
        self.uid = uid
        if nomination {
            self.currentLocationRef = DBRef.userLastNomLocation(uid: uid).reference()
            self.currentCategoryRef = DBRef.userLastNomCategory(uid: uid).reference()
        } else {
            self.currentCategoryRef = DBRef.userLastAwardCategory(uid: uid).reference()
            self.currentLocationRef = DBRef.userLastAwardLocation(uid: uid).reference()
        }
        let field = SearchTextField()
        field.theme.bgColor = UIColor.black
        field.theme.fontColor = Colors.app_text.generateColor()
        field.theme.font = Fonts.hira_pro_three.generateFont(size: 14.0)
        field.borderStyle = .roundedRect
        field.attributedPlaceholder = LoginStrings.welcome_email.generateString(text: self.filterType)
        self.locationField = field
    }
    
    init(vc: UIViewController, popup: NYAlertViewController, filterType: String) {
        self.vc = vc
        self.popup = popup
        self.filterType = filterType
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var vc: UIViewController!
        if let test = aDecoder.decodeObject(forKey: "vc") as? NomineesViewController {
            vc = test
        } else {
            vc = aDecoder.decodeObject(forKey: "vc") as! AwardsViewController
        }
        let popup  = aDecoder.decodeObject(forKey: "popup") as! NYAlertViewController
        let filter = aDecoder.decodeObject(forKey: "filter") as? String ?? ""
        self.init(vc: vc, popup: popup, filterType: filter)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.vc, forKey: "vc")
        aCoder.encode(self.popup, forKey: "popup")
        aCoder.encode(self.filterType, forKey: "filter")
    }
    
    func createLocationPopup() {
        self.popup = NYAlertViewController()
        self.popup.alertViewBackgroundColor = Colors.popup_background.generateColor()
        self.popup.buttonCornerRadius = 10.0
        // Title
        self.popup.title = "Filter Location"
        self.popup.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
        self.popup.titleColor = Colors.app_text.generateColor()
        // Message
        self.popup.message = nil
        self.locationField.addTarget(self, action: #selector(userTypingLocation(_:)), for: UIControlEvents.editingChanged)
        let closure: SearchTextFieldItemHandler = { (content: [SearchTextFieldItem], row: Int) in
            let item = content[row]
            self.locationField.attributedText = LoginStrings.welcome_email.generateString(text: "\(item.title), \(item.subtitle!)")
            self.selectedItem = item
            self.popup.resignFirstResponder()
        }
        self.popup.addTextField { (textField) in
            guard textField is SearchTextField else {
                print("Guard statement fired for search field")
                return
            }
            if let textField = textField as? SearchTextField {
                self.locationField = textField
                self.locationField.itemSelectionHandler = closure
            } else {
                print("Cannot cast!!")
            }
        }
        
        
        // Buttons
        let cancelAction = NYAlertAction(title: "Cancel", style: .cancel) { (_) in
            // Put if statement in here to see if they need nominations and if not then display the New Nomination Screen.
            let workItem = DispatchWorkItem {
                let checkoutVC = self.vc.storyboard?.instantiateViewController(withIdentifier: VCID.cart_screen.id) as! CartViewController
                let navController = UINavigationController(rootViewController: checkoutVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.vc.present(navController, animated:true, completion: nil)
            }
            self.vc.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(20), execute: workItem)
        }
        self.popup.cancelButtonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        self.popup.cancelButtonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.cancelButtonColor = Colors.nom_detail_firstBackground.generateColor()
        
        let searchAction = NYAlertAction(title: "Search", style: .default) { (_) in
            self.setUpLocationController()
        }
        self.popup.buttonTitleFont = Fonts.hira_pro_six.generateFont(size: 15.0)
        self.popup.buttonTitleColor = Colors.nom_detail_innerBackground.generateColor()
        self.popup.buttonColor = Colors.nom_detail_innerBorder.generateColor()
        // Actions
        self.popup.addAction(searchAction)
        self.popup.addAction(cancelAction)
        
        
        self.popup.swipeDismissalGestureEnabled = true
        self.popup.backgroundTapDismissalGestureEnabled = true
    }
    @objc func userTypingLocation(_ sender: SearchTextField) {
        self.locationField.showLoadingIndicator()
       /* SearchAlg.instance.loadCityQuery(query: self.locationField.text!) { (searches) in
            guard searches != nil else {
                return
            }
            self.searches = searches!
            self.locationField.filterItems(searches!)
            self.locationField.startSuggestingInmediately = true
            self.locationField.stopLoadingIndicator()
        } */
    }
    func setUpLocationController() {
        let cityState = "\(self.selectedItem.title), \(self.selectedItem.subtitle!)"
        let obj = Cities(cluster: self.selectedItem.cluster!, cityState: cityState)
        self.currentLocationRef.setValue(obj.toDictionary())
        let loadingVC = self.vc.storyboard?.instantiateViewController(withIdentifier: VCID.loading_screen.id) as! LoadingViewController
        self.vc.present(loadingVC, animated: false, completion: nil)
        if self.nomination {
            let nominees = self.vc as! NomineesViewController
            nominees.startNeededChain()
        } else {
            let awards = self.vc as! AwardsViewController
            awards.startNeededChain(loadView: loadingVC)
        }
    }
    func createCategoryPopup() {
        self.popup = NYAlertViewController()
        self.popup.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.35)
        self.popup.alertViewBackgroundColor = Colors.popup_background.generateColor()
        self.popup.buttonCornerRadius = 10.0
        // Title
        self.popup.title = "Filter Category"
        self.popup.titleFont = Fonts.hira_pro_six.generateFont(size: 21.0)
        self.popup.titleColor = Colors.app_text.generateColor()
        // Message
        self.popup.message = nil
        //self.popup.messageFont = Fonts.hira_pro_three.generateFont(size: 17.0)
        //self.popup.messageColor = Colors.app_text.generateColor()
        // Button Designs
        self.popup.cancelButtonColor = Colors.filter_selected_button_background.generateColor() // Selected
        self.popup.cancelButtonTitleColor = Colors.filter_selected_text.generateColor() // Selected
        self.popup.buttonColor = Colors.filter_unselected_button_background.generateColor() // Unselected
        self.popup.buttonTitleColor = Colors.filter_unselected_text.generateColor() // Unselected
        // Action Generation
        self.findCurrentCategory()
        
        self.popup.swipeDismissalGestureEnabled = true
        self.popup.backgroundTapDismissalGestureEnabled = true
    }
    func findCurrentCategory() {
        let heart = FilterStrings.heart_category.id
        let hand = FilterStrings.hand_category.id
        let head = FilterStrings.head_category.id
        let health = FilterStrings.health_category.id
        let all = FilterStrings.all_category.id
        
        switch self.filterType {
        case all,"Categories":
            let uid = Auth.auth().currentUser?.uid ?? "none"
            let selectedAction = NYAlertAction(title: hand, style: .cancel, handler: { (action: NYAlertAction!) -> Void in
                print("hand category tapped")
                self.popup.dismiss(animated: true, completion: nil)
            })
            
            self.popup.addAction(selectedAction)
            let loopArray = [heart, head, health, hand]
            for title in loopArray {
                if title != self.filterType {
                    let unselectedAction = NYAlertAction(title: title, style: .default, handler: { (_) in
                        // Signal to home VC that the category has changed and load view accordingly
                        // Show LOAD SCREEN
                        // MARK: - Add async function to load data tonight!!!!!
                        if title != all {}
                        self.setUpCategoryController(uid: uid, title: title)
                    })
                    self.popup.addAction(unselectedAction)
                }
            }
        case hand:
            let uid = Auth.auth().currentUser?.uid ?? "none"
            let selectedAction = NYAlertAction(title: hand, style: .cancel, handler: { (_) in
                self.popup.dismiss(animated: true, completion: nil)
            })
            self.popup.addAction(selectedAction)
            let loopArray = [heart, head, health, all]
            for title in loopArray {
                if title != self.filterType {
                    let unselectedAction = NYAlertAction(title: title, style: .default, handler: { (_) in
                        // Signal to home VC that the category has changed and load view accordingly
                        // Show LOAD SCREEN
                        // MARK: - Add async function to load data tonight!!!!!
                        if title != all {}
                        self.setUpCategoryController(uid: uid, title: title)
                        
                        
                    })
                    self.popup.addAction(unselectedAction)
                }
            }
        case health:
            let uid = Auth.auth().currentUser?.uid ?? "none"
            let selectedAction = NYAlertAction(title: health, style: .cancel, handler: { (_) in
                self.popup.dismiss(animated: true, completion: nil)
            })
            self.popup.addAction(selectedAction)
            let loopArray = [heart, head, hand, all]
            for title in loopArray {
                if title != self.filterType {
                    let unselectedAction = NYAlertAction(title: title, style: .default, handler: { (_) in
                        // Signal to home VC that the category has changed and load view accordingly
                        // Show LOAD SCREEN
                        // MARK: - Add async function to load data tonight!!!!!
                        if title != all {}
                        self.setUpCategoryController(uid: uid, title: title)
                        
                        
                    })
                    self.popup.addAction(unselectedAction)
                }
            }
        case heart:
            let uid = Auth.auth().currentUser?.uid ?? "none"
            let selectedAction = NYAlertAction(title: heart, style: .cancel, handler: { (_) in
                self.popup.dismiss(animated: true, completion: nil)
            })
            self.popup.addAction(selectedAction)
            let loopArray = [hand, head, health, all]
            for title in loopArray {
                if title != self.filterType {
                    let unselectedAction = NYAlertAction(title: title, style: .default, handler: { (_) in
                        // Signal to home VC that the category has changed and load view accordingly
                        // Show LOAD SCREEN
                        // MARK: - Add async function to load data tonight!!!!!
                        if title != all {}
                        self.setUpCategoryController(uid: uid, title: title)
                        
                        
                    })
                    self.popup.addAction(unselectedAction)
                }
            }
        case head:
            let uid = Auth.auth().currentUser?.uid ?? "none"
            let selectedAction = NYAlertAction(title: head, style: .cancel, handler: { (_) in
                self.popup.dismiss(animated: true, completion: nil)
            })
            self.popup.addAction(selectedAction)
            let loopArray = [heart, hand, health, all]
            for title in loopArray {
                if title != self.filterType {
                    let unselectedAction = NYAlertAction(title: title, style: .default, handler: { (_) in
                        // Signal to home VC that the category has changed and load view accordingly
                        // Show LOAD SCREEN
                        // MARK: - Add async function to load data tonight!!!!!
                        if title != all {}
                        self.setUpCategoryController(uid: uid, title: title)
                        
                        
                    })
                    self.popup.addAction(unselectedAction)
                }
            }
        case .none:
            break
        case .some(_):
            break
        }
    }
    func setUpCategoryController(uid: String, title: String) {
        if self.nomination {
            self.currentCategoryRef.setValue(title)
            self.popup.dismiss(animated: true, completion: nil)
            let refresh = UIRefreshControl()
            let nominees = self.vc as! NomineesViewController
            nominees.currentCategory = title
            nominees.refresh(refresh)
        }  else {
            self.currentCategoryRef.setValue(title)
            self.popup.dismiss(animated: true, completion: nil)
            let refresh = UIRefreshControl()
            let awards = self.vc as! AwardsViewController
            awards.currentCategory = title
            awards.refresh(refresh)
        }
        
    }
}












