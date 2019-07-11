//
//  Home.swift
//  Social
//
//  Created by calm on 2019/5/23.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import Foundation

enum Real {
    
    // 感觉
    enum Feel {
        case skip(isSlide: Bool)
        case like(isSlide: Bool)
        case love
    }
    
    struct Info: Codable {
        
        let id: Int64                             // ID
        let avatar: String?                       // 头像
        let nickname: String                      // 昵称
        let birthday: String                      // 生日
        let hometown: Int?                        // 家乡
        let residence: Int?                       // 居住地
        let college: String?                      // 大学
        let major: String?                        // 专业
        let collegeCert: Int?                     // 大学认证  0未审核,1待审核,2已审核
        let company: String?                      // 公司
        let profession: String?                   // 职位
        let companyCert: Int?                     // 公司认证  0未审核,1待审核,2已审核
        let intro: String?                        // 自我描述
        let height: Int?                          // 身高
        let realCert: Int?                        // 真人认证 0未认证 1认证
        
        let photos: [Photo]?                      // 相片
        let tags: [String]?                       // 标签
        let habits: [Content]?                    // 我的日常
        let wishes: [Content]?                    // 喜欢什么样的TA
        let qa: [QA]?                             // 我的问答
        
        let lon: Double?              // 经度
        let lat: Double?              // 纬度
        let like: Int                 // 是否喜欢，0为未评价，1为喜欢，2为超喜欢
    }
}

extension Real.Info {
    
    struct QA: Codable, Equatable {
        let id: Int?
        let q: String
        let a: String
    }
    
    struct Content: Codable, Equatable {
        let id: Int
        let content: String
    }
    
    struct Photo: Codable {
        let url: String?
        let width: Int
        let height: Int
    }
}
