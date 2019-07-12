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
        return .left
    }
    public var dragPercentage: CGFloat {
        return .zero
    }
    
    internal weak var view: UIView?
    internal var panGestureRecognizer = UIPanGestureRecognizer()
    internal var bounds: CGRect { return view?.bounds ?? .zero }
    internal var superview: UIView? { return view?.superview }
    internal var transform: CGAffineTransform {
        get { return view?.transform ?? .identity }
        set{ view?.transform = newValue }
    }
    
    public init() {}
    
    open func began(_ gestureRecognizer: UIPanGestureRecognizer) {}
    open func changed(_ gestureRecognizer: UIPanGestureRecognizer) {}
    open func ended(_ gestureRecognizer: UIPanGestureRecognizer) {}
    open func `default`(_ gestureRecognizer: UIPanGestureRecognizer) {}
    
    open func resetViewPositionAndTransformations(_ completion: @escaping () -> Void) {}
    open func swipeAction(_ direction: SwipeResultDirection, _ completion: @escaping () -> Void) {}
    open func swipe(_ direction: SwipeResultDirection, completion: @escaping () -> Void) {}
    open func removeAnimations () {}
}
