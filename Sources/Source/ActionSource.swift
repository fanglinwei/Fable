//
//  ActionSource.swift
//  Fable
//
//  Created by calm on 2019/6/13.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

public class ActionSource<Data> {
    
    public struct Context {
        public let card: FableCard?
        public let data: Data
        
        init(_ card: FableCard? = nil, _ data: Data) {
            self.card = card
            self.data = data
        }
    }
    
    /// 滑动蒙层view
    public let viewForCardOverlay = Delegate<Context, FableOverlayView?>()
    /// 卡片显示
    public let didShowCard = Delegate<Context, Void>()
    /// 当卡片滑动时透传上下文
    public let slipThroughContext = Delegate<(Context, SwipeResultDirection), Any?>()
    /// 当卡片出去   (主动调用Swipe滑出/手势滑出)
    public let didSwipeCard = Delegate<(Context, SwipeResultDirection, context: Any?), Void>()
    /// 卡片被点
    public let didSelectCard = Delegate<Context, Void>()
    /// 手势开始
    public let panBegan = Delegate<Context, Void>()
    /// 手势结束
    public let panFinished = Delegate<Context, Void>()
    ///  手势滑动进度
    public let didDraggedPercentage = Delegate<(Context, percentage: CGFloat, direction: SwipeResultDirection), Void>()
    /// 是否能拖出去
    public let shouldSwipeCard = Delegate<(Context, SwipeResultDirection, context: Any?), Bool>()
    /// 即将重置卡片
    public let willResetCard = Delegate<Context, Void>()
    /// 已经重置卡片
    public let didResetCard = Delegate<Context, Void>()
    // 显示区卡片为空
    public let didRunOutOfVisibles = Delegate<Void, Void>()
    /// 等待区数据为空
    public let didRunOutOfDatas = Delegate<Context, Void>()
    /// 卡片是否能被拖动
    public let shouldDragCard = Delegate<Context, Bool>()
    /// 甩出比例
    public let swipeThresholdRatioMargin = Delegate<Context, CGFloat>()
    
    public init() {}
}
