//
//  ASTextNode+Extension.swift
//  Social
//
//  Created by calm on 2019/6/19.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import AsyncDisplayKit

extension ASTextNode {
    
    var lineBreakMode: NSLineBreakMode {
        set {
            let _attributedText = attributedText
            let paragraphStyle = _attributedText?.attribute(.paragraphStyle,
                                                  at: 0,
                                                  effectiveRange: nil) as? NSMutableParagraphStyle
            
            let style = paragraphStyle ?? NSMutableParagraphStyle()
            style.lineBreakMode = newValue
            attributedText = _attributedText?.applying([.paragraphStyle : style])
        }
        get {
            let style = attributedText?.attribute(.paragraphStyle,
                                                  at: 0,
                                                  effectiveRange: nil) as? NSParagraphStyle
            return style?.lineBreakMode ?? .byWordWrapping
        }
    }
    
    convenience init(_ text: String, color: UIColor, font: UIFont) {
        self.init()
        attributedText = text
            .colored(with: color)
            .applying([.font : font])
    }
    
    func set(_ text: String?, color: UIColor, font: UIFont) {
        attributedText = text?
            .colored(with: color)
            .applying([.font : font])
    }
}
