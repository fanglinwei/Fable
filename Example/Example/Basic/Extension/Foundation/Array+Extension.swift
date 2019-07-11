//
//  Array+Extension.swift
//  Example
//
//  Created by calm on 2019/7/11.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

extension Array {
    
    @discardableResult
    mutating func safeRemoveFirst() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return removeFirst()
    }
    
    mutating func safeRemoveLast() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return removeLast()
    }
}
