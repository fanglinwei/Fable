//
//  PondArray.swift
//  Fable
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

struct PondArray<T> {
    private var size: Int
    private(set) var array: [T]
    var count: Int {
        return array.count
    }
    
    var first: T? {
        return array.first
    }
    
    var last: T? {
        return array.last
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    init(size: Int) {
        self.size = size
        self.array = [T]()
    }
    
    @discardableResult
    mutating func append(_ newElement: T) -> T? {
        if count < size {
            array.append(newElement)
            return nil
            
        } else {
            let temp =  array.removeFirst()
            array.append(newElement)
            return temp
        }
    }
    
    mutating func append(contentsOf newElements:  [T])  {
        newElements.forEach { append($0) }
    }
    
    mutating func removeAll() {
        array.removeAll()
    }
    
    mutating func removeFirst() -> T {
        return array.removeFirst()
    }
    
    mutating func safeRemoveFirst() -> T? {
        return array.safeRemoveFirst()
    }
    
    mutating func set(size: Int) {
        if size <= self.size {
            _ = array.prefix(size)
        }
        
        self.size = size
    }
}

extension PondArray  {
    
    public subscript(index: Int) -> T {
        return array[index]
    }
    
    public subscript(safe index: Int) -> T? {
        guard array.startIndex <= index && index < array.endIndex else {
            return nil
        }
        return self[index]
    }
}

