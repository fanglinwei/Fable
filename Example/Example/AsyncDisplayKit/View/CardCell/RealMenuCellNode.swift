//
//  HomeMenuCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol RealMenuCellNodeDelegate: NSObjectProtocol {
    /// 跳过
    func skipAction()
    /// 喜欢
    func likeAction()
    /// 超喜欢
    func loveAction()
}

class RealMenuCellNode: RealBaseCellNode {
    
    weak var delegate: RealMenuCellNodeDelegate?
    
    private lazy var loveButtonNode = ASButtonNode().then {
        $0.setImage(#imageLiteral(resourceName: "home_card_love"), for: .normal)
        $0.addTarget(self, action: #selector(loveAction), forControlEvents: .touchUpInside)
    }
    private lazy var skipButtonNode = ASButtonNode().then {
        $0.setImage(#imageLiteral(resourceName: "home_card_skip"), for: .normal)
        $0.addTarget(self, action: #selector(skipAction), forControlEvents: .touchUpInside)
    }
    
    private lazy var likeButtonNode = ASButtonNode().then {
        $0.setImage(#imageLiteral(resourceName: "home_card_like"), for: .normal)
        $0.addTarget(self, action: #selector(likeAction), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let size = CGSize(70, 70).auto()
        loveButtonNode.style.preferredSize = size
        skipButtonNode.style.preferredSize = size
        likeButtonNode.style.preferredSize = size
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.alignItems = .center
        
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.alignItems = .center
        hStack.spacing = 102.auto()
        hStack.children = [skipButtonNode, likeButtonNode]
        
        vStack.children = [
            loveButtonNode,
            hStack
        ]
        
        return ASBackgroundLayoutSpec(child: vStack, background: contentNode)
    }
    
    @objc
    private func skipAction(_ sender: Any) {
        delegate?.skipAction()
    }
    
    @objc
    private func likeAction(_ sender: Any) {
        delegate?.likeAction()
    }
    
    @objc
    private func loveAction(_ sender: Any) {
        delegate?.loveAction()
    }
}
