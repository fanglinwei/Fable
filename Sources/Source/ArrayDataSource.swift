//
//  ArrayDataSource.swift
//  Fable
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

public class ArrayDataSource<Data> {
    
    public private(set) var data: [Data] = []
    
    var visibles: PondArray<Data>
    var recycles: PondArray<Data>
    let visibleCount: Int
    let recycleCount: Int
    
    public var isVisibleFull: Bool {
        return visibleCount == visibles.count
    }
    
    let needsLoadFill = Delegate<[Data], Void>()
    
    public init(visibleCount: Int = 3,
                recycleCount: Int = 2) {
        
        assert(visibleCount > 0, "visibleCount 必须大于一个")
        assert(recycleCount > 0, "recycleCount 必须大于一个")
        
        self.visibleCount = visibleCount
        self.recycleCount = recycleCount
        self.visibles =  PondArray(size: visibleCount)
        self.recycles =  PondArray(size: recycleCount)
    }
    
    public func visibles(at: Int) -> Data? {
        return visibles[safe: at]
    }
    
    public func recycles(at: Int) -> Data? {
        return recycles[safe: at]
    }
    
    func clean() {
        data.removeAll()
        visibles.removeAll()
        recycles.removeAll()
    }
    
    func pushVisible() -> Data? {
        guard let data = data.safeRemoveFirst() else {
            return nil
        }
        
        if let temp = visibles.append(data)  {
            recycles.append(temp)
        }
        return data
    }
    
    @discardableResult
    func popVisible() {
        if let temp = visibles.safeRemoveFirst()  {
            recycles.append(temp)
        }
    }
    
    public var numberOfWaitings: Int {
        return data.count
    }
    
    public func append(_ datas: [Data]) {
        data = datas
        
        guard !isVisibleFull  else {
            return
        }
        var isWaitEmpty = false
        var temps: [Data] = []
        while !isVisibleFull, !isWaitEmpty {
            guard let data = data.safeRemoveFirst() else {
                isWaitEmpty = true
                break
            }
            visibles.append(data)
            temps.append(data)
        }
        
        needsLoadFill.call(temps)
    }
}


