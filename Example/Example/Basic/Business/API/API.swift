//
//  API.swift
//  Example
//
//  Created by calm on 2019/7/11.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

/// 模拟网络请求
enum API {}
extension API {
    typealias Result<T> = Swift.Result<T, API.Error>
    struct Null: Codable {}
}

extension API {
    
    public enum Error: Swift.Error {
        /// 请求类型失败 (请求失败)
        case asset
        /// 映射类型失败 (请求成功 解析映射时)
        case mapping
        
        public var localizedDescription: String {
            switch self {
            case .asset:        return "找不到数据文件"
            case .mapping:      return "映射类型失败"
            }
        }
    }
}

extension API {
    
    enum Asset: String {
        case real
    }
    
    static func load<T: Decodable>(_ asset: Asset,
                            completion: @escaping ((API.Result<T>) -> Void)){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let asset = NSDataAsset(name: asset.rawValue) else {
                completion(.failure(.asset))
                return
            }
            
            do {
                let data = try JSONDecoder().decode(T.self, from: asset.data)
                completion(.success(data))
            } catch {
                completion(.failure(.mapping))
            }
        }
    }
}
