//
//  NomineesTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/11/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Nuke
import Toucan
import Firebase

enum NStatus {
    case in_review
    case voting_open
    case voting_closed
    public var id:String{
        switch self {
        case .in_review:
            return "In Review"
        case .voting_open:
            return "Voting Open"
        case .voting_closed:
            return "Voting Closed"
        }
    }
    
    public var statusNumber:Int{
        switch self {
        case .in_review:
            return 1
        case .voting_open:
            return 2
        case .voting_closed:
            return 3
        }
    }
    
//    func getPhaseStatus(phase:Int)->String{
//        switch phase {
//        case 1:
//            return "In Review"
//        case 2,3:
//            return "V"
//
//        }
//    }
}

class NomineesTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic     : UIImageView!
    @IBOutlet weak var nomineeName    : UILabel!
    @IBOutlet weak var nomineeLocation: UILabel!
    @IBOutlet weak var nomintadBy     : UILabel!
    @IBOutlet weak var nomineeStatus  : UILabel!
    @IBOutlet weak var votesLabel     : UILabel!
    @IBOutlet weak var numVotesButton : UIButton!
    @IBOutlet weak var ranking: UIImageView!
    
    var nominations: Nominations!
    var keychain = KeychainWrapper.standard
    
    func configureNom(nom: Nominations) {
        
        self.votesLabel.alpha = 1.0
        self.numVotesButton.alpha = 1.0

        self.nomineeName.text = nom.nominee.fullName

        if !nominations.userApproved {
            
            self.votesLabel.alpha = 0.0
            self.numVotesButton.alpha = 0.0
            if nom.nominatedBy.email != Auth.auth().currentUser?.email {
                self.nomineeName.text = "Click to Approve!"
            }
        }
        
        if nom.anonoymous {
            self.nomintadBy.text = "Anonymous"
        } else {
            self.nomintadBy.text = nom.nominatedBy.fullName
        }
        self.nomineeLocation.text = nom.nominee.cityState
        
        let nomStatus = nom.phase as? Int ?? 0
        let startDate = Date(timeIntervalSince1970: nom.startDate)
        let endDate   = Date(timeIntervalSince1970: nom.endDate)
        let currentDate = Date()
        
        if nom.endDate > 0 {
            if endDate <= currentDate {
                updateNomValue(uid: nom.uid, completion: { (statusValue) in
                    print("nominee goes to phase 4")
                })
              //  nomineeStatus.text = NStatus.voting_closed.id
                print("\(NStatus.voting_closed.id)")
            }
        }
        self.numVotesButton.setTitle("0", for: [])
        self.ranking.image = nil
        nom.getAndSetVotesForParticulerNomination(action: VotesAction.get.id, uid: nom.uid, vote: 1){(voteValue) in
            DispatchQueue.main.async {
                self.numVotesButton.setTitle("\(voteValue)", for: [])
                self.ranking.image = UIImage(named:"nominations-active")
                if voteValue >= 10 && voteValue < 31 {
                    self.ranking.image = UIImage(named:"copper_\(nom.category.lowercased())")
                }
                else if voteValue > 30 && voteValue < 51 {
                    self.ranking.image = UIImage(named:"silver_\(nom.category.lowercased())")
                    
                }
                else if voteValue > 50 {
                    self.ranking.image = UIImage(named:"gold_\(nom.category.lowercased())")
                }
            }
        }

        self.setUpPic()
        self.designButton()
        self.downloadImageFromFirebase()
        self.designVoteButton()
    }
    
    
    // MARK: - Load Current Person
//    func loadCurrentUser(completion: @escaping (Person?, String?) -> Void) {
//        if Auth.auth().currentUser != nil {
//            let uid = Auth.auth().currentUser!.uid
//            self.loadPerson(uid: uid, completion: { (person, error) in
//                completion(person, error)
//            })
//
//        } else {
//            //sud
//            //self.createAnonymousUser()
//        }
//    }
    
    func designVoteButton(){
        self.numVotesButton.layer.borderColor = UIColor.white.cgColor
        self.numVotesButton.layer.borderWidth = 0.5
        self.numVotesButton.layer.cornerRadius = 4.0
        self.numVotesButton.layer.masksToBounds = true
        self.numVotesButton.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
    }
    
    func downloadImageFromFirebase(){
        self.profilePic.image = UIImage(named:"gold_heart")

        if self.nominations.urls.count > 0{
            let imageUrl = self.nominations.urls[0]
            
            if AppFileManager.sharedInstance.imageExistInDcoumentDirectory(imageName: imageUrl){
                let image = AppFileManager.sharedInstance.getImageFromDocumentDirectory(imageName: imageUrl)
                self.profilePic.image = image
                return
            }
            
            let completeUrl = "\(firebaseStorageUrl)\(imageUrl)"
           // let completeUrl = "gs://golden-test-app.appspot.com/\(imageUrl)"
            let storageRef = Storage.storage().reference(forURL: completeUrl)
            storageRef.downloadURL(completion: { (url, error) in
                guard url != nil else {
                    return
                }
                do{
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    self.profilePic.image = image
                    AppFileManager.sharedInstance.saveImageDocumentDirectory(image: image!, imageName: imageUrl)
                }catch{
                    print(error)
                }
            })
        }
        
    }
    
    // MARK: - Configure Nomination Table View Cell
    func configureCell(dict: [String : Any]) {
        self.contentView.isUserInteractionEnabled = true
        self.nomineeName.text = dict["name"] as? String ?? ""
        self.nomineeLocation.text = dict["location"] as? String ?? ""
        let nomBy = dict["nominatedBy"] as? String ?? ""
        self.nomintadBy.text = "Nominated By \(nomBy)"
        let numVotes = dict["numberOfVotes"] as? Int ?? 0
        
        let nomStatus = dict["phase"] as? Int ?? 0
        if nomStatus == NStatus.in_review.statusNumber {
            nomineeStatus.text = NStatus.in_review.id
        }else if nomStatus == NStatus.voting_open.statusNumber {
            nomineeStatus.text = NStatus.voting_open.id
        }else if nomStatus == NStatus.voting_closed.statusNumber {
            nomineeStatus.text = NStatus.voting_closed.id
        }else {
            nomineeStatus.text = ""
        }
        self.numVotesButton.setTitle("\(numVotes)", for: [])
        self.setUpPic()
        self.designButton()
    }
    func designButton() {
        self.numVotesButton.titleEdgeInsets.top = 2.0
        self.numVotesButton.titleEdgeInsets.bottom = 2.0
        self.numVotesButton.titleEdgeInsets.left = 4.0
        self.numVotesButton.titleEdgeInsets.right = 4.0
    }
    func setUpPic() {
        self.profilePic.isUserInteractionEnabled = true
        self.profilePic.contentMode = UIViewContentMode.scaleAspectFill
        
        self.profilePic.layer.masksToBounds = true
        self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
        
        // ---> This puts a border around the image
        /*
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderWidth = 4.0
        self.profilePic.layer.borderColor = UIColor.white.cgColor
         */
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateNomValue(uid:String, completion: @escaping (Bool?) -> Void){
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
                if error == nil {
                    if let data = snapshot?.documents {
                        for d in data {
                            let docRef = FireRef.spec_nomination(uid: d.documentID).reference()
                            docRef.updateData(["phase":4])
                            docRef.updateData(["charityDone":false])
                        }
                    }
                }
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
        
    }

}



extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
