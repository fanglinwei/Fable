//
//  AnimationSemaphore.swift
//  Fable
//
//  Created by calm on 2019/5/14.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

class AnimationSemaphore {
    
    private var animating = 0
    
    public var isAnimating: Bool {
        get {
            return animating > 0
        }
    }
    
    public func increment() {
        animating += 1
    }
    
    public func decrement() {
        animating  -= 1
        if animating < 0 {
            animating = 0
        }
    }
}
