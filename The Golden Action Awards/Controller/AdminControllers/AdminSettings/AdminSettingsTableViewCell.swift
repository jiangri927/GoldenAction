//
//  AdminSettingsTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/12/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class AdminSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsTitle: UILabel!
    @IBOutlet weak var settingsDescription: UILabel!
    
    func configureCell(item: [String : Any]) {
        let tit = item["title"] as? String ?? ""
        let de = item["description"] as? String ?? ""
//        self.settingsTitle.attributedText = Strings.cell_settings_title.generateString(text: tit)
//        self.settingsDescription.attributedText = Strings.cell_settings_description.generateString(text: de)
        
        self.settingsTitle.text = tit
        self.settingsDescription.text = de
        
        // Run through strings enum
        
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
