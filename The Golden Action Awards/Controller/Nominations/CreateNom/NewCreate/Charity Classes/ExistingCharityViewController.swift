//
//  ExistingCharityViewController.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 28/05/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus
import PhoneNumberKit
import SwiftyContacts
import SearchTextField
import DropDown
import DGActivityIndicatorView


class ExistingCharityViewController: UIViewController,UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var charityNameField: UITextField! //SearchTextField!
    @IBOutlet weak var charityDetails:UILabel!
    @IBOutlet var resultSearchController:UISearchBar!

    
    var selectedItem: SearchTextFieldItem!
    var searches = [SearchTextFieldItem]()
    
    var charitySearches = [Charity]()
    var charityDropDown = DropDown()
    var selectedCharity : Charity?
    var activityView:DGActivityIndicatorView!
    
    var doneClouser: ((Charity) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadIndicatorView()
        self.designSearchField()
        self.swipeDismiss()
        self.tapDismiss()
       // self.startQuery()
        
//        self.charityDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            self.selectedCharity = self.charitySearches[index] as Charity
//
//            let userData = ["charity" : self.selectedCharity]
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectCharity"), object: nil, userInfo: userData as [AnyHashable : Any])
//
//            let fullAddress = self.selectedCharity!.fullAddress
//            let editedAddress = fullAddress.replacingOccurrences(of: ",", with: ",\n")
//            self.charityDetails.text = "\(self.selectedCharity?.charityName ?? ""),\n\(editedAddress)"
//            self.charityDropDown.hide()
//
//        }
      //  NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        self.charityDetails.layer.cornerRadius = 10.0
        //self.charityDetails.layer.borderWidth = 2
        self.charityDetails.layer.masksToBounds = true

    }
    
    @objc func refreshList(notification: NSNotification){
        print("parent method is called")
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
    }
    
    func swipeDismiss() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureRight(_:)))
        gesture.direction = .right
        self.view.addGestureRecognizer(gesture)
    }
    
    func designSearchField() {
        self.resultSearchController.barTintColor = Colors.black.generateColor()
        let textFieldInsideSearchBar = self.resultSearchController.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        textFieldInsideSearchBar?.backgroundColor = Colors.black.generateColor()
        if let font = UIFont(name: "Avenir Next", size: 17.0){
            textFieldInsideSearchBar?.font = font
        }
        textFieldInsideSearchBar?.setBottomBorder()
        
        self.resultSearchController.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        self.resultSearchController.delegate = self
        //self.resultSearchController.showsCancelButton = true
        self.resultSearchController.searchBarStyle = UISearchBarStyle.default
        self.resultSearchController.placeholder = "Search Here"
        self.resultSearchController.sizeToFit()
        
        //self.charityDropDown.direction = .bottom
        self.charityDropDown.anchorView = self.charityDetails
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        print("working")
        
        SearchFirebaseDB.instance.loadCharityQueryFromCollection(query: resultSearchController.text!){(searches, nomsName) in
            guard searches != nil else {
                self.activityView.stopAnimating()
                return
            }
            self.charitySearches = searches!
            self.activityView.stopAnimating()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.isHidden = true
    }
    
    
//    func startQuery() {
//        let textFieldInsideSearchBar = self.resultSearchController.value(forKey: "searchField") as? UITextField
//
//        textFieldInsideSearchBar!.reactive.text.observeNext { (text) in
//            guard text != nil else {
//                self.activityView.stopAnimating()
//                return
//            }
//            if text!.count >= 2 {
//                self.activityView.startAnimating()
//                SearchFirebaseDB.instance.loadCharityQueryFromCollection(query: textFieldInsideSearchBar!.text!){(searches, nomsName) in
//                    guard searches != nil else {
//                        self.activityView.stopAnimating()
//                        return
//                    }
//                    self.charitySearches = searches!
//                    self.charityDropDown.dataSource = nomsName!
//                    self.charityDropDown.show()
//                    self.activityView.stopAnimating()
//                    textFieldInsideSearchBar!.resignFirstResponder()
//                }
//            }
//        }
//    }
    
    func findAndConfirmPerson(uid: String) {
        let ref = DBRef.user(uid: uid).reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let person = Person(dict: dict)
                //self.segueToConfirm(person: person)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//extension CharityViewControler: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == self.charityNameField {
//            self.resignFirstResponder()
//        }
//        print(textField.text!)
//        return true
//    }
//
//
//}


extension ExistingCharityViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charitySearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharitySearchTableViewCell", for: indexPath) as! CharitySearchTableViewCell
       // let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        
        let text = charitySearches[indexPath.row].charityName
        cell.lblCharityName.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedCharity = self.charitySearches[indexPath.row] as Charity
        
        let userData = ["charity" : self.selectedCharity]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectCharity"), object: nil, userInfo: userData as [AnyHashable : Any])
        
        let fullAddress = self.selectedCharity!.fullAddress
        let editedAddress = fullAddress.replacingOccurrences(of: ",", with: ",\n")
        self.charityDetails.text = "\(self.selectedCharity?.charityName ?? ""),\n\(editedAddress)"
        self.tableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

