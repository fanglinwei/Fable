//
//  UIViewController+Extension.swift
//  Example
//
//  Created by calm on 2019/7/11.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func add(child controller: UIViewController, to container: UIView? = .none) {
        addChild(controller)
        (container ?? view)?.addSubview(controller.view)
        controller.view.frame = (container ?? view).bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }
}
