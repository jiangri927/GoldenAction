//
//  ExistingUserList.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 24/04/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import DGActivityIndicatorView
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

//97,244

class ExistingUserList:UITableViewController{
    
    private var dateCellExpanded: Bool = false
    private var selectedIndexPath: Int = -1
    
    var doneClouser: ((Person) -> Void)?
    
    var personSearches = [Person]()
    var searchedPersons = [Person]()
    var activityView:DGActivityIndicatorView!
    var resultSearchController:UISearchBar!
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadIndicatorView()
        self.title = "Existing User"
        self.getAllPersonList()
        
        self.tapDismiss()
        
        let imageColor = self.gradient(size: (self.navigationController?.navigationBar.frame.size)!, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.navigationController?.navigationBar.barTintColor = UIColor.init(patternImage: imageColor!)
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .done, target: self, action: #selector(action))
        
        let leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "backButton"), style: .done, target: self, action: #selector(action))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.darkGray
        
        self.addSearchBar()
    }
    
    func addSearchBar(){
        self.resultSearchController = UISearchBar()
        self.resultSearchController.barTintColor = Colors.black.generateColor()
        let textFieldInsideSearchBar = self.resultSearchController.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = Colors.app_text.generateColor()
        textFieldInsideSearchBar?.backgroundColor = Colors.black.generateColor()
        textFieldInsideSearchBar?.setBottomBorder()
        
        self.resultSearchController.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        self.resultSearchController.delegate = self
        self.resultSearchController.searchBarStyle = UISearchBarStyle.default
        self.resultSearchController.placeholder = "Search Here"
        self.resultSearchController.sizeToFit()
        self.tableView.tableHeaderView = self.resultSearchController
        
    }
    
    @objc func action(sender: UIBarButtonItem) {
        // Function body goes here
        print("working")
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadIndicatorView(){
        activityView = LoadView.instance.generateLoad(size: 100.0, appColor: true)
        self.view.addSubview(activityView)
        self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.65)
        LoadLayout.instance.addCenteredLoadScreen(view: self.view, dg: activityView)
        //activityView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.searchedPersons.count
        }else {
            return self.personSearches.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedUser: Person!
        if self.isSearching {
            selectedUser = self.searchedPersons[indexPath.row] as Person
        }else {
            selectedUser = self.personSearches[indexPath.row] as Person
        }
        print(selectedUser)
        self.doneClouser!(selectedUser)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ExistingUserCell", for: indexPath) as! ExistingUserCell
        headerCell.selectionStyle = .none
        var selectedUser: Person!
        if self.isSearching {
            selectedUser = self.searchedPersons[indexPath.row] as Person
        }else {
            selectedUser = self.personSearches[indexPath.row] as Person
        }
        
        headerCell.selectedUser = selectedUser
        
        headerCell.fullName.text = selectedUser.fullName
        headerCell.email.text    = selectedUser.cityState
        
        headerCell.profileImage.layer.borderWidth = 0
        headerCell.profileImage.layer.masksToBounds = false
        headerCell.profileImage.clipsToBounds = true
        headerCell.profileImage.layer.cornerRadius = headerCell.profileImage.frame.width / 2
        
        headerCell.downloadImageFromFirebase()
        return headerCell
    }
    
    @objc func doneMethod(sender: UIButton){
        let selectedUser = self.personSearches[selectedIndexPath] as Person
        print(selectedUser)
        self.doneClouser!(selectedUser)        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        if indexPath.row == selectedIndexPath {
        //            return 252
        //        }
        return 98
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        let imageColor1 = self.gradient(size: header.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        if section == 0 {
            view.tintColor = UIColor.black
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.init(patternImage: imageColor1!)
            let formattedString = NSMutableAttributedString()
            formattedString.bold("", fontSize: 21.0)
            header.textLabel?.attributedText = formattedString
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
}


extension ExistingUserList{
    func getAllPersonList(){
        self.activityView.startAnimating()
        SearchFirebaseDB.instance.loadUserQuery(query: "abc"){(searches, nomsName) in
            self.activityView.stopAnimating()
            guard searches != nil else {
                return
            }
            self.personSearches.removeAll()
            for search in searches! {
                if !search.fullName.contains(find: "Anonymous") {
                    self.personSearches.append(search)
                }
            }
//            self.personSearches = searches!
            print(self.personSearches.count)
            self.tableView.reloadData()
        }
    }
}


class ExistingUserCell : UITableViewCell{
    
    var selectedUser:Person?
    
    @IBOutlet weak var profileImage:UIImageView!
    
    @IBOutlet weak var fullName:UILabel!
    @IBOutlet weak var email:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.configureTextField()
    }
    
    func configureTextField(){
        self.fullName.backgroundColor = .clear
        
        self.email.backgroundColor = .clear
        self.email.textColor       = .gray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func downloadImageFromFirebase()
    {
        let imageUrl = self.selectedUser?.profilePictureURL
        
//        if AppFileManager.sharedInstance.imageExistInDcoumentDirectory(imageName: imageUrl!){
//            let image = AppFileManager.sharedInstance.getImageFromDocumentDirectory(imageName: imageUrl!)
//            self.profileImage.image = image
//            return
//        }
        let completeUrl = "\(firebaseStorageUrl)\(imageUrl ?? " ")"
        let storageRef = Storage.storage().reference(forURL: completeUrl)
        
        self.profileImage.sd_setImage(with: storageRef)
        
//        storageRef.downloadURL(completion: { (url, error) in
//            guard url != nil else {
//                return
//            }
//            do{
//                let data = try Data(contentsOf: url!)
//                let image = UIImage(data: data as Data)
//                self.profileImage.image = image
//                AppFileManager.sharedInstance.saveImageDocumentDirectory(image: image!, imageName: imageUrl!)
//            }catch{
//                print(error)
//            }
//        })
        
    }
    
}

extension ExistingUserList: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedPersons.removeAll()
        
        if (searchText.count) > 0 {
            self.isSearching = true
        }else{
            self.isSearching = false
        }
        
        self.personSearches.forEach({
            if $0.fullName.range(of: searchText, options: .caseInsensitive) != nil{
                if !self.searchedPersons.contains($0) {
                    self.searchedPersons.append($0)
                }
            }
        })
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
//        self.searchedPersons.removeAll()
//
//        let searchTxt = text
//
//        if (searchTxt.count) > 0 {
//            self.isSearching = true
//        }else{
//            self.isSearching = false
//        }
//
//        self.personSearches.forEach({
//            if $0.fullName.range(of: searchTxt, options: .caseInsensitive) != nil{
//                if !self.searchedPersons.contains($0) {
//                    self.searchedPersons.append($0)
//                }
//            }
//        })
//
//        self.tableView.reloadData()
        return true
    }
}
