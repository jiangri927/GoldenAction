//
//  FaqTableViewCell.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 25/06/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit

class FaqTableViewCell: UITableViewCell {
    
    @IBOutlet var lblQuestion: UILabel!
    @IBOutlet var lblAnswer: UILabel!
    
    func configureCell(item: [String : Any]) {
        let title = item["title"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        
        self.lblQuestion.text =  title
        self.lblAnswer.text =  description
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
