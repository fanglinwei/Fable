//
//  HomeCoverCellNode.swift
//  Social
//
//  Created by calm on 2019/5/21.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealCoverCellNode: RealBaseCellNode {
    
    // 封面图片
    private lazy var coverImageNode = ASCoverImageNode(
        cache: ASKingfisherImageCache.shared,
        downloader: ASKingfisherImageDownloader.shared
    ).then {
        $0.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        $0.contentMode = .scaleAspectFill
        $0.shouldRenderProgressImages = true
    }
    
    // ta超喜欢你
    private lazy var superLikeNode = ASImageNode(image: #imageLiteral(resourceName: "home_card_cover_likeme"))
    
    // 真人认证标签
    private lazy var realCertNode = ASImageNode(image: #imageLiteral(resourceName: "home_card_certification_icon2"))
    
    // 名称
    private lazy var nameNode = ASTextNode().then {
        $0.maximumNumberOfLines = 1
    }
    
    // 年龄
    private lazy var ageNode = ASTextNode()
    
    // 企业职位
    private lazy var companyNode = ASTextNode().then {
        $0.maximumNumberOfLines = 1
    }
    
    // 学校专业
    private lazy var collegeNode = ASTextNode().then {
        $0.maximumNumberOfLines = 1
    }
    
    // 企业认证图标
    private lazy var companyCertNode = ASImageNode(image: #imageLiteral(resourceName: "home_card_certification_icon1"))
    // 学校认证图标
    private lazy var collegeCertNode = ASImageNode(image: #imageLiteral(resourceName: "home_card_certification_icon1"))
    
    private let model: RealCoverCellNode.Model
    
    init(_ model: RealCoverCellNode.Model) {
        self.model = model
        super.init()
    }
    
    override func layout() {
        super.layout()
        contentNode.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.3843137255, blue: 0.8352941176, alpha: 1)
    }
    
    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        
        coverImageNode.url = model.image.toURL()
    }
    
    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        
        // 昵称
        do {
            let font = UIFont.systemFont(ofSize: 33.auto(), weight: .semibold)
            nameNode.set(model.nickname, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), font: font)
            nameNode.lineBreakMode = .byCharWrapping
        }
        
        // 年龄
        do {
            let font = UIFont.systemFont(ofSize: 33.auto(), weight: .medium)
            ageNode.set("," + model.age.string, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), font: font)
        }
        
        if
            let company = model.company,
            let profession = model.profession {
            companyNode.set(
                company + " " + profession,
                color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                font: .systemFont(ofSize: 14.auto())
            )
            companyNode.lineBreakMode = .byCharWrapping
        }
        
        if
            let college = model.college,
            let major = model.major {
            collegeNode.set(
                college + " " + major,
                color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                font: .systemFont(ofSize: 14.auto())
            )
            collegeNode.lineBreakMode = .byCharWrapping
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let size = constrainedSize.max
        
        let infoHeight: CGFloat = 122.auto()
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.style.flexShrink = 1.0
        hStack.spacing = 10.auto()
        
        // 真人认证图标处理
        do{
            var children: [ASLayoutElement] = []
            if model.isRealCert {
                realCertNode.style.preferredSize = CGSize(106, 26).auto()
                children.append(realCertNode)
            }

            if model.isSuperLike {
                superLikeNode.style.preferredSize = CGSize(106, 26).auto()
                children.append(superLikeNode)
            }
            hStack.children = children
        }
        
        let overlay = ASInsetLayoutSpec(insets: UIEdgeInsets(10, 10, .infinity, 10).auto(), child: hStack)
        
        coverImageNode.style.preferredSize = CGSize(size.width, size.height - infoHeight)
        let image = ASOverlayLayoutSpec(child: coverImageNode, overlay: overlay)
        // info
        let infoStack = ASStackLayoutSpec.vertical()
        infoStack.style.preferredSize = CGSize(size.width, infoHeight)
        
        nameNode.style.flexShrink = 1.0
        let nameAndAgeStack = ASStackLayoutSpec.horizontal()
        nameAndAgeStack.style.flexShrink = 1.0
        nameAndAgeStack.spacing = 5.auto()
        nameAndAgeStack.children = [nameNode, ageNode]
        nameAndAgeStack.style.spacingAfter = 14.auto()
        
        var children: [ASLayoutElement] = []
        children.append(nameAndAgeStack)
        
        //企业
        if  !model.company.isNilOrEmpty, !model.profession.isNilOrEmpty  {
            
            let stack = ASStackLayoutSpec.horizontal()
            stack.alignItems = .center
            stack.style.flexShrink = 1.0
            stack.spacing = 8.auto()
            companyNode.style.flexShrink = 1.0
            companyCertNode.isHidden = !model.companyCert
            companyCertNode.style.preferredSize = CGSize(12, 14).auto()
            stack.children = [companyNode]
            if model.companyCert {
                stack.children?.append(companyCertNode)
            }
            stack.style.spacingAfter = 8.auto()
            children.append(stack)
        }
        
        //学校
        if !model.college.isNilOrEmpty, !model.major.isNilOrEmpty  {
            
            let stack = ASStackLayoutSpec.horizontal()
            stack.alignItems = .center
            stack.style.flexShrink = 1.0
            stack.spacing = 8.auto()
            collegeNode.style.flexShrink = 1.0
            collegeCertNode.isHidden = !model.collegeCert
            collegeCertNode.style.preferredSize = CGSize(12, 14).auto()
            stack.children = [collegeNode]
            if model.collegeCert {
                stack.children?.append(collegeCertNode)
            }
            children.append(stack)
        }
        
        infoStack.children = children
        
        let info = ASInsetLayoutSpec(insets: UIEdgeInsets(0, 24, 32, 20).auto(), child: infoStack)
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [image, info]
        return ASBackgroundLayoutSpec(child: vStack, background: contentNode)
    }
}

extension RealCoverCellNode {
    
    struct Model {
        typealias Info = Real.Info
        let image: String
        let nickname: String
        let age: Int
        let isSuperLike: Bool
        let isRealCert: Bool
        
        // 学校
        let college: String?
        let major: String?
        let collegeCert: Bool
        
        // 企业
        let company: String?
        let profession: String?
        let companyCert: Bool
    }
}

extension RealCoverCellNode.Model {
    
    init(with profile: Info) {
        
        self.image = profile.photos?.first?.url ?? ""
        self.nickname = profile.nickname
        self.isSuperLike = profile.like == 2
        self.age = profile.birthday.birthToAge() ?? 0
        self.college = profile.college
        self.major = profile.major
        // 未审核,1待审核,2已审核
        self.collegeCert = profile.collegeCert == 2
        self.company = profile.company
        self.profession = profile.profession
        // 未审核,1待审核,2已审核
        self.companyCert = profile.companyCert == 2
        self.isRealCert = profile.realCert?.bool ?? false
    }
}

private class ASCoverImageNode: ASNetworkImageNode {
    
    private lazy var maskLayer = CAShapeLayer()
    
    override init(cache: ASImageCacheProtocol?, downloader: ASImageDownloaderProtocol) {
        super.init(cache: cache, downloader: downloader)
        DispatchQueue.main.async {
            self.layer.mask = self.maskLayer
        }
    }
    
    override func layout() {
        super.layout()
        addMaskPath()
    }
    
    private func addMaskPath() {
        let maskHeight: CGFloat = 48.auto()
        let radius: CGFloat = 16.auto()
        // 计算左侧外切角
        let leftAngle: CGFloat = atan(bounds.width / maskHeight)
        // 根据数学原理内夹角 = 外切角 左侧
        // 根据三角函数计算左侧切边
        let leftTrimming: CGFloat = tan(leftAngle / 2) * radius
        
        // 右侧角度相关
        // 右侧内夹角
        let rightAngle: CGFloat = .pi - leftAngle
        let rightTrimming: CGFloat = tan(rightAngle / 2) * radius
        
        // 贝塞尔
        let path = UIBezierPath()
        path.move(to: CGPoint(0, 0))
        
        // 圆角1
        do {
            let trimming = leftTrimming
            let point = CGPoint(0, bounds.maxY - maskHeight - trimming)
            path.addLine(to: point)
            let center = CGPoint(radius, point.y)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: .pi,
                        endAngle: .pi - leftAngle,
                        clockwise: false)
        }
        
        // 绘制从左到右的大斜边
        do {
            let angle: CGFloat = .pi / 2 - leftAngle
            let marginY: CGFloat = sin(angle) * radius
            let marginX: CGFloat = cos(angle) * radius
            let point = CGPoint(bounds.maxX - marginX, bounds.maxY - marginY)
            path.addLine(to: point)
        }
        
        // 圆角2
        do {
            let trimming = rightTrimming
            let center = CGPoint(bounds.maxX - radius, bounds.maxY - trimming)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: .pi - leftAngle,
                        endAngle: 0,
                        clockwise: false)
        }
        
        // 右上角
        do {
            let point = CGPoint(bounds.maxX, 0)
            path.addLine(to: point)
        }
        
        path.close()
        maskLayer.path = path.cgPath
    }
}
