//
//  SettingsTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/14/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configureCell(item: [String : Any]) {
        let title = item["title"] as? String ?? ""
        let description = item["description"] as? String ?? ""
       // self.titleLabel.attributedText = Strings.cell_settings_title.generateString(text: title)
       // self.descriptionLabel.attributedText = Strings.cell_settings_description.generateString(text: description)
        
        
        
        
        
        self.titleLabel.text =  title
        self.descriptionLabel.text =  description

        
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
