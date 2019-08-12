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
    func card(_ card: PackCardView, shouldSwipeIn direction: SwipeResultDirection, context: Any?) -> Bool
    func card(_ card: PackCardView, slideThroughContext direction: SwipeResultDirection) -> Any?
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
    
    var animator = Animator() {
        didSet {
            configureAnimator()
        }
    }
    
    /// 滑动半径
    var swipeActionAnimationDuration: TimeInterval {
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
    
    internal func configure(_ cell: FableCardable, overlayView: FableOverlayView?) {
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
    
    private func configureAnimator() {
        animator.view = self
    }
}

// MARK: - GestureRecognizers
extension PackCardView {
    
    @objc
    private func tapRecognized(_ recogznier: UITapGestureRecognizer) {
        delegate?.card(cardWasTapped: self)
    }
    
    @objc
    private func panRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            removeAnimations()
            dragBegin = true
            delegate?.card(cardPanBegan: self)
            // 图像优化
            // https://www.jianshu.com/p/2a01e5e2141f
            layer.rasterizationScale = UIScreen.main.scale
            layer.shouldRasterize = true
            animator.handle(gestureRecognizer)
            
        case .changed:
            animator.handle(gestureRecognizer)
            
            let percentage = dragPercentage
            updateOverlayWithFinishPercent(percentage, direction: dragDirection)
            if let dragDirection = dragDirection {
                delegate?.card(self, wasDraggedWithFinishPercentage: min(abs(100 * percentage), 100), inDirection: dragDirection)
            }
        case .ended, .cancelled:
            isUserInteractionEnabled = false
            delegate?.card(cardPanFinished: self)
            
            // 滑动
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
        animator.removeAnimations()
    }
    
    internal func swipe(_ direction: SwipeResultDirection,
                        _ context: Any?,
                        completionHandler: @escaping () -> Void) {
        guard !dragBegin else { return }
        isUserInteractionEnabled = false
        delegate?.card(self, wasSwipedIn: direction, context: context)
        animator.swipe(direction) { [weak self] in
            guard let self = self else { return }
            completionHandler()
            self.removeFromSuperview()
        }
    }
}

extension PackCardView {
    
    private func swipeMadeAction() {
        let shouldSwipe = { [weak self] (direction: SwipeResultDirection) -> Bool in
            guard let self = self else { return true }
            let context = self.delegate?.card(self, slideThroughContext: direction)
            return self.delegate?.card(self, shouldSwipeIn: direction, context: context) ?? true
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
        let context = delegate?.card(self, slideThroughContext: direction)
        delegate?.card(self, wasSwipedIn: direction, context: context)
        overlayView?.overlayState = direction
        overlayView?.alpha = 1.0
        animator.swipeAction(panGestureRecognizer, direction) { [weak self] in
            guard let self = self else { return }
            self.dragBegin = false
            self.removeFromSuperview()
        }
    }
    
    private func resetViewPositionAndTransformations() {
        delegate?.card(cardWillReset: self)
        animator.resetViewPosition(animations: { [weak self] in
            self?.overlayView?.alpha = 0
        }) { [weak self] in
            guard let self = self else { return }
            self.delegate?.card(cardDidReset: self)
            self.dragBegin = false
            self.isUserInteractionEnabled = true
        }
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
        return animator.dragDirection
    }
    
    private var dragPercentage: CGFloat {
        return animator.dragPercentage
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
