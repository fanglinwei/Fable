//
//  UIEdgeInsets.swift
//  CGExtension
//
//  Created by calm on 2019/5/31.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    var horizontal: CGFloat { return left + right }
    
    var vertical: CGFloat { return top + bottom }
    
    init(_ t: CGFloat, _ l: CGFloat, _ b: CGFloat, _ r: CGFloat) {
        self.init(top: t, left: l, bottom: b, right: r)
    }
    
    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.init()
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical/2, left: horizontal/2, bottom: vertical/2, right: horizontal/2)
    }
}
