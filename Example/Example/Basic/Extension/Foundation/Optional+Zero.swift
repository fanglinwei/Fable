//
//  Optional+Empty.swift
//  Social
//
//  Created by calm on 2019/6/3.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import Foundation

// MARK: - Methods (BinaryFloatingPoint)
public extension Optional where Wrapped: BinaryFloatingPoint {
    
    /// SwifterSwift: Check if optional is nil or zero float.
    var isNilOrZero: Bool {
        guard let float = self else { return true }
        return float.isZero
    }
    
    /// SwifterSwift: Returns the float only if it is not nill and not zero.
    var nonZero: Wrapped? {
        guard let float = self else { return nil }
        guard !float.isZero else { return nil }
        return float
    }
}

// MARK: - Methods (BinaryInteger)
public extension Optional where Wrapped: BinaryInteger {
    
    /// SwifterSwift: Check if optional is nil or zero integer.
    var isNilOrZero: Bool {
        guard let integer = self else { return true }
        return integer.isZero
    }
    
    /// SwifterSwift: Returns the integer only if it is not nill and not zero.
    var nonZero: Wrapped? {
        guard let integer = self else { return nil }
        guard !integer.isZero else { return nil }
        return integer
    }
}

extension BinaryInteger {
    
    /// SwifterSwift: Return true if 1, or other if false.
    ///
    ///        0.isZero -> true
    ///        1.isZero -> false
    ///        2.isZero -> false
    ///
    var isZero: Bool {
        return self == 0
    }
}


