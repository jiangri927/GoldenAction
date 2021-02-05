//
//  SubmitVoteViewController.swift
//  The Golden Action Awards
//
//  Created by SubcoDevs  on 05/07/19.
//  Copyright © 2019 Michael Kunchal. All rights reserved.
//

import UIKit

class SubmitVoteViewController: UIViewController {
    
    @IBOutlet var txt_vote: UITextField!
    @IBOutlet var btnVote: UIButton!
    
    var voteCount : Int = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        designPendingBtns()
    }
    
    
    func designPendingBtns()
    {
        self.btnVote.layer.cornerRadius = 3.0
        self.btnVote.layer.cornerRadius = 3.0
        self.btnVote.layer.masksToBounds = true
        let imageColor = self.gradient(size: self.btnVote.frame.size, color: [Constants.gradientStartColor, Constants.gradientEndColor])
        self.btnVote.backgroundColor     = UIColor.init(patternImage: imageColor!)
    }

    
    @IBAction func btnActionOnVoteCount(_ sender: UIButton) {
        
        if(sender.tag == 0)
        {
            voteCount = voteCount + 1
            txt_vote.text =  "\(voteCount)"
        }
        else
        {
            if(voteCount == 0){
                return
            }
            voteCount = voteCount - 1
            txt_vote.text =  "\(voteCount)"
        }
    }
    
    @IBAction func btnActionOnVoteSubmit(_ sender: UIButton) {
    }
}
