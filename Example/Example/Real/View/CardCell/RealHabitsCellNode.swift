//
//  HomeHabitsCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealHabitsCellNode: RealBaseCellNode {
    
    private lazy var textNode = ASTextNode()
    private let children: [DesireNode]
    private let title: String
    
    init(_ title: String, items: [String]) {
        self.title = title
        children = items.map { DesireNode($0) }
        super.init()
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        let font = UIFont.systemFont(ofSize: 16.auto())
        textNode.set(title, color: #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.137254902, alpha: 1), font: font)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let v1Stack = ASStackLayoutSpec.vertical()
        v1Stack.spacing = 24.auto()
        
        let v2Stack = ASStackLayoutSpec.vertical()
        v2Stack.spacing = 30.auto()
        v2Stack.children = children
        v1Stack.children = [textNode, v2Stack]
        let child = ASInsetLayoutSpec(insets: UIEdgeInsets(0, 26, 0, 26).auto(),
                                      child: v1Stack)
        return ASBackgroundLayoutSpec(child: child, background: contentNode)
    }
}

// 子视图
private class DesireNode: ASDisplayNode {
    
    // 小黄点
    private lazy var sortNode = ASDisplayNode().then {
        $0.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.2196078431, alpha: 1)
    }
    
    private lazy var textNode = ASTextNode()
    private let title: String
    
    init(_ title: String) {
        self.title = title
        super.init()
        automaticallyManagesSubnodes = true
        textNode.truncationMode = .byTruncatingTail
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        let font = UIFont.systemFont(ofSize: 16.auto())
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.auto();
        
        textNode.attributedText = title
            .colored(with: #colorLiteral(red: 0.1843137255, green: 0.3450980392, blue: 0.7764705882, alpha: 1))
            .applying([.font : font])
            .applying([.paragraphStyle : paragraphStyle])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        sortNode.style.preferredSize = CGSize(4, 4).auto()
        sortNode.style.layoutPosition = CGPoint(0, 8).auto()
        textNode.style.flexShrink = 1
        
        let sort = ASAbsoluteLayoutSpec(children: [sortNode])
        let stack =  ASStackLayoutSpec.horizontal()
        stack.spacing = 6.auto()
        stack.children = [sort, textNode]
        return stack
    }
}


