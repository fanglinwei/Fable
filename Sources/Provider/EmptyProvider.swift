//
//  EmptyProvider.swift
//  Fable
//
//  Created by calm on 2019/6/13.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

class EmptyProvider: ItemProvider {
    
    public var visibleSize: Int { return 0 }
    
    public var recycleSize: Int { return 0 }
    
    public var numberOfWaitings: Int { return 0 }
    
    var needsLoadFill: Delegate<[FableCard], Void> = .init()
    
    func swipeThresholdRatioMargin(_ card: FableCard?) -> CGFloat { return 0.5}
    func viewForCardOverlay(_ card: FableCard?) -> FableOverlayView? { return nil}
    func didShowCard(_ card: FableCard?) {}
    func didSwipeCard(_ card: FableCard?, _ direction: SwipeResultDirection, _ context: [String: Any]?) {}
    func didSelectCard(_ card: FableCard?) {}
    func panBegan(_ card: FableCard?) {}
    func panFinished(_ card: FableCard?) {}
    func didDraggedPercentage(_ card: FableCard?, _ percentage: CGFloat, _ direction: SwipeResultDirection) {}
    func shouldSwipeCard(_ card: FableCard?, _ direction: SwipeResultDirection) -> Bool { return true}
    func willResetCard(_ card: FableCard?) {}
    func didResetCard(_ card: FableCard?) {}
    func didRunOutOfVisibles() {}
    func didRunOutOfDatas() {}
    func shouldDragCard(_ card: FableCard?) -> Bool { return true }
}
