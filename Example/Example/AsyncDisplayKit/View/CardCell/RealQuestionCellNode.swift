//
//  RealQuestionCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealQuestionCellNode: RealBaseCellNode {
    
    typealias QA = Real.Info.QA
    
    private let children: [QuestionNode]
    
    init(_ qas: [QA]) {
        children = qas.map { QuestionNode($0.q, answer: $0.a) }
        super.init()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let vStack = ASStackLayoutSpec.vertical()
        vStack.spacing = 40.auto()
        vStack.children = children
        let child = ASInsetLayoutSpec(insets: UIEdgeInsets(0, 26, 0, 26).auto(),
                                      child: vStack)
        
        return ASBackgroundLayoutSpec(child: child, background: contentNode)
    }
}

// 问答视图
private class QuestionNode: ASDisplayNode {
    
    private lazy var questionNode = ASTextNode()
    private lazy var answerNode = ASTextNode()

    private let question: String
    private let answer: String
    
    init(_ question: String, answer: String) {
        self.question = question
        self.answer = answer
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        
        do{
            let font = UIFont.systemFont(ofSize: 15.auto(), weight: .light)
            questionNode.set(question, color: #colorLiteral(red: 0.3764705882, green: 0.4117647059, blue: 0.4470588235, alpha: 1), font: font)
        }
        
        do {
            let font = UIFont.systemFont(ofSize: 16.auto())
            answerNode.set(answer, color: #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.137254902, alpha: 1), font: font)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.alignItems = .baselineFirst
        vStack.spacing = 21.auto()
        vStack.children = [questionNode, answerNode]
        return vStack
    }
}
