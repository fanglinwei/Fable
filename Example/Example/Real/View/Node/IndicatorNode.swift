//
//  IndicatorNode.swift
//  Social
//
//  Created by calm on 2019/6/18.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import AsyncDisplayKit

class IndicatorNode: ASDisplayNode {
    
    lazy var barNode = ASDisplayNode().then {
        $0.backgroundColor = .white
    }
    
    var top: CGFloat = 0
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        barNode.cornerRadius = 2.auto()
        cornerRadius = 2.auto()
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04)
    }
    
    
    func set(progress: CGFloat) {
        let progress = limit(progress, 0...1)
        let height = bounds.height
        let barHeight = barNode.bounds.height
        let distance = height - barHeight
        top = distance * progress
        setNeedsLayout()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        barNode.style.preferredSize = CGSize(4, 28).auto()
        barNode.style.layoutPosition = CGPoint(0, top)
        return ASAbsoluteLayoutSpec(children: [barNode])
    }
}
