//
//  Animator.swift
//  Fable
//
//  Created by calm on 2019/7/12.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

public protocol Animatorable {
    var dragDirection: SwipeResultDirection? { get }
    var dragPercentage: CGFloat { get }
}

public class Animator: Animatorable {
    
    public var dragDirection: SwipeResultDirection? {
        return nil
    }
    public var dragPercentage: CGFloat {
        return .zero
    }
    
    internal weak var view: UIView?
    
    open func handle(_ gestureRecognizer: UIPanGestureRecognizer) {}
    
    open func resetViewPosition(animations: (() -> Void)? = nil,
                                _ completion: @escaping () -> Void) {}
    
    open func swipeAction(_ recognizer: UIPanGestureRecognizer, _ direction: SwipeResultDirection, _ completion: @escaping () -> Void) {}
    
    open func swipe(_ direction: SwipeResultDirection, completion: @escaping () -> Void) {}
    open func removeAnimations () {}
}
