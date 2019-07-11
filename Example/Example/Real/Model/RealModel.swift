//
//  HomeModel.swift
//  Social
//
//  Created by calm on 2019/6/26.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit
import Fable

protocol RealModelDelegate: NSObjectProtocol {
    func viewLoading()
    func backgroundView(_ isHidden: Bool)
}

class RealModel: NSObject {
    
    typealias Info = Real.Info
    enum Card {
        case info(Info)
        case other
        
        var shouldDrag: Bool {
            switch self {
            case .info:         return true
            case .other:        return true
            }
        }
    }
    
    weak var delegate: RealModelDelegate?
    
    // 数据源
    lazy var dataSource = ArrayDataSource<Card>(visibleSize: 2, recycleSize: 2)
}

extension RealModel {
    
    // 加载数据
    func loadData() {
        delegate?.viewLoading()
        // 加载卡片数据
        API.load(.real) { [weak self] (result: API.Result<[Info]>) in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                let cards = value.map { Card.info($0) }
                self.dataSource.append(cards)
                self.delegate?.backgroundView(true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // 发起滑动请求
    func swiped(_ feel: Real.Feel, id: Int64) {
        print("滑动卡片")
    }
}

