//
//  LottieAnimationWithSound.swift
//  Loads
//
//  Created by SubcoDevs  on 30/04/19.
//  Copyright © 2019 SubcoDevs . All rights reserved.
//

import Foundation
import  UIKit
import Lottie
import AVFoundation

class LottieAnimationWithSound:NSObject{
    static let sharedInstance = LottieAnimationWithSound()
    var player: AVAudioPlayer?
    
    func addAnimation(animationName:String, soundFileName:String, viewController:UIViewController){
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        let starAnimationView = AnimationView()
        starAnimationView.frame = CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight)
        let starAnimation = Animation.named(animationName)
        
        starAnimationView.center = viewController.view.center
        starAnimationView.contentMode = .scaleAspectFit
        starAnimationView.animationSpeed = 0.5
        //starAnimationView.loopMode = .loop
        starAnimationView.animation = starAnimation
        self.playSound(audioName: soundFileName)
        viewController.view.addSubview(starAnimationView)
        starAnimationView.play { (finished) in
            print("Lottie animation is finished")
            starAnimationView.removeFromSuperview()
        }
    }
    
    func playSound(audioName:String) {
        guard let url = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
        
        do {
            //try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            //try AVAudioSession.sharedInstance().setCategory(.def)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
