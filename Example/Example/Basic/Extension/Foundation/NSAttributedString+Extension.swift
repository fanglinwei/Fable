//
//  NSAttributedString+Extension.swift
//  LiveTrivia
//
//  Created by Gesen on 2017/11/25.
//  Copyright © 2017年 LiveTrivia. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    func sizeToFits(_ size: CGSize) -> CGSize {
        let framesetter = CTFramesetterCreateWithAttributedString(self)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, size, nil)
        return textSize
    }
    
    func applying(_ attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = (string as NSString).range(of: string)
        copy.addAttributes(attributes, range: range)
        return copy
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: left)
    result.append(right)
    return result
}

func + (left: NSAttributedString, right: String) -> NSAttributedString {
    guard !left.string.isEmpty else {
        return right.toAttr()
    }

    let result = NSMutableAttributedString(attributedString: left)
    result.append(right.toAttr(left.attributes(at: 0, effectiveRange: nil)))
    return result
}
