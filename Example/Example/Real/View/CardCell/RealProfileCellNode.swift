//
//  HomeProfileCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealProfileCellNode: RealBaseCellNode {
    
    struct Model {
        
        typealias Info = Real.Info
        
        let signature: String?
        let infos: [String]
    }
    
    // 逗号
    private lazy var douhaoImageNode = ASImageNode(image: #imageLiteral(resourceName: "home_card_profile_douhao"))
    //个性签名
    private lazy var infoTextNode = ASTextNode()
    
    private let model: Model
    private let tagsNodes: [TagNode]
    
    init(_ model: Model) {
        self.model = model
        tagsNodes = model.infos.map { TagNode($0) }
        super.init()
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        
        let font = UIFont.systemFont(ofSize: 17.auto())
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.auto()
        
        infoTextNode.attributedText = model.signature?
            .colored(with: #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.137254902, alpha: 1))
            .applying([.font : font])
            .applying([.paragraphStyle : paragraphStyle])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        douhaoImageNode.style.preferredSize = CGSize(43, 27).auto()
        douhaoImageNode.style.spacingAfter = 27.auto()
        
        var children: [ASLayoutElement] = []
        children.append(douhaoImageNode)
        
        if !model.signature.isNilOrEmpty {
            children.append(infoTextNode)
            infoTextNode.style.spacingAfter = 24.auto()
        }
        
        let tagStack = ASStackLayoutSpec.horizontal()
        tagStack.style.flexShrink = 1
        tagStack.spacing = 10.auto()
        tagStack.lineSpacing = 16.auto()
        tagStack.flexWrap = .wrap
        tagStack.children = tagsNodes
        children.append(tagStack)
        
        let stack = ASStackLayoutSpec.vertical()
        stack.children = children
        let child = ASInsetLayoutSpec(insets: UIEdgeInsets(36, 26, 0, 26).auto(), child: stack)
        return ASBackgroundLayoutSpec(child: child, background: contentNode)
    }
}

extension RealProfileCellNode.Model {
    
    init(with profile: Info) {
        var infos: [String] = []
        
        if let height = profile.height.nonZero {
            infos.append("\(height)cm")                 //身高
        }
        infos.append("星座")
        let name1 = "湖北 武汉"
        infos.append("家乡 \(name1)")          // 家乡
        let name2 = "北京 朝阳"                 // 现居地
        infos.append("现居地 \(name2)")
        
        self.signature = profile.intro
        self.infos = infos
    }
}
