//
//  RealLoadingController.swift
//  Social
//
//  Created by calm on 2019/5/23.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import Lottie

class RealLoadingController: UIViewController {

    
    @IBOutlet weak var avatarImageView: AvatarView!
    
    @IBOutlet weak var animationiew: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        play()
    }
    
    private func setup()  {
        avatarImageView.set(
            "http://cdn.duitang.com/uploads/item/201601/08/20160108194244_JxGRy.thumb.700_0.jpeg",
            style: .color(#colorLiteral(red: 0.8980392157, green: 0.9215686275, blue: 0.9960784314, alpha: 1)),
            space: .constant(6.auto())
        )
        
        animationiew.animationSpeed = 1.5
        animationiew.loopMode = .loop
        animationiew.backgroundBehavior = .pauseAndRestore
        
    }
    
    func play() {
        animationiew.play()
    }
    
    static func instance() -> Self {
        return StoryBoard.real.instance()
    }
}
