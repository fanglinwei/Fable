//
//  Provider.swift
//  Fable
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

public protocol Provider {
    var numberOfWaitings: Int { get }
    var isVisibleFull: Bool { get }
    var visibleSize: Int { get }
    var recycleSize: Int { get }
    
    func willReload()
    func didReload()
}

extension Provider {
    
    public func willReload() {}
    public func didReload() {}
}

protocol ItemProvider: Provider {
    func clean()
    func popVisible()
    func takeVisible() -> FableCard?
    
    func swipeThresholdRatioMargin(_ card: FableCard?) -> CGFloat
    func viewForCardOverlay(_ card: FableCard?) -> FableOverlayView?
    func didShowCard(_ card: FableCard?)
    func didSwipeCard(_ card: FableCard?, _ direction: SwipeResultDirection, _ context: Any?)
    func didSelectCard(_ card: FableCard?)
    func panBegan(_ card: FableCard?)
    func panFinished(_ card: FableCard?)
    func didDraggedPercentage(_ card: FableCard?, _ percentage: CGFloat, _ direction: SwipeResultDirection)
    func shouldSwipeCard(_ card: FableCard?, _ direction: SwipeResultDirection) -> Bool
    func willResetCard(_ card: FableCard?)
    func didResetCard(_ card: FableCard?)
    func didRunOutOfVisibles()
    func didRunOutOfDatas()
    func shouldDragCard(_ card: FableCard?) -> Bool
    
    var needsLoadFill: Delegate<[FableCard], Void> { get }
    
    func flattenedProvider() -> ItemProvider
}

extension ItemProvider {
    
    public var isVisibleFull: Bool { return false }
    
    func takeVisible() -> FableCard? {
        return nil
    }
    
    func popVisible() {}
    
    func clean() {}
    
    func flattenedProvider() -> ItemProvider {
        return self
    }
}
