//
//  PackCardView.swift
//  Fable
//
//  Created by calm on 2019/5/14.
//  Copyright © 2019 calm. All rights reserved.
//

private let screenSize = UIScreen.main.bounds.size
typealias SwipedCompletion = () -> Void

protocol PackCardViewDelegate: class {
    
    func card(_ card: PackCardView, wasDraggedWithFinishPercentage percentage: CGFloat, inDirection direction: SwipeResultDirection)
    func card(_ card: PackCardView, wasSwipedIn direction: SwipeResultDirection, context: Any?) -> SwipedCompletion
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
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var animationDirectionY: CGFloat = 1.0
    private var swipePercentageMargin: CGFloat = 1
    
    /// 滑动圆心
    private var dot: CGPoint {
        let r = (radius ?? bounds.height * 2) + bounds.height * 0.5
        return CGPoint(x: bounds.width * 0.5, y: abs(r))
    }
    
    private var animator = UIViewPropertyAnimator()
    private var animationProgress: CGFloat = 0
    private var targetTransform = CGAffineTransform.identity
    
    
    override public var frame: CGRect {
        didSet {
            configureSwipePercentageMargin()
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
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
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PackCardView.panGestureRecognized(_:)))
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PackCardView.tapRecognized(_:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    deinit {
        print("deinit:\t\(classForCoder)")
        contentCard?.removeFromSuper()
        removeGestureRecognizer(panGestureRecognizer)
        removeGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - configure
extension PackCardView {
    
    //MARK: Configurations
    func configure(_ cell: FableCardable, overlayView: FableOverlayView?) {
        self.overlayView?.removeFromSuperview()
        self.contentCard?.removeFromSuper()
        
        if let overlay = overlayView {
            self.overlayView = overlay
            overlay.alpha = 0;
            self.addSubview(overlay)
            self.insertSubview(cell._content, belowSubview: overlay)
        } else {
            self.addSubview(cell._content)
        }
        
        self.contentCard = cell
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
    
    @objc func panGestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            removeAnimations()
            dragBegin = true
            animationDirectionY = 1.0
            layer.rasterizationScale = UIScreen.main.scale
            layer.shouldRasterize = true
            delegate?.card(cardPanBegan: self)
            
            set(anchorPoint: CGPoint(x: 0.5, y: dot.y / bounds.height))
            transform = CGAffineTransform(rotationAngle: -targetAngle)
            targetTransform = CGAffineTransform(rotationAngle: targetAngle)
            startAnimationIfNeeded()
            animator.pauseAnimation()
            animator.fractionComplete = 0.5
            animationProgress = animator.fractionComplete
            
        case .changed:
            
            /*
             atan 反正切函数
             旋转角度 = 反正切/(位移的距离/圆点到手势触摸的点)
             */
            let dragDistance = gestureRecognizer.translation(in: superview)
            let location = gestureRecognizer.location(in: superview)
            
            let a = dragDistance.x / (dot.y - location.y)
            let rotationAngle =  atan(a)
            var fraction = rotationAngle / (targetAngle * 2)
            if animator.isReversed { fraction *= -1 }
            animator.fractionComplete = fraction + animationProgress
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

extension PackCardView {
    
    //MARK: Public
    func removeAnimations() {
        animator.stopAnimation(true)
    }
    
    func swipe(_ direction: SwipeResultDirection,
               _ context: Any?,
               completionHandler: @escaping () -> Void) {
        
        guard !dragBegin else { return }
        let completion = delegate?.card(self, wasSwipedIn: direction, context: context)
        
        set(anchorPoint: CGPoint(x: 0.5, y: dot.y / bounds.height))
        transform = CGAffineTransform(rotationAngle: -targetAngle)
        targetTransform = CGAffineTransform(rotationAngle: targetAngle)
        startAnimationIfNeeded()
        animator.pauseAnimation()
        animator.fractionComplete = 0.5
        
        if direction == .left {
            animator.isReversed.toggle()
        }
        
        animator.addCompletion { [weak self]_ in
            guard let self = self else { return }
            completion?()
            completionHandler()
            self.removeFromSuperview()
        }
        
        let timingParameters = UISpringTimingParameters(damping: 0.9, response: 1.2)
        let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
        let durationFactor = CGFloat(preferredDuration / animator.duration)
        animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
    }
    
    private func cutting(_ angle: CGFloat, for portion: Int) -> [CGFloat] {
        return (0 ..< portion).reduce(into: []) { (array, index) in
            let temp = angle / CGFloat(portion) * CGFloat(index)
            array.append(temp)
        }
    }
    
    private func keyTimes(for portion: Int) -> [NSNumber] {
        return (0 ..< portion).reduce(into: []) { (array, index) in
            let temp = 1 / Double(portion) * Double(index)
            array.append(NSNumber(value: temp))
        }
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
        let completion =  self.delegate?.card(self, wasSwipedIn: direction, context: nil)
        let location = panGestureRecognizer.location(in: superview)
        let velocity = panGestureRecognizer.velocity(in: superview)
        overlayView?.overlayState = direction
        overlayView?.alpha = 1.0
        
        if direction == .left {
            animator.isReversed.toggle()
        }
        
        let radius = dot.y - location.y
        let fraction = 0.5 - abs(0.5 - animator.fractionComplete)
        let angle = fraction * targetAngle * 2
        let distance = radius * tan(angle)
        let relativeVelocity = abs(velocity.x) / distance
        let timingParameters = UISpringTimingParameters(damping: 1, response: 1.2, initialVelocity: CGVector(dx: relativeVelocity, dy: 0))
        let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
        let durationFactor = CGFloat(preferredDuration / animator.duration)
        
        animator.addCompletion { position in
            completion?()
            self.removeFromSuperview()
        }
        animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
    }
    
    private func resetViewPositionAndTransformations() {
        delegate?.card(cardWillReset: self)
        removeAnimations()
        animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.7)
        animator.addAnimations {
            self.transform = .identity
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
    
    
    private func startAnimationIfNeeded() {
        if animator.isRunning { return }
        let timingParameters = UISpringTimingParameters(damping: 1, response: 1.2)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            self.transform = self.targetTransform
        }
        animator.addCompletion { [weak self] position in
            guard let self = self else { return }
            self.dragBegin = false
        }
    }
}

extension PackCardView {
    
    private var directions: [SwipeResultDirection] {
        return delegate?.card(cardAllowedDirections: self) ?? [.left, .right]
    }
    
    private var dragDirection: SwipeResultDirection? {
        return (animator.fractionComplete - 0.5 > 0) ? .right : .left
    }
    
    private var dragPercentage: CGFloat {
        guard dragDirection != nil else { return 0 }
        let a = abs(animator.fractionComplete - 0.5) * targetAngle * 2
        return min(a / completionAngle, 1)
    }
    
    var completionAngle: CGFloat {
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

extension UIView {
    
    func set(anchorPoint point: CGPoint ) {
        let newAnchorPoint = point
        let oldPosition = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
        let newPosition = CGPoint(x: bounds.size.width * newAnchorPoint.x, y: bounds.size.height * newAnchorPoint.y)
        layer.anchorPoint = newAnchorPoint
        layer.position = CGPoint(x: layer.position.x - oldPosition.x + newPosition.x, y: layer.position.y - oldPosition.y + newPosition.y)
        frame.origin.x = layer.position.x - layer.anchorPoint.x * bounds.size.width
        frame.origin.y = layer.position.y - layer.anchorPoint.y * bounds.size.height
    }
}
