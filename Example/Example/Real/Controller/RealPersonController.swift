
//
//  RealPersonController.swift
//  Social
//
//  Created by calm on 2019/5/21.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol RealPersonViewControllerDelegate: RealMenuCellNodeDelegate {
}

class RealPersonController: ASViewController<RealPersonNode> {
    typealias Info  = Real.Info
    private typealias Photo = Info.Photo
    private typealias Cover = RealCoverCellNode.Model
    private typealias Profile = RealProfileCellNode.Model
    private typealias QA = RealQuestionCellNode.QA
    
    weak var delegate: RealPersonViewControllerDelegate?
    /// 是否边缘回弹
    var bounces: Bool {
        get { return node.bounces }
        set { node.bounces = newValue }
    }
    
    private var datas: [Style] = []
    private let info: Info
    
    private var tableNode: ASTableNode {
        return node.tableNode
    }
    
    init(_ info: Info) {
        self.info = info
        super.init(node: RealPersonNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupAnalyzeProfile()
    }
}

extension RealPersonController {
    
    private func setup()  {
        tableNode.dataSource = self
        tableNode.delegate = self
    }
    
    // 组装数据
    private func setupAnalyzeProfile() {
        
        let info = self.info
        var photos = info.photos ?? []
        
        DispatchQueue.global().async {
            var datas: [Style] = []
            
            // 添加合理性间距
            let addWiseSpace = {
                guard !(datas.last?.isSpace ?? false) else {
                    return
                }
                datas.append(.space60)
            }
            
            // 封面
            do {
                let model = Cover(with: info)
                datas.append(.cover(model))
                photos.safeRemoveFirst()
            }
            
            // 简介
            do {
                let model = Profile(with: info)
                datas.append(.profile(model))
                datas.append(.space60)
            }
            
            // 关于我
            if let tags = info.tags.nonEmpty {
                datas.append(.about(tags))
                datas.append(.space60)
            }
            
            // 图片
            if let photo = photos.safeRemoveFirst() {
                datas.append(.image(photo))
            }
            
            // 我的日常
            if let habits = info.habits.nonEmpty {
                addWiseSpace()
                datas.append(.habits(title: "我的日常",
                                     items: habits.map { $0.content }))
                datas.append(.space60)
            }
            
            // 图片
            if let photo = photos.safeRemoveFirst() {
                datas.append(.image(photo))
            }
            
            // 喜欢什么样的TA
            if let wishes = info.wishes.nonEmpty {
                addWiseSpace()
                datas.append(.habits(title: "喜欢什么样的TA",
                                     items: wishes.map { $0.content }))
                datas.append(.space60)
            }
            
            // 图片
            if let photo = photos.safeRemoveFirst() {
                datas.append(.image(photo))
            }
            
            // 问题
            if let qa = info.qa.nonEmpty {
                addWiseSpace()
                datas.append(.qa(qa))
                datas.append(.space60)
            }
            
            // 剩余图片
            if !photos.isEmpty {
                let temps: [Style] = photos.map { .image($0) }
                datas.append(contentsOf: temps)
            }
            
            // 定位
            if
                let latitude = info.lat.nonZero,
                let longitude = info.lon.nonZero {
                datas.append(.location(lat: latitude, lon: longitude))
                datas.append(.space60)
            }
            
            //菜单/举报
            datas.append(.menu)
            datas.append(.space(42.auto()))
            datas.append(.report)
            datas.append(.space60)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.datas = datas
                self.tableNode.reloadData()
            }
        }
    }
}

extension RealPersonController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

        let nodeBlock: ASCellNodeBlock = { [weak self] in
            guard let self = self else { return ASCellNode() }
            
            switch self.datas[indexPath.row] {
            case .cover(let cover):
                return RealCoverCellNode(cover)
                
            case .profile(let profile):
                return RealProfileCellNode(profile)
                
            case .image(let image):
                return RealImageCellNode(image)
      
            case .about(let tags):
                return RealAboutCellNode(tags)
                
            case .qa(let qa):
                return RealQuestionCellNode(qa)
                
            case let .habits(title, items):
                return RealHabitsCellNode(title, items: items)
                
            case let .location(lat, lon):
                return RealLocationCellNode(lat, lon)
                
            case .menu:
                let _node = RealMenuCellNode()
                _node.delegate = self
                return _node
                
            case .report:
                let _node = RealReportCellNode()
                _node.delegate = self
                return _node
                
            case .space(let value):
                return RealSpaceCellNode(value)
            }
        }
        return nodeBlock
    }
}

extension RealPersonController: ASTableDelegate {
    
    // 设置cell最大size
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        guard case .cover = datas[indexPath.row] else {
            return ASSizeRange(min: CGSize.zero, max: CGSize(CGFloat.infinity, CGFloat.infinity))
        }
        
        return ASSizeRange(min: CGSize.zero, max: tableNode.calculatedSize)
    }
}

extension RealPersonController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 计算滚动指示器百分比
        let y = scrollView.contentOffset.y
        node.set(offset: y)
        
        let gap = scrollView.contentSize.height - scrollView.height
        if gap > 0 {
            node.set(progress: y / gap)
        }
    }
}

extension RealPersonController: RealMenuCellNodeDelegate {
    
    func skipAction() {
        delegate?.skipAction()
    }
    
    func likeAction() {
        delegate?.likeAction()
    }
    
    func loveAction() {
        delegate?.loveAction()
    }
}

extension RealPersonController: RealReportCellNodeDelegate {
    
    func reportAction() {
        Toast.show(top: "举报")
    }
}

extension RealPersonController {
    
    /// 样式
    ///
    /// - cover: 封面
    /// - image: 图片
    /// - profile: 个人简介
    /// - about: 关于我
    /// - habits: 日常/喜欢什么样的Ta
    /// - qa: 问答
    /// - location: 定位
    /// - menu: 菜单
    /// - report: 举报/拉黑
    /// - space: 间距
    private enum Style {
        
        case cover(Cover)
        case image(Photo)
        case profile(Profile)
        case about([String])
        case habits(title: String, items: [String])
        case qa([QA])
        case location(lat: Double, lon: Double)
        case menu
        case report
        case space(CGFloat)
        
        var isSpace: Bool {
            switch self {
            case .space:       return true
            default:           return false
            }
        }
        
        // 便捷60间距
        static let space60: Style = .space(60.auto())
    }
}
