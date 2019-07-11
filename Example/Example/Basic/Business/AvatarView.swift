//
//  AvatarView.swift
//  Social
//
//  Created by 李响 on 2019/3/14.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import Foundation
import UIKit

class AvatarView: UIView {
    
    enum BorderStyle {
        /// 颜色边框
        case color(UIColor)
        /// 图片边框
        case image(UIImage)
    }
    
    enum BorderSpace {
        /// 倍数 (相较于整体宽高的倍数 0 - 1.0)
        case multiple(Float)
        /// 常数 (固定间隔宽度)
        case constant(Float)
    }
    
    private var circleImage = CircleImageView()
    private var peopleImage = CircleImageView()
    
    private var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        setupLayout()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(circleImage)
        addSubview(peopleImage)
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapAction)
        )
        addGestureRecognizer(tap)
    }
    
    private func setupLayout() {
        
        circleImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        peopleImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }
    }
    
    private func set(style: BorderStyle) {
        switch style {
        case .color(let color):
            circleImage.image = nil
            circleImage.backgroundColor = color
        case .image(let image):
            circleImage.image = image
            circleImage.backgroundColor = .clear
        }
    }
    
    private func set(space: BorderSpace) {
        switch space {
        case .multiple(let n):
            peopleImage.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalToSuperview().multipliedBy(1.0 - n * 2)
            }
        case .constant(let n):
            peopleImage.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalToSuperview().inset(n)
            }
        }
        layoutIfNeeded()
    }
    
    @objc private func tapAction() {
        action?()
    }
}

extension AvatarView {
    
    /// 设置
    ///
    /// - Parameters:
    ///   - url: 头像URL字符串
    ///   - style: 边框样式
    ///   - space: 边框间距
    public func set(_ url: String?,
                    placeholder: UIImage? = .none,
                    style: BorderStyle = .color(.white),
                    space: BorderSpace = .multiple(0.05)) {
        set(style: style)
        set(space: space)
        peopleImage.kf.setImage(with: url, placeholder: placeholder)
    }
    
    /// 设置
    ///
    /// - Parameters:
    ///   - image: 头像图片
    ///   - style: 边框样式
    ///   - space: 边框间距
    public func set(_ image: UIImage,
                    style: BorderStyle = .color(.white),
                    space: BorderSpace = .multiple(0.05)) {
        set(style: style)
        set(space: space)
        peopleImage.image = image
    }
    
    /// 设置
    ///
    /// - Parameter action: 点击事件
    public func set(_ action: @escaping (() -> Void)) {
        self.action = action
    }
}

extension AvatarView {
    
    private class CircleImageView: UIImageView {
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            cornerRadius = bounds.width / 2
        }
    }
}
