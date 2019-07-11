//
//  HomeImageCellNode.swift
//  Social
//
//  Created by calm on 2019/5/22.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RealImageCellNode: RealBaseCellNode {
    
    typealias Photo = Real.Info.Photo
    
    private lazy var photoImageNode = ASNetworkImageNode(
        cache: ASKingfisherImageCache.shared,
        downloader: ASKingfisherImageDownloader.shared
    ).then {
        $0.contentMode = .scaleAspectFill
        $0.shouldRenderProgressImages = true
    }
    
    private let photo: Photo
    init(_ photo: Photo) {
        self.photo = photo
        super.init()
    }
    
    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        photoImageNode.url = photo.url?.toURL()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let ratio = CGFloat(photo.height) / CGFloat(photo.width)
        let child = ASRatioLayoutSpec(ratio: ratio, child: photoImageNode)
        return ASBackgroundLayoutSpec(child: child, background: contentNode)
    }
}
