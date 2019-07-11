//
//  RealReportCellNode.swift
//  Social
//
//  Created by calm on 2019/7/4.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol RealReportCellNodeDelegate: NSObjectProtocol {
    /// 举报/拉黑
    func reportAction()
}

class RealReportCellNode: RealBaseCellNode {
    
    weak var delegate: RealReportCellNodeDelegate?
    
    /// 举报/拉黑
    private lazy var reportButtonNode = ASButtonNode().then {
        let font = UIFont.systemFont(ofSize: 14.auto(), weight: .thin)
        $0.setTitle("举报 / 拉黑", with: font, with: #colorLiteral(red: 0.3764705882, green: 0.4117647059, blue: 0.4470588235, alpha: 1), for: .normal)
        $0.addTarget(self, action: #selector(reportAction), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: reportButtonNode, background: contentNode)
    }
    
    @objc
    private func reportAction(_ sender: Any) {
        delegate?.reportAction()
    }
}

