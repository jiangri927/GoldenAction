//
//  Charities.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
//import AlgoliaSearch
import SearchTextField

class Charity {
    
    // DICT values: 'EIN', 'NTEECC', 'NAME', 'ADDRESS', 'CITY', 'STATE', 'ZIP5', 'SUBSECCD'
    var charityName: String
    var fullAddress: String
    var classification: String // "NTEECC" this is for the classification
    var ein: String
    var uid:String
    var isAdminVerify:Bool
    
    init(searchItem: SearchTextFieldItem) {
        self.charityName = searchItem.title
        self.classification = searchItem.subtitle!
        self.fullAddress = searchItem.fullAddress!
        self.ein = searchItem.ein!
        self.uid = ""
        self.isAdminVerify = false
    }
    
    init(charityName: String,classification:String, address: String, ein: String, uid:String) {
        self.charityName = charityName
        self.fullAddress = address
        self.ein = ein
        self.classification = classification
        self.uid = uid
        self.isAdminVerify = false
    }
    
    init(charityName: String, address: String, ein: String, uid:String) {
        self.charityName = charityName
        self.fullAddress = address
        self.ein = ein
        self.classification = "N/A"
        self.uid = uid
        self.isAdminVerify = false
    }
    
    init(dict: [String : Any]) {
        self.charityName = dict["NAME"] as? String ?? "N/A"
        self.ein = dict["EIN"] as? String ?? "N/A"
        self.classification = dict["NTEECC"] as? String ?? "N/A"
        let address = dict["ADDRESS"] as? String ?? ""
        let city = dict["CITY"] as? String ?? ""
        let state = dict["STATE"] as? String ?? ""
        let zip = dict["ZIP5"] as? String ?? ""
        if (address == "") || (city == "") || (state == "") || (zip == "") {
            self.fullAddress = "\(address), \(city), \(state) \(zip)"
        } else {
            self.fullAddress = "N/A"
        }
        self.uid = dict["uid"] as? String ?? ""
        self.isAdminVerify = false
    }
    
    init(parsedDict: [String : Any]) {
        self.ein = parsedDict["ein"] as? String ?? "N/A"
        self.classification = parsedDict["classification"] as? String ?? "N/A"
        self.fullAddress = parsedDict["fullAddress"] as? String ?? "N/A"
        self.charityName = parsedDict["charityName"] as? String ?? "N/A"
        self.uid = parsedDict["uid"] as? String ?? "N/A"
        self.isAdminVerify = false
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "charityName": self.charityName,
            "ein": self.ein,
            "classification": self.classification,
            "fullAddress": self.fullAddress,
            "uid":self.uid,
            "isAdminVerified":self.isAdminVerify
        
        ]
    }
}
extension Charity {
    func saveCharity() {
        let ref = CollectionFireRef.charity.reference()
        print(self.toDictionary())
        var newRef = ref.addDocument(data: self.toDictionary(), completion: { (error) in
        })
        newRef.updateData(["uid" : newRef.documentID])
        self.uid = newRef.documentID
    }
    
    class func loadCharityQuery(query: String?, completion: @escaping ([SearchTextFieldItem]?) -> Void) {
       /* let charityIndex = AlgoliaRef.charities.reference()
        let que = Query(query: query)
        var completionHandler: (([String : Any]?, Error?) -> ())!
        if query != "" {
            completionHandler = { (content: [String : Any]?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    completion(nil)
                    return
                }
                let hits = content!["hits"] as? [Any] ?? []
                print(hits)
                if hits.count != 0 {
                    var searches = [SearchTextFieldItem]()
                    for hit in hits {
                        let hit = hit as! [String : Any]
                        let charity = Charity(dict: hit)
                        let item = SearchTextFieldItem(charityTitle: charity.charityName, charityDescriptionSubtitle: CharityCategory.findCategory.determineCategory(classification: charity.classification), fullAddress: charity.fullAddress, ein: charity.ein)
                        if !searches.contains(item) {
                            searches.insert(item, at: searches.count)
                        }
                    }
                    let popular = SearchTextFieldItem(title: "Popular", subtitle: "", cluster: "000")
                    searches.append(popular)
                    completion(searches)
                } else {
                    completion(nil)
                }
                /*if let cursor = content!["cursor"] as? String {
                 cityIndex.browse(from: cursor, completionHandler: self.completionHandler)
                 print("Page 2")
                 } */
            }
            charityIndex.browse(query: que, completionHandler: completionHandler)
        } */
        
        /*cityIndex.browse(query: que) { (response, error) in
         if error != nil {
         print(error?.localizedDescription)
         completion()
         } else {
         print(response)
         completion()
         }
         } */
        
        
    }
}
enum CharityCategory {
    /*
     I. Arts, Culture, and Humanities - A
     II. Education - B
     III. Environment and Animals - C, D
     IV. Health - E, F, G, H
     V. Human Services - I, J, K, L, M, N, O, P
     VI. International, Foreign Affairs - Q
     VII. Public, Societal Benefit - R, S, T, U, V, W
     VIII. Religion Related - X
     IX. Mutual/Membership Benefit - Y
     X. Unknown, Unclassified - Z
     */
    case arts
    case education
    case environment
    case health
    case human_services
    case international
    case societal
    case mutualMember
    case unknown
    case religion
    case findCategory
    
    func sendDescription() -> String {
        switch self {
        case .arts:
            return "Arts, Culture, and Humanities"
        case .education:
            return "Education"
        case .environment:
            return "Environment and Animals"
        case .health:
            return "Health"
        case .human_services:
            return "Human Services"
        case .international:
            return "International, Foreign Affairs"
        case .societal:
            return "Public, Societal Benefit"
        case .mutualMember:
            return "Mutual/Membership Benefit"
        case .unknown:
            return "Unknown, Unclassified"
        case .religion:
            return "Religion Related"
        case .findCategory:
            return "N/A"
            
        }
    }
    
    func determineCategory(classification: String) -> String {
        if classification.contains("A") {
            return CharityCategory.arts.sendDescription()
        } else if classification.contains("B") {
            return CharityCategory.education.sendDescription()
        } else if classification.contains("C") || classification.contains("D") {
            return CharityCategory.environment.sendDescription()
        } else if classification.contains("E") || classification.contains("F") || classification.contains("G") || classification.contains("H") {
            return CharityCategory.health.sendDescription()
        } else if classification.contains("I") || classification.contains("J") || classification.contains("K") || classification.contains("L") || classification.contains("M") || classification.contains("N") || classification.contains("O") || classification.contains("P") {
            return CharityCategory.human_services.sendDescription()
        } else if classification.contains("Q") {
            return CharityCategory.international.sendDescription()
        } else if classification.contains("R") || classification.contains("S") || classification.contains("T") || classification.contains("U") || classification.contains("V") || classification.contains("W") {
            return CharityCategory.societal.sendDescription()
        } else if classification.contains("X") {
            return CharityCategory.mutualMember.sendDescription()
        } else if classification.contains("Y") {
            return CharityCategory.unknown.sendDescription()
        } else {
            return CharityCategory.religion.sendDescription()
        }
    }
    
}
