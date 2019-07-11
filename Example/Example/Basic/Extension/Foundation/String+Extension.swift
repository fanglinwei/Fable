//
//  String+Extension.swift
//  LiveTrivia
//
//  Created by Gesen on 2017/11/19.
//  Copyright © 2017年 LiveTrivia. All rights reserved.
//

import Foundation
import Kingfisher

extension String: Resource {
    
    public var cacheKey: String { return self }
    public var downloadURL: URL { return URL(string: self) ?? URL(string: "https://www.abc.com")! }
}

extension String {
    
    func contains(find: String) -> Bool {
        return range(of: find) != nil
    }
    
    func toURL() -> URL? {
        return URL(string: self)
    }

    func toAttr(_ attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    /// string转attributedString，主要用于label计算高度时候
    func set(lineSpacing: CGFloat,
             alignment: NSTextAlignment = .left,
             lineBreakMode: NSLineBreakMode = .byTruncatingTail
        ) -> NSMutableAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = lineSpacing //大小调整
        paragraphStyle.lineBreakMode = lineBreakMode
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSMakeRange(0, count))
        return attributedString
    }
}

extension String {
    
    func birthToAge(_ dateFormat: String = "yyyy-MM-dd") -> Int? {
        guard let date = date(withFormat: dateFormat) else {
            return nil
        }
        return Date().year - date.year
    }
}

extension String {
    
    func decode<T: Decodable>() throws -> T {
        guard let data = data(using: .utf8) else {
            throw NSError(domain: "数据错误", code: 0)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension Optional where Wrapped == String {
    
    var count: Int {
        return self?.count ?? 0
    }
}
