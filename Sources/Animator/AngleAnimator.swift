//
//  AngleAnimator.swift
//  Fable
//
//  Created by calm on 2019/7/12.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

public class AngleAnimator: Animator {
    
    public var targetAngle: CGFloat = 0.69
    public var radius: CGFloat?
    
    public override var dragPercentage: CGFloat {
        guard dragDirection != nil else { return 0 }
        let a = abs(fractionComplete - 0.5) * targetAngle * 2
        return min(a / completionAngle, 1)
    }
    
    public override var dragDirection: SwipeResultDirection? {
        return (fractionComplete - 0.5 > 0) ? .right : .left
    }
    
    private var animator = UIViewPropertyAnimator()
    private var animationProgress: CGFloat = 0
    
    // 动画进度
    /*
     手动管理动画进度代替UIViewPropertyAnimator.fractionComplete属性
     在iOS10设备下会出现一下问题:
     1) UIViewPropertyAnimator.fractionComplete 动画效果不稳定
     2) 调用animator.continueAnimation(withTimingParameters:, durationFactor:)方法结束动画会不生效.
     */
    private var fractionComplete: CGFloat = 0 {
        didSet {
            var fraction = max(fractionComplete, 0)
            fraction = min(fractionComplete, 1)
            let angle = targetAngle * 2 * (fraction - 0.5)
            transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    public override init() {
        super.init()
    }
    
    public override func handle(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            setupAnchorPoint()
            fractionComplete = 0.5
            animationProgress = fractionComplete
        case .changed:
            /*
             atan 反正切函数
             旋转角度 = 反正切/(位移的距离/圆点到手势触摸的点)
             */
            let dragDistance = gestureRecognizer.translation(in: superview)
            let location = gestureRecognizer.location(in: superview)
            
            let a = dragDistance.x / (dot.y - location.y)
            let rotationAngle =  atan(a)
            let fraction = rotationAngle / (targetAngle * 2)
            fractionComplete = fraction + animationProgress
        default:
            break
        }
    }
    
    public override func resetViewPosition(animations: (() -> Void)? = nil,
                                           _ completion: @escaping () -> Void) {
        removeAnimations()
        animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.7)
        animator.addAnimations {
            self.fractionComplete = 0.5
            animations?()
        }
        animator.addCompletion { position in
           completion()
        }
        animator.startAnimation()
    }
    
    public override func swipeAction(_ recognizer: UIPanGestureRecognizer, _ direction: SwipeResultDirection, _ completion: @escaping () -> Void) {
        
        let location = recognizer.location(in: superview)
        let velocity = recognizer.velocity(in: superview)
        
        let radius = dot.y - location.y
        let fraction = 0.5 - abs(0.5 - fractionComplete)
        let angle = fraction * targetAngle * 2
        let distance = radius * tan(angle)
        let relativeVelocity = abs(velocity.x) / distance
        let timingParameters = UISpringTimingParameters(damping: 1, response: 1.2, initialVelocity: CGVector(dx: relativeVelocity, dy: 0))
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            switch direction {
            case .left:
                self.fractionComplete = 0
            case .right:
                self.fractionComplete = 1
            }
        }
        
        animator.addCompletion { position in
            completion()
        }
        
        animator.startAnimation()
    }
    
    public override func swipe(_ direction: SwipeResultDirection, completion: @escaping () -> Void) {
        setupAnchorPoint()
        fractionComplete = 0.5
        let timingParameters = UISpringTimingParameters(damping: 0.9, response: 1.2)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            switch direction {
            case .left:
                self.fractionComplete = 0
            case .right:
                self.fractionComplete = 1
            }
        }
        
        animator.addCompletion { _ in
            completion()
        }
        
        animator.startAnimation()
    }
    
    
    public override func removeAnimations() {
        animator.stopAnimation(true)
    }
    
    private func setupAnchorPoint() {
        view?.set(anchorPoint: CGPoint(x: 0.5, y: dot.y / bounds.height))
    }
    
    deinit { print("deinit:\t AngleAnimator") }
}


extension AngleAnimator {
    
    private var bounds: CGRect { return view?.bounds ?? .zero }
    private var superview: UIView? { return view?.superview }
    private var transform: CGAffineTransform {
        get { return view?.transform ?? .identity }
        set{ view?.transform = newValue }
    }
    
    /// 滑动圆心
    private var dot: CGPoint {
        let r = (radius ?? bounds.height * 2) + bounds.height * 0.5
        return CGPoint(x: bounds.width * 0.5, y: abs(r))
    }
    
    private var completionAngle: CGFloat {
        let a = bounds.width * 0.5 / (dot.y - bounds.height)
        return atan(a)
    }
}
