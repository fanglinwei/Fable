//
//  RealPersonNode.swift
//  Social
//
//  Created by calm on 2019/6/20.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealPersonNode: ASDisplayNode {
    
    lazy var indicatorNode = IndicatorNode()
    
    lazy var tableNode = ASTableNode().then {
        $0.backgroundColor = .white
        $0.allowsSelection = false
        $0.view.separatorStyle = .none
        $0.view.showsVerticalScrollIndicator = false
    }
    
    var bounces: Bool {
        get { return tableNode.view.bounces }
        set { tableNode.view.bounces = newValue }
    }
    
    private var indicatorY: CGFloat = 0
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let size = CGSize(4, 100).auto()
        indicatorNode.style.preferredSize = size
        let edge = UIEdgeInsets(top: 24.auto() + indicatorY,
                                left: .infinity,
                                bottom: .infinity,
                                right: 24.auto())
        
        let indicator = ASInsetLayoutSpec(insets: edge, child: indicatorNode)
        return ASOverlayLayoutSpec(child: tableNode, overlay: indicator)
    }
    
    func set(progress: CGFloat) {
        indicatorNode.set(progress: progress)
    }
    
    func set(offset y: CGFloat) {
        let y = min(y, 0)
        indicatorY = abs(y)
        setNeedsLayout()
    }
}
