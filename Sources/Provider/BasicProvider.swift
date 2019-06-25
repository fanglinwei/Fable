//
//  BasicProvider.swift
//  Fable
//
//  Created by calm on 2019/6/13.
//  Copyright © 2019 calm. All rights reserved.
//

public class BasicProvider<Data, View: FableCardable>: ItemProvider {
    
    typealias Context = ActionSource<Data>.Context
    
    public var dataSource: ArrayDataSource<Data>
    public var viewSource: ViewSource<Data, View>
    public var actionSource: ActionSource<Data>
    public var visibleSize: Int { return dataSource.visibleSize }
    public var recycleSize: Int { return dataSource.recycleSize }
    
    var needsLoadFill: Delegate<[FableCard], Void> = .init()
    
    public init(dataSource: ArrayDataSource<Data>,
                viewSource: ViewSource<Data, View>,
                actionSource: ActionSource<Data>) {
        self.dataSource = dataSource
        self.viewSource = viewSource
        self.actionSource = actionSource
        self.dataSource.needsLoadFill.delegate(on: self) { (self, data) in
            let views = data.map { self.viewSource.view(data: $0)}
            self.needsLoadFill.call(views)
        }
    }
    
    public var numberOfWaitings: Int {
        return dataSource.numberOfWaitings
    }
    
    public var isVisibleFull: Bool {
        return dataSource.isVisibleFull
    }
    
    func takeVisible() -> FableCard? {
        guard let data = dataSource.pushVisible() else {
            return nil
        }
        return viewSource.view(data: data)
    }
    
    func popVisible() {
        dataSource.popVisible()
    }
    
    public func clean() {
        dataSource.clean()
    }
}

// MARK: - Action
extension BasicProvider {
    
    func swipeThresholdRatioMargin(_ card: FableCard?) -> CGFloat {
        guard let data = dataSource.visibles.first else {
            return 0.5
        }
        
        let context = Context(card, data)
        return actionSource.swipeThresholdRatioMargin.call(context) ?? 0.5
    }
    
    func viewForCardOverlay(_ card: FableCard?) -> FableOverlayView? {
        guard let data = dataSource.visibles.first else {
            return nil
        }
        
        let context = Context(card, data)
        return actionSource.viewForCardOverlay.call(context) ?? nil
    }
    
    func didShowCard(_ card: FableCard?) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.didShowCard.call(context)
    }
    
    func didSwipeCard(_ card: FableCard?, _ direction: SwipeResultDirection, _ context: Any?) {
        guard let data = dataSource.recycles.last else { return }
        let _context = Context(card, data)
        actionSource.didSwipeCard.call((_context, direction, context))
    }
    
    func didSelectCard(_ card: FableCard?) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.didSelectCard.call(context)
    }
    
    func panBegan(_ card: FableCard?) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.panBegan.call(context)
    }
    
    func panFinished(_ card: FableCard?) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.panFinished.call(context)
    }
    
    func didDraggedPercentage(_ card: FableCard?, _ percentage: CGFloat, _ direction: SwipeResultDirection) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.didDraggedPercentage.call((context, percentage, direction))
    }
    
    func shouldSwipeCard(_ card: FableCard?,
                         _ direction: SwipeResultDirection,
                         _ context: Any?) -> Bool {
        
        guard let data = dataSource.visibles.first else { return true }
        let _context = Context(card, data)
        return actionSource.shouldSwipeCard.call((_context, direction, context)) ?? true
    }
    
    func willResetCard(_ card: FableCard?) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.willResetCard.call(context)
    }
    
    func didResetCard(_ card: FableCard?) {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(card, data)
        actionSource.didResetCard.call(context)
    }
    
    func didRunOutOfVisibles() {
        actionSource.didRunOutOfVisibles.call()
    }
    
    func didRunOutOfDatas() {
        guard let data = dataSource.visibles.first else { return }
        let context = Context(nil, data)
        actionSource.didRunOutOfDatas.call(context)
    }
    
    func shouldDragCard(_ card: FableCard?) -> Bool {
        guard let data = dataSource.visibles.first else { return true }
        let context = Context(card, data)
        return actionSource.shouldDragCard.call(context) ?? true
    }
}
