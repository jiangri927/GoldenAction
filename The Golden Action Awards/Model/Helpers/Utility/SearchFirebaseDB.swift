//
//  SearchFirebaseDB.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 03/01/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import Foundation
import SearchTextField
import Firebase

class SearchFirebaseDB {
    
    private static let instanceInner = SearchFirebaseDB()
    
    static var instance: SearchFirebaseDB {
        return instanceInner
    }
    
    var completionHandler: (([String : Any]?, Error?) -> ())!
    
    func loadCityQuery(query: String?, completion: @escaping ([SearchTextFieldItem]?) -> Void) {
        let ref = DBRef.cityCluster.reference()
        ref.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var noms = [SearchTextFieldItem]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let city = dict["city"] as? String ?? "N/A"
                        let state = dict["state"] as? String ?? "N/A"
                        let cluster = dict["cluster"] as? String ?? "000"
                        let item = SearchTextFieldItem(title: city, subtitle: state, cluster: cluster)
                        if !noms.contains(item) {
                            noms.append(item)
                        }
                    }
                }
                completion(noms)
                print("==============")
                //rdprint(noms)
            } else {
                completion([])
            }
        }
    }
    
    func loadUserQuery(query: String?, completion: @escaping ([Person]?, [String]?) -> Void) {
        let userIndex = DBRef.person.reference()
        userIndex.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var noms = [Person]()
                var nomsName = [String]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let item = Person(dict: dict)
                        //let searchedItem =  SearchUserFieldItem(selectedPerson: item.)
                        if !noms.contains(item) {
                            noms.append(item)
                            nomsName.append(item.fullName)
                        }
                    }
                }
                let nomsList = noms.sorted{$0.fullName < $1.fullName}
                let nameList = nomsName.sorted{$0 < $1}
                
                completion(nomsList, nameList)
            } else {
                completion([],[])
            }
        }
    }
    
 /*   func loadUserQuery(query: String?, completion: @escaping ([Person]?, [String]?) -> Void) {
        let userIndex = DBRef.person.reference()
        userIndex.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var noms = [Person]()
                var nomsName = [String]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let item = Person(dict: dict)
                        if !noms.contains(item) {
                            noms.append(item)
                            nomsName.append(item.fullName)
                        }
                    }
                }
                let nomsList = noms.sorted{$0.fullName < $1.fullName}
                let nameList = nomsName.sorted{$0 < $1}
                
                completion(nomsList, nameList)
            } else {
                completion([],[])
            }
        }
    }
 */
    
    // Searching for charity from firebase real database
    func loadCharityQuery(query: String?, completion: @escaping ([Charity]?, [String]?) -> Void) {
        let userIndex = DBRef.charities.reference()
        userIndex.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var charityObj = [Charity]()
                var charityName = [String]()
                for snap in snapshot {
                    if let dict = snap.value as? [String : Any] {
                        let item = Charity(parsedDict: dict)
                        if charityObj.contains(where: {$0.charityName == item.charityName}){
                            charityObj.append(item)
                            charityName.append(item.charityName)

                        }
                    }
                }
                completion(charityObj, charityName)
            } else {
                completion([],[])
            }
        }
    }
    
    
    // Searching for charity from firestore
    func loadCharityQueryFromCollection(query: String?, completion: @escaping ([Charity]?, [String]?) -> Void) {
        let userIndex = CollectionFireRef.charity.reference()
        
        
        
       
        let predicate  = NSPredicate(format: "charityName CONTAINS[c] %@", query ?? "")
//
//        userIndex.filter(using: predicate).getDocuments { (snapshot, error) in
        
        
        var charityArr = [Dictionary<String, AnyObject>]()
        var tempCharityArr = [Dictionary<String, AnyObject>]()
        
        
        userIndex.getDocuments { (snapshot, error) in
            if error == nil {
                if let data = snapshot?.documents {
                    var charityList = [Charity]()
                    var charityName = [String]()
                    for d in data {
                        
                        charityArr.append(d.data() as [String : AnyObject])
                        
                        let tmpCharity = Charity(parsedDict: d.data())
                        charityList.append(tmpCharity)
                        charityName.append(tmpCharity.charityName)
                    }
                    
                    print(charityArr[0])
                    
                    
                    
                    var charityNameList = charityName.sorted{$0 < $1}
                    var charityObjectList = charityList.sorted{$0.charityName < $1.charityName}
                    
                    tempCharityArr = (charityArr as NSArray).filtered(using: predicate) as! [Dictionary<String, AnyObject>]
                    
                    if(tempCharityArr.count > 0){
                        print(tempCharityArr[0])
                        
                        charityObjectList.removeAll()
                        for dict in tempCharityArr{
                            let tmpCharity = Charity(parsedDict: dict)
                            charityObjectList.append(tmpCharity)
                        }
                        
                        
                        
                    }else{
                        print("NoValues")
                    }
                    
                    
                    
                    
                    //charityList.filter(predicate)
                    
                    
                    completion(charityObjectList, charityNameList)
                }
            }else{
                completion([], [])
            }
        }
    }
    
    
}
