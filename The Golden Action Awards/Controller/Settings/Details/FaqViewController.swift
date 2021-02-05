//
//  FaqViewController.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 25/06/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit

class FaqViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var settingsSelection1: [[String : Any]] {
        return [
            //["title": "Rate the app", "description": "If you like The Golden Action Awards, please allow support by rating us"],
            ["title": "1. Who can I nominate?", "description": "You can nominate anyone, (man, women, child,  even animal)  as long as you feel they are deserving recognition and appreciation. "],
            ["title": "2. What are the award levels?", "description": "1-9 votes is a Nomination level. Nominee will receive a printable certificate. 10-30 votes is a Bronze level. Nominee will receive a printable certificate and a Bronze medal.     31-50 votes is a Silver level. Nominee will receive a printable certificate and a Silver medal. 51 and above votes is a Gold level. Nominee will receive a printable certificate and a Gold medal."],
            ["title": "3. What actions are acceptable for nomination?", "description": "Any action you feel deserving recognition and appreciation is appropriate for nomination. Remember to think of your nomination in one of the four categories. Head, as in a graduation or new business venture. Hand, as in volunteering or lending a helping hand. Health, as in facing cancer or heart disease challenges. And Heart, as in a kind or selfless gesture. "],
//            ["title": "4. Will I or my nominee, owe taxes on the funds donations to charity?", "description": "No all taxes are paid by Golden Action Awards. "],
//            ["title": "5. Can I or my nominee, get a tax deduction for the funds given to my charity?", "description": "Probably not, but check with your accountant to be sure. "],
//            ["title": "6. Why isn’t more of the proceeds donated to charities through Golden Action Awards?", "description": "Our first priority is to recognize and appreciate the individuals that have a positive influence on those around them.  For us not-for-profits are second only to those that make them possible. Of course we want to give back by supporting charities, and we do what we can after awards and app fees are paid. So if your primary goal is simply to donate to charity, please make a donation directly to your favorite organization. "],
            ["title": "4. What happens if my nomination is declined?", "description": "When a nomination is submitted it goes first to the nominee, where it is accepted or declined. If declined you will be notified. We suggest you discuss the decision with your nominee. If accepted the nomination then goes to Admin. Admin reserves the right to decline any nomination for any inappropriate content. If the nomination is declined by admin you and the nominee will be notified. When approved the nomination goes live on Golden Action Awards. Nomination fees will not be refunded if declined by either nominee or Admin."],
              ["title": "5. What do you mean by Hand, heart, health, head?", "description": "These are the 4 categories in which you can nominate someone.\nHeart - for those who have a kind heart.\nHead - for those who have done something smart.\nHealth - for those who promote good health \nHand - for those who lend a helping hand"],
            ["title": "6. What do the award medals look like?", "description": "8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. What do the award medals look like?8. "]
          
        ]//individuals that have a positive influence
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBarTint()
        self.title = "FAQ's"
        
        let leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "backButton"), style: .done, target: self, action: #selector(action))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.darkGray
        
         self.tableView.register(UINib(nibName: "FaqTableViewCell", bundle: nil), forCellReuseIdentifier: "FaqTableViewCell")

    }
    
    @objc func action(sender: UIBarButtonItem) {
        // Function body goes here
        print("working")
        self.dismiss(animated: true, completion: nil)
    }

}


extension FaqViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSelection1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaqTableViewCell", for: indexPath) as! FaqTableViewCell
        let item = self.settingsSelection1[indexPath.row]
        cell.configureCell(item: item)
        cell.subviews.forEach { (view) in
            if view.tag == 1000 {
                view.removeFromSuperview()
            }
        }
        cell.lblAnswer.alpha = 1
        if indexPath.row == 5 {
            let imageView1 = UIImageView(image: UIImage(named: "gold_heart"))
            imageView1.frame = CGRect(x: 8, y: 44, width: 70, height: 70)
            imageView1.tag = 1000
            let imageView2 = UIImageView(image: UIImage(named: "copper_hand"))
            imageView2.frame = CGRect(x: 93, y: 44, width: 70, height: 70)
            imageView2.tag = 1000
            let imageView3 = UIImageView(image: UIImage(named: "silver_health"))
            imageView3.frame = CGRect(x: 178, y: 44, width: 70, height: 70)
            imageView3.tag = 1000
            cell.addSubview(imageView1)
            cell.addSubview(imageView2)
            cell.addSubview(imageView3)
            cell.lblAnswer.alpha = 0
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print(tableView.cellForRow(at: indexPath)?.frame.size.height ?? 0)
//        return tableView.cellForRow(at: indexPath)?.frame.size.height ?? 0
//    }
    
    
}
