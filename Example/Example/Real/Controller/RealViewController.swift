//
//  RealViewController.swift
//  Example
//
//  Created by calm on 2019/7/11.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit
import Fable

class RealViewController: UIViewController {
    
    typealias Info = RealModel.Info
    typealias Card = RealModel.Card
    typealias Feel = Real.Feel
    
    @IBOutlet weak var fableView: FableView!
    @IBOutlet weak var skipOverlayView: UIImageView!
    @IBOutlet weak var likeOverlayView: UIImageView!
    
    private weak var loadingView: UIView?
    
    private lazy var model = RealModel().then {
        $0.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFableView()
        setupChild()
        // 加载数据
        model.loadData()
    }
    
    private func setupChild() {
        let controller = RealLoadingController.instance()
        add(child: controller, to: fableView.backgroundView)
        loadingView = controller.view
        loadingView?.isHidden = false
        fableView.backgroundView.cornerRadius = 16.auto()
    }
}


// MARK: - Overlay
extension RealViewController {
    
    func update(skip percentage: CGFloat) {
        resetLike()
        let scale = 1 + percentage
        let x = (70.auto() + 49.auto()) * percentage
        skipOverlayView.transform = CGAffineTransform(translationX: x, y: 0)
            .scaledBy(x: scale, y: scale)
        skipOverlayView.alpha = min(0.9, percentage)
    }
    
    func update(like percentage: CGFloat) {
        resetSkip()
        let scale = 1 + percentage
        let x = -(70.auto() + 49.auto()) * percentage
        likeOverlayView.transform = CGAffineTransform(translationX: x, y: 0)
            .scaledBy(x: scale, y: scale)
        likeOverlayView.alpha = min(0.9, percentage)
    }
    
    func resetSkip() {
        UIView.animate(withDuration: 0.25) {
            self.skipOverlayView.transform = .identity
            self.skipOverlayView.alpha = 0
        }
    }
    
    func resetLike() {
        UIView.animate(withDuration: 0.25) {
            self.likeOverlayView.transform = .identity
            self.skipOverlayView.alpha = 0
        }
    }
    
    func loading() {
        loadingView?.isHidden = false
    }
}


extension RealViewController {
    
    private func setupFableView() {
        
        fableView.backgroundScale = 0.95
        let ratioMargin: CGFloat = 0.45
        
        // 视图层
        let viewSource = ViewSource {
            [weak self] (data: Card) -> UIViewController in
            guard let self = self else { return UIViewController() }
            
            let controller: UIViewController
            switch data {
            case .info(let value):
                let _controller = RealPersonController(value)
                _controller.delegate = self
                _controller.bounces = false
                controller = _controller
                
            // 自定义其他类型页面
            case .other:
                controller = UIViewController()
            }
            
            self.addChild(controller)
            controller.view.cornerRadius = 16.auto()
            return controller
        }
        
        // 事件层
        let actionSource = ActionSource<Card>()
        actionSource.swipeThresholdRatioMargin.delegate(on: self) { (_, _) -> CGFloat in
            return ratioMargin
        }
        
        // 监听滑动进度, 根据滑动进度做预览动画效果
        actionSource.didDraggedPercentage.delegate(on: self) {
            (self, arg1) in
            
            let (_, percentage, direction) = arg1
            let progress = limit(percentage / 100, 0...1)
            switch direction {
            case .left:
                self.update(skip: progress)
            case .right:
                self.update(like: progress)
            }
        }
        
        // 手势结束
        actionSource.panFinished.delegate(on: self) { (self, _) in
            self.resetSkip()
            self.resetLike()
        }
        
        // 即将重置
        actionSource.willResetCard.delegate(on: self) { (self, _) in
            self.resetSkip()
            self.resetLike()
        }
        
        // 设置是否能滑动
        actionSource.shouldDragCard.delegate(on: self) { (self, context) -> Bool in
            return context.data.shouldDrag
        }
        
        // 自定义滑动透传context
        actionSource.slideThroughContext.delegate(on: self) { (self, arg1) -> Any? in
            let (_, direction) = arg1
            switch direction {
            case .left:      return Feel.skip(isSlide: true)
            case .right:     return Feel.like(isSlide: true)
            }
        }
        
        // 卡片被判断滑出
        actionSource.didSwipeCard.delegate(on: self) { (self, arg1) in
            let (card, _, context) = arg1
            
            if case .info(let value) = card.data,
                let feel = context as? Feel {
                self.model.swiped(feel, id: value.id)
            }
        }
        
        // 滑动时候判断能否滑出策略
        actionSource.shouldSwipeCard.delegate(on: self) { (self, arg1) -> Bool in
            let (_, _, context) = arg1
            guard let feel = context as? Feel else { return false }
            
            switch feel {
            case .skip,
                 .like,
                 .love:
                return true
            }
        }
        
        // 卡片显示区为空
        actionSource.didRunOutOfVisibles.delegate(on: self) { (self, _) in
            self.backgroundView(false)
        }
        
        // 等待区数据为空
        actionSource.didRunOutOfDatas.delegate(on: self) { (self, _) in
            // 这里可无缝衔接下一页数据
            self.model.loadData()
        }
        
        let radius = fableView.height * 3
        let animatorSource = AnimatorSource { () -> AngleAnimator in
            let animator = AngleAnimator()
            animator.radius = radius
            animator.targetAngle = .pi / 6
            return animator
        }
        
        let provider = BasicProvider(dataSource: model.dataSource,
                                     viewSource: viewSource,
                                     actionSource: actionSource,
                                     animatorSource: animatorSource)
        
        fableView.provider = provider
    }
}

extension RealViewController: RealPersonViewControllerDelegate {
    // 跳过
    func skipAction() {
        fableView.swipe(.left, context: Feel.skip(isSlide: false))
    }
    
    // 喜欢
    func likeAction() {
        fableView.swipe(.right, context: Feel.like(isSlide: false))
    }
    
    // 超级喜欢
    func loveAction() {
        fableView.swipe(.right, context: Feel.love)
    }
}

extension RealViewController: RealModelDelegate {
    
    func viewLoading() {
        loading()
    }
    
    
    func backgroundView(_ isHidden: Bool) {
        fableView.backgroundView.isHidden = isHidden
    }
}
