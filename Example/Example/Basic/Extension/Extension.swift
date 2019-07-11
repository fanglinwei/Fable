//
//  +TopLevel.swift
//  LiveTrivia
//
//  Created by Gesen on 2017/11/22.
//  Copyright © 2017年 LiveTrivia. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import SwifterSwift
import Then
import AutoInch

/// 打印日志
///
/// - Parameters:
///   - items: 内容
///   - separator: 分隔符
///   - terminator: 结束符
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items[0], separator:separator, terminator: terminator)
    #endif
}

// Layout
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

/// limit a value to a range so that it is not less than the minimum, nor higher than the maximum
///
///     limit(1, 5...10)
///     // 5
///     limit(-1, 5...10)
///     // 5
///     limit(8, 5...10)
///     // 8
///     limit(11, 5...10)
///     // 10
///
/// - Parameters:
///   - x: value
///   - range: Closed range
func limit<T>(_ x: T, _ range: ClosedRange<T>) -> T where T : Comparable {
    return min(max(x, range.lowerBound), range.upperBound)
}
