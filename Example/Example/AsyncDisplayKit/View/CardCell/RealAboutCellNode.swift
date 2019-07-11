//
//  RealAboutCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealAboutCellNode: RealBaseCellNode {
    
    // 位置
    private lazy var textNode = ASTextNode(
        "关于我",
        color: #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.137254902, alpha: 1),
        font: .systemFont(ofSize: 16.auto())
    )
    
    private let tagsNodes: [TagNode]
    
    init(_ tags: [String]) {
        tagsNodes = tags.map { TagNode($0) }
        super.init()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
        let stack = ASStackLayoutSpec.vertical()
        stack.spacing = 26.auto()
        
        let tagStack = ASStackLayoutSpec.horizontal()
        tagStack.style.flexShrink = 1
        tagStack.spacing = 10.auto()
        tagStack.lineSpacing = 16.auto()
        tagStack.flexWrap = .wrap
        tagStack.children = tagsNodes
        
        stack.children = [textNode, tagStack]
        let child = ASInsetLayoutSpec(insets: UIEdgeInsets(0, 26, 0, 26), child: stack)
        return ASBackgroundLayoutSpec(child: child, background: contentNode)
    }
}

// 标签节点
class TagNode: ASCellNode {
    
    //名称
    private lazy var textNode = ASTextNode()
    private let string: String
    
    init(_ string: String) {
        self.string = string
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func layout() {
        super.layout()
        
        backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9529411765, blue: 1, alpha: 1)
        cornerRadius = 17.auto()
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        
        let font = UIFont.systemFont(ofSize: 14.auto(), weight: .light)
        textNode.attributedText = string.colored(with: #colorLiteral(red: 0.1843137255, green: 0.3450980392, blue: 0.7764705882, alpha: 1)).applying([.font : font])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(7, 21, 7, 21).auto(), child: textNode)
    }
}
