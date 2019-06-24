//
//  PackCardView.swift
//  Fable
//
//  Created by calm on 2019/5/14.
//  Copyright © 2019 calm. All rights reserved.
//

private let screenSize = UIScreen.main.bounds.size

protocol PackCardViewDelegate: class {
    
    func card(_ card: PackCardView, wasDraggedWithFinishPercentage percentage: CGFloat, inDirection direction: SwipeResultDirection)
    func card(_ card: PackCardView, wasSwipedIn direction: SwipeResultDirection, context: Any?)
    func card(_ card: PackCardView, shouldSwipeIn direction: SwipeResultDirection) -> Bool
    func card(cardWillReset card: PackCardView)
    func card(cardDidReset card: PackCardView)
    func card(cardWasTapped card: PackCardView)
    func card(cardSwipeThresholdRatioMargin card: PackCardView) -> CGFloat
    func card(cardAllowedDirections card: PackCardView) -> [SwipeResultDirection]
    func card(cardShouldDrag card: PackCardView) -> Bool
    func card(cardSwipeSpeed card: PackCardView) -> Speed
    func card(cardPanBegan card: PackCardView)
    func card(cardPanFinished card: PackCardView)
}

public final class PackCardView: UIView {
    
    /// 滑动半径
    public var radius: CGFloat?
    public var targetAngle: CGFloat = 0.69
    
    public var swipeActionAnimationDuration: TimeInterval {
        let speed = delegate?.card(cardSwipeSpeed: self) ?? .default
        return speed.value
    }
    
    weak var delegate: PackCardViewDelegate? {
        didSet {
            configureSwipePercentageMargin()
        }
    }
    
    internal var dragBegin = false
    private var overlayView: FableOverlayView?
    public private(set) var contentCard: FableCardable?
    
    private var swipePercentageMargin: CGFloat = 1
    
    /// 滑动圆心
    private var dot: CGPoint {
        let r = (radius ?? bounds.height * 2) + bounds.height * 0.5
        return CGPoint(x: bounds.width * 0.5, y: abs(r))
    }
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panRecognized))
        pan.delegate = self
        return pan
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognized))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        return tap
    }()
    
    private var animator = UIViewPropertyAnimator()
    
    /// 动画进度
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
    
    private var animationProgress: CGFloat = 0
    
    override public var frame: CGRect {
        didSet {
            configureSwipePercentageMargin()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.overlayView?.frame = bounds
        self.contentCard?._content.frame = bounds
    }
    
    private func setup() {
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    deinit {
        print("deinit:\t\(classForCoder)")
        removeGestureRecognizer(panGestureRecognizer)
        removeGestureRecognizer(tapGestureRecognizer)
        contentCard?.removeFromSuper()
    }
}

// MARK: - configure
extension PackCardView {
    
    func configure(_ cell: FableCardable, overlayView: FableOverlayView?) {
        self.overlayView?.removeFromSuperview()
        self.contentCard?.removeFromSuper()
        self.contentCard = cell
        
        if let overlay = overlayView {
            self.overlayView = overlay
            overlay.alpha = 0;
            self.addSubview(overlay)
            self.insertSubview(cell._content, belowSubview: overlay)
        } else {
            self.addSubview(cell._content)
        }
        setNeedsLayout()
    }
    
    private func configureSwipePercentageMargin() {
        guard
            let ratio = delegate?.card(cardSwipeThresholdRatioMargin: self),
            ratio != 0 else {
                return
        }
        swipePercentageMargin = ratio
    }
}

// MARK: - GestureRecognizers
extension PackCardView {
    
    @objc private func tapRecognized(_ recogznier: UITapGestureRecognizer) {
        delegate?.card(cardWasTapped: self)
    }
    
    @objc func panRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            removeAnimations()
            dragBegin = true
            delegate?.card(cardPanBegan: self)
            // 图像优化
            // https://www.jianshu.com/p/2a01e5e2141f
            layer.rasterizationScale = UIScreen.main.scale
            layer.shouldRasterize = true
            
            set(anchorPoint: CGPoint(x: 0.5, y: dot.y / bounds.height))
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
            let percentage = dragPercentage
            updateOverlayWithFinishPercent(percentage, direction: dragDirection)
            if let dragDirection = dragDirection {
                delegate?.card(self, wasDraggedWithFinishPercentage: min(abs(100 * percentage), 100), inDirection: dragDirection)
            }
        case .ended, .cancelled:
            isUserInteractionEnabled = false
            delegate?.card(cardPanFinished: self)
            swipeMadeAction()
            layer.shouldRasterize = false
            
        default:
            layer.shouldRasterize = false
            resetViewPositionAndTransformations()
        }
    }
}

//MARK: Public
extension PackCardView {
    
    internal func removeAnimations() {
        animator.stopAnimation(true)
    }
    
    internal func swipe(_ direction: SwipeResultDirection,
                        _ context: Any?,
                        completionHandler: @escaping () -> Void) {
        guard !dragBegin else { return }
        delegate?.card(self, wasSwipedIn: direction, context: context)
        
        set(anchorPoint: CGPoint(x: 0.5, y: dot.y / bounds.height))
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
        
        animator.addCompletion { [weak self]_ in
            guard let self = self else { return }
            completionHandler()
            self.removeFromSuperview()
        }
        
        animator.startAnimation()
    }
}

extension PackCardView {
    
    private func swipeMadeAction() {
        let shouldSwipe = { [weak self] (direction: SwipeResultDirection) -> Bool in
            guard let self = self else { return true }
            return self.delegate?.card(self, shouldSwipeIn: direction) ?? true
        }
        if
            let dragDirection = dragDirection ,
            shouldSwipe(dragDirection) && dragPercentage >=
                swipePercentageMargin && directions.contains(dragDirection) {
            
            swipeAction(dragDirection)
        } else {
            resetViewPositionAndTransformations()
        }
    }
    
    private func swipeAction(_ direction: SwipeResultDirection) {
        delegate?.card(self, wasSwipedIn: direction, context: nil)
        
        let location = panGestureRecognizer.location(in: superview)
        let velocity = panGestureRecognizer.velocity(in: superview)
        overlayView?.overlayState = direction
        overlayView?.alpha = 1.0
        
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
            self.dragBegin = false
            self.removeFromSuperview()
        }
        
        animator.startAnimation()
    }
    
    private func resetViewPositionAndTransformations() {
        delegate?.card(cardWillReset: self)
        removeAnimations()
        animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.7)
        animator.addAnimations {
            self.fractionComplete = 0.5
            self.overlayView?.alpha = 0
        }
        animator.addCompletion { position in
            self.delegate?.card(cardDidReset: self)
            self.dragBegin = false
            self.isUserInteractionEnabled = true
        }
        animator.startAnimation()
    }
    
    private func updateOverlayWithFinishPercent(_ percent: CGFloat, direction: SwipeResultDirection?) {
        overlayView?.overlayState = direction
        let progress = max(min(percent/swipePercentageMargin, 1.0), 0)
        overlayView?.update(progress: progress)
    }
}

extension PackCardView {
    
    private var directions: [SwipeResultDirection] {
        return delegate?.card(cardAllowedDirections: self) ?? [.left, .right]
    }
    
    private var dragDirection: SwipeResultDirection? {
        return (fractionComplete - 0.5 > 0) ? .right : .left
    }
    
    private var dragPercentage: CGFloat {
        guard dragDirection != nil else { return 0 }
        let a = abs(fractionComplete - 0.5) * targetAngle * 2
        return min(a / completionAngle, 1)
    }
    
    private var completionAngle: CGFloat {
        let a = bounds.width * 0.5 / (dot.y - bounds.height)
        return atan(a)
    }
}

extension PackCardView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view is UIControl else {
            return true
        }
        return false
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == panGestureRecognizer else {
            return true
        }
        return delegate?.card(cardShouldDrag: self) ?? true
    }
}
