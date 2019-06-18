//
//  ArrayDataSource.swift
//  Fable
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

public class ArrayDataSource<Data> {
    
    public private(set) var data: [Data] = []
    
    public var visibleCount: Int { return visibles.count }
    public var recycleCount: Int { return recycles.count }
    
    var visibles: PondArray<Data>
    var recycles: PondArray<Data>
    let visibleSize: Int
    let recycleSize: Int
    
    public var isVisibleFull: Bool {
        return visibleSize == visibleCount
    }
    
    let needsLoadFill = Delegate<[Data], Void>()
    
    public init(visibleSize: Int = 3,
                recycleSize: Int = 2) {
        
        assert(visibleSize > 0, "visibleSize 必须大于一个")
        assert(recycleSize > 0, "recycleSize 必须大于一个")
        
        self.visibleSize = visibleSize
        self.recycleSize = recycleSize
        self.visibles =  PondArray(size: visibleSize)
        self.recycles =  PondArray(size: recycleSize)
    }
    
    public func visibles(at: Int) -> Data? {
        return visibles[safe: at]
    }
    
    public func recycles(at: Int) -> Data? {
        return recycles[safe: at]
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
    
    func popVisible() {
        if let temp = visibles.safeRemoveFirst()  {
            recycles.append(temp)
        }
    }
}


