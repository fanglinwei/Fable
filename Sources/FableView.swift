//
//  FableView.swift
//  Fable
//
//  Created by calm on 2019/5/14.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

public final class FableView: UIView {
    
    public var provider: Provider? {
        didSet {
            guard let provider = provider as? ItemProvider  else {
                return
            }
            flattenedProvider = provider.flattenedProvider()
            _visibles.set(size: flattenedProvider.visibleSize)
            _recycles.set(size: flattenedProvider.recycleSize)
            
            flattenedProvider.needsLoadFill.delegate(on: self) { (self, cells) in
                self.setNeedsLoadFill(cells)
            }
        }
    }
    
    public var targetAngle: CGFloat = 0.69
    public var radius: CGFloat?
    /// 拖动时背景是否能做移动动画
    public var shouldMoveBackgroundCard = true
    public var backgroundScale: CGFloat = 0.9
    public var isAnimating: Bool { return animationSemaphore.isAnimating }
    public var shouldPassthroughTapsWhenNoVisibleCards = false
    public private(set) lazy var backgroundView = UIView()
    public var hasLoadFillCount: Bool { return loadFillCount > 0 }
    
    private var loadFillCount = 0
    private var isLoadFilling = false
    private lazy var flattenedProvider: ItemProvider = EmptyProvider()
    
    public var visibles: [PackCardView] {
        return _visibles.array
    }
    
    private var reverseAnimationDuration: TimeInterval = 0.3
    private var cardIsDragging: Bool {
        guard let frontCard = _visibles.first else {
            return false
        }
        return frontCard.dragBegin
    }
    
    private var _visibles: PondArray<PackCardView> = PondArray(size: 3)
    private var _recycles: PondArray<PackCardView> = PondArray(size: 2)
    private var animationSemaphore = AnimationSemaphore()
    
    private var currentView: FableCard?  {
        return _visibles.first?.contentCard
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup()  {
        addSubview(backgroundView)
        backgroundView.backgroundColor = .clear
        backgroundView.fillToSuperview()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard !animationSemaphore.isAnimating, !cardIsDragging else {
            return
        }
        
        layoutDeck()
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard shouldPassthroughTapsWhenNoVisibleCards else {
            return super.point(inside: point, with: event)
        }
        
        if super.point(inside: point, with: event) {
            return _visibles.count > 0
        } else {
            return false
        }
    }
}

extension FableView {
    
    /// 清空资源
    public func clean() {
        _visibles.array.forEach { $0.removeFromSuperview() }
        _recycles.array.forEach { $0.removeFromSuperview() }
        
        _visibles.removeAll()
        _recycles.removeAll()
        
        loadFillCount = 0
        flattenedProvider.clean()
    }
    
    
    /// 左右滑动卡片
    ///
    /// - Parameters:
    ///   - direction: 滑动方向
    ///   - force: 是否强制滑动
    ///   - context: 上下文
    public func swipe(_ direction: SwipeResultDirection,
                      force: Bool = false,
                      context: Any? = nil) {
        let shouldSwipe =  flattenedProvider.shouldSwipeCard(currentView, direction)
        guard force || shouldSwipe else { return }
        guard !animationSemaphore.isAnimating else { return }
        guard
            let card = _visibles.first,
            !card.dragBegin else {
            return
        }
        
        animationSemaphore.increment()
        card.swipe(direction, context) { [weak self] in
            guard let self = self else { return }
            self.animationSemaphore.decrement()
        }
        card.delegate = nil
    }
}

extension FableView {
    
    private func setNeedsLoadFill(_ cells: [FableCard]) {
        guard !isLoadFilling else { return }
        provider?.willReload()
        isLoadFilling = true
        
        // 加载视图
        for cell in cells {
            
            let view = PackCardView(frame: bounds)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            // 添加到显示池子
            _visibles.append(view)
            let i = _visibles.count - 1
            layoutCard(view, at: i)
            view.delegate = self
            view.configure(cell, overlayView: nil)
            view.targetAngle = targetAngle
            if let radius = radius {
                view.radius = radius
            }
            view.isUserInteractionEnabled = i == 0
            insertSubview(view, aboveSubview: backgroundView)
        }
        
        isLoadFilling = false
        
        loadFillCount += 1
        flattenedProvider.didReload()
        
        if loadFillCount == 1 {
            flattenedProvider.didShowCard(currentView)
        }
    }
    
    private func loadNewCard() {
        guard let contentView = flattenedProvider.takeVisible() else {
            return
        }
        let view = PackCardView(frame: bounds)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // 添加到显示池子
        _visibles.append(view)
        let i = visibles.count - 1
        view.delegate = self
        view.configure(contentView, overlayView: nil)
        view.targetAngle = targetAngle
        view.isUserInteractionEnabled = false
        layoutCard(view, at: i)
        if let radius = radius {
            view.radius = radius
        }
        
        insertSubview(view, aboveSubview: backgroundView)
    }
    
    // MARK: Actions
    private func swipedAction(_ direction: SwipeResultDirection, context: Any?) {
        let current = currentView
        
        if let temp = _visibles.safeRemoveFirst() {
            _recycles.append(temp)
        }
        
        if flattenedProvider.numberOfWaitings - 1 <= 0 {
            flattenedProvider.didRunOutOfDatas()
        }
        
        if flattenedProvider.numberOfWaitings != 0 {
            loadNewCard()
        } else {
            flattenedProvider.popVisible()
        }
        
        if !_visibles.isEmpty {
            animationSemaphore.increment()
            animateCardsAfterLoading { [weak self] in
                guard let self = self else { return }
                self.animationSemaphore.decrement()
                self.flattenedProvider.didSwipeCard(current, direction, context)
                self.flattenedProvider.didShowCard(self.currentView)
                self.setNeedsLayout()
            }
        } else {
            self.flattenedProvider.didSwipeCard(current, direction, context)
            self.flattenedProvider.didRunOutOfVisibles()
            self.setNeedsLayout()
        }
    }
    
    private func moveOtherCardsWithPercentage(_ percentage: CGFloat) {
        guard _visibles.count > 1 else {
            return
        }
        for index in 1 ..< visibles.count {
            let fraction: CGFloat = percentage / 100
            let card = visibles[index]
            let percent = pow(backgroundScale, CGFloat(index))
            let scale = (1 - percent) * fraction + percent
            card.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    private func layoutDeck() {
        for (index, card) in _visibles.array.enumerated() {
            layoutCard(card, at: index)
        }
    }
    
    private func layoutCard(_ card: PackCardView, at index: Int) {
        if index == 0 {
            card.transform = .identity
        } else {
            let scale = cardScale(with: index)
            card.transform = CGAffineTransform(scaleX: scale.width, y: scale.height)
        }
    }
    
    private func cardScale(with index: Int) -> CGSize {
        let percent = pow(backgroundScale, CGFloat(index))
        return CGSize(width: percent, height: percent)
    }
    
    private func animateCardsAfterLoading(_ completion: (() -> Void)? = nil) {
        for (index, card) in _visibles.array.enumerated() {
            card.removeAnimations()
            card.isUserInteractionEnabled = index == 0
            if index == 0 {
                let scale = cardScale(with: index)
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0.0,
                    options: .curveLinear,
                    animations: {
                        card.transform = CGAffineTransform(scaleX: scale.width, y: scale.height)
                }) { finished in
                    completion?()
                }
            }
        }
    }
}

extension FableView: PackCardViewDelegate {
    
    func card(_ card: PackCardView, wasDraggedWithFinishPercentage percentage: CGFloat, inDirection direction: SwipeResultDirection) {
        if shouldMoveBackgroundCard {
            moveOtherCardsWithPercentage(percentage)
        }
        flattenedProvider.didDraggedPercentage(currentView, percentage, direction)
    }
    
    func card(_ card: PackCardView, wasSwipedIn direction: SwipeResultDirection, context: Any?) {
        swipedAction(direction, context: context)
    }
    
    func card(_ card: PackCardView, shouldSwipeIn direction: SwipeResultDirection) -> Bool {
        return flattenedProvider.shouldSwipeCard(currentView, direction)
    }
    
    func card(cardWillReset card: PackCardView) {
        defer { flattenedProvider.willResetCard(currentView) }
        guard _visibles.count > 1 else { return }

        animationSemaphore.increment()
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.moveOtherCardsWithPercentage(0)
        }) { [weak self] _ in
            self?.animationSemaphore.decrement()
        }
    }
    
    func card(cardDidReset card: PackCardView) {
        flattenedProvider.didResetCard(currentView)
    }
    
    func card(cardWasTapped card: PackCardView) {
        flattenedProvider.didSelectCard(currentView)
    }
    
    func card(cardSwipeThresholdRatioMargin card: PackCardView) -> CGFloat {
        return flattenedProvider.swipeThresholdRatioMargin(currentView)
    }
    
    func card(cardAllowedDirections card: PackCardView) -> [SwipeResultDirection] {
        return [.left, .right]
    }
    
    func card(cardShouldDrag card: PackCardView) -> Bool {
        return flattenedProvider.shouldDragCard(currentView)
    }
    
    func card(cardSwipeSpeed card: PackCardView) -> Speed {
        return .default
    }
    
    func card(cardPanBegan card: PackCardView) {
        flattenedProvider.panBegan(currentView)
    }
    
    func card(cardPanFinished card: PackCardView) {
        flattenedProvider.panFinished(currentView)
    }
}
