//
//  FableOverlayView.swift
//  Fable
//
//  Created by calm on 2019/5/14.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

open class FableOverlayView: UIView {
    
    open var overlayState: SwipeResultDirection?
    
    open func update(progress: CGFloat) {
        alpha = progress
    }
}
