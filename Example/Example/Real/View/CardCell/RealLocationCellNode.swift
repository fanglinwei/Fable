//
//  HomeLocationCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealLocationCellNode: RealBaseCellNode {
    
    private lazy var iconImageNode = ASImageNode(image: #imageLiteral(resourceName: "home_card_location"))
    
    // 位置
    private lazy var textNode = ASTextNode(
        "位置",
        color: #colorLiteral(red: 0.3764705882, green: 0.4117647059, blue: 0.4470588235, alpha: 1),
        font: .systemFont(ofSize: 14.auto())
    )
    
    // 定位
    private lazy var locationNode = ASTextNode()
    private let lat: Double
    private let lon: Double
    
    init(_ lat: Double, _ lon: Double) {
        self.lat = lat
        self.lon = lon
        super.init()
    }
    
    // 页面预加载时
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        
        let text = "位置"
        let font = UIFont.systemFont(ofSize: 18.auto(), weight: .light)
        self.locationNode.set(text, color: #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.137254902, alpha: 1), font: font)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.alignItems = .center
        iconImageNode.style.preferredSize = CGSize(width: 13, height: 14).auto()
        
        horizontalStack.spacing = 8.auto()
        horizontalStack.children = [iconImageNode, textNode]
        
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.spacing = 17.auto()
        verticalStack.children = [
            ASInsetLayoutSpec(insets: UIEdgeInsets(25, 25, 0, 0).auto(), child: horizontalStack),
            ASInsetLayoutSpec(insets: UIEdgeInsets(0, 25, 0, 0).auto(), child: locationNode)
        ]
        
        return ASBackgroundLayoutSpec(child: verticalStack, background: contentNode)
    }
}
