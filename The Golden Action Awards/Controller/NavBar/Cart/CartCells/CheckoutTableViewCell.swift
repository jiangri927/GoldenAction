//
//  CheckoutTableViewCell.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 3/15/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import UIKit
import StoreKit

class CheckoutTableViewCell: UITableViewCell {

    @IBOutlet weak var votesIcon: UIImageView!
    @IBOutlet weak var bundleLabel: UILabel!
    @IBOutlet weak var numberVotesLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var isVoteSegue:Bool!
    
    func configurePlans(plan: SKProduct, votes: Bool) {
        let name = plan.localizedTitle
        self.bundleLabel.attributedText = Strings.cell_cart_bundle.generateString(text: name)
        let price = plan.priceLocale.identifier
        self.priceLabel.attributedText = Strings.cell_cart_price.generateString(text: price)
        print(price)
    }
    
    func configureCell(voteBundle: [String : Any]) {
        let bundle = voteBundle["bundle_num"] as? String ?? ""
        let votesNum = voteBundle["num_votes"] as? Int ?? 0
        let price = voteBundle["price"] as? Double ?? 0
        
        
//        self.bundleLabel.attributedText = Strings.cell_cart_bundle.generateString(text: bundle)
//        self.numberVotesLabel.attributedText = Strings.cell_cart_numvotes.generateString(text: "Contains \(votesNum) Votes")
        self.priceLabel.text = "$\(price)"
        self.bundleLabel.text = "\(bundle)"
        var vote = "Votes"
        if votesNum == 1 {vote = "Vote"}
        self.numberVotesLabel.text = "Contains \(votesNum) \(vote)"
    }
    
    
    func configureCell1(voteBundle: [String : Any]) {
        let bundle = voteBundle["bundle_num"] as? String ?? ""
        let votesNum = voteBundle["num_votes"] as? Int ?? 0
        let price = voteBundle["price"] as? Double ?? 0
        
        
        //        self.bundleLabel.attributedText = Strings.cell_cart_bundle.generateString(text: bundle)
        //        self.numberVotesLabel.attributedText = Strings.cell_cart_numvotes.generateString(text: "Contains \(votesNum) Votes")
        self.priceLabel.text = "$\(price)"
        self.bundleLabel.text = "\(bundle)"
        var vote = "Nominations"
        if votesNum == 1 {vote = "Nomination"}
        self.numberVotesLabel.text = "Buy \(votesNum) \(vote)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.priceLabel.textColor = Constants.gradientEndColor
//        self.priceLabel.setGradiantColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
