//
//  SignupLegalViewController.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

class SignupLegalViewController: UIViewController {

    // MARK: - Outlet Declaration
    @IBOutlet weak var legalTitle: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var legalTextView: UITextView!
    
    var admin: Bool!
    var settings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        self.legalTextView.textColor = UIColor.gray
        self.legalTextView.backgroundColor = UIColor.black
        
        
        
        if self.settings {
            self.acceptButton.setAttributedTitle(Strings.buttons.generateString(text: "Go Back"), for: [])
            self.acceptButton.reactive.tap.observeNext {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.acceptButton.addTarget(self, action: #selector(acceptTapped(_:)), for: .touchUpInside)
            self.acceptButton.setAttributedTitle(Strings.buttons.generateString(text: "I Accept"), for: [])
        }
        
        let keyboardDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(recognizer:)))
        self.view.addGestureRecognizer(keyboardDismiss)
        
        let imageColor1 = self.gradient(size: self.acceptButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.legalTitle.textColor = UIColor.init(patternImage: imageColor1!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        let imageColor = self.gradient(size: self.acceptButton.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        
        self.acceptButton.backgroundColor = UIColor.init(patternImage: imageColor!)
        self.acceptButton.setTitleColor(UIColor.white, for: [])
        self.acceptButton.layer.cornerRadius = 10.0
        self.acceptButton.layer.masksToBounds = true
    }
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func acceptTapped(_ sender: UIButton) {
        let workItem = DispatchWorkItem {
            if self.admin != nil {
                //updating uuid value for logged user with firebase message notification
                NotificationHelper.instance.saveForLoggedUser()
                self.performSegue(withIdentifier: SegueId.sponsorlegal_congrats.id, sender: self)
                
            } else {
                //updating uuid value for logged user with firebase message notification
                NotificationHelper.instance.saveForLoggedUser()
                self.dismiss(animated: true, completion: nil)
                /*let nomVC = self.storyboard?.instantiateViewController(withIdentifier: VCID.nominee_screen.id) as! NomineesViewController
                self.navigationController?.pushViewController(nomVC, animated: true) */
            }
        }
        let uid = Auth.auth().currentUser!.uid
        let ref = DBRef.legal(uid: uid).reference()
        ref.setValue(true)
        
        //updating uuid value for logged user with firebase message notification
        NotificationHelper.instance.saveForLoggedUser()
        
       // updateNominationDetails()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: workItem)
    }
    
    func updateNominationDetails(){
        
        let workItem = DispatchWorkItem {
            self.updateNomValue(completion:{ (status) in
                print("uid updated properly")
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: workItem)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignupLegalViewController {
    
    func updateNomValue(completion: @escaping (Bool?) -> Void){
        var uid = Auth.auth().currentUser!.uid
        let email = Auth.auth().currentUser?.email
        
        let valueWorkItem = DispatchWorkItem {
            let ref = CollectionFireRef.nominations.reference()
            ref.getDocuments { (snapshot, error) in
                guard error != nil else{
                    return
                }
                for snap in (snapshot?.documents)! {
                    let data = snap.data()
                    let nomineePerson = Nominations(dict: data)
                    if nomineePerson.nominee.email == email {
                       // nomineePerson.nominee.uid = uid
                       // snap.up
                    }
                }
            }
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: valueWorkItem)
        
    }

}

extension SignupLegalViewController{
    
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
        context.drawLinearGradient(gredient, start: CGPoint(x:0.0,y:size.height), end: CGPoint(x:size.width,y:size.height), options: [])
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    } */
    
}

