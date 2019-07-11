//
//  RealSpaceCellNode.swift
//  Social
//
//  Created by calm on 2019/6/25.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealSpaceCellNode: RealBaseCellNode {
    
    let value: CGFloat
    init(_ value: CGFloat) {
        self.value = value
        super.init()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        contentNode.style.preferredSize = CGSize(0, value)
        return ASWrapperLayoutSpec(layoutElement: contentNode)
    }
}
