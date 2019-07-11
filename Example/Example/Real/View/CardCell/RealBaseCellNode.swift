//
//  HomeBaseCellNode.swift
//  Social
//
//  Created by calm on 2019/5/28.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealBaseCellNode: ASCellNode {
    
    var topCorner: Bool = false
    var bottomCorner: Bool = false
    
    lazy var contentNode = ASDisplayNode()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func layout() {
        super.layout()
        contentNode.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private func setupCorner() {
        switch (topCorner, bottomCorner) {
        case (true, true):
            roundCorners([.allCorners], radius: 16.auto())
        case (true, false):
            roundCorners([.topLeft, .topRight], radius: 16.auto())
        case (false, true):
            roundCorners([.bottomLeft, .bottomRight], radius: 16.auto())
            
        case (false, false):
            roundCorners([.allCorners], radius: 0)
        }
    }

    private func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

