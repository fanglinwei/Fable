//
//  Toast.swift
//  Example
//
//  Created by calm on 2019/7/11.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation
import SwiftMessages

enum Toast { }

extension Toast {
    
    private static let messages = SwiftMessages()
    private static var workItem: DispatchWorkItem?
    
    /// 显示顶部消息
    ///
    /// - Parameter msg: 消息内容
    static func show(top msg: String, at background: Background = .success) {
        _show(msg, background.color)
    }
}

extension Toast {
    
    enum Background {
        case success
        case failure
        
        var color: UIColor {
            switch self {
            case .success:      return #colorLiteral(red: 0.07843137255, green: 0.7803921569, blue: 0.8705882353, alpha: 1)
            case .failure:      return #colorLiteral(red: 1, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
            }
        }
    }
}

extension Toast {
    
    private static func _show(_ msg: String, _ background: UIColor) {
        guard !msg.isEmpty else { return }
        
        if let current: MessageView = messages.current() {
            current.configureContent(title: "", body: msg)
            current.configureTheme(
                backgroundColor: background,
                foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            )
            
        } else {
            let view = MessageView.viewFromNib(layout: .messageView)
            view.configureContent(title: "", body: msg)
            view.configureTheme(
                backgroundColor: background,
                foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            )
            view.button?.isHidden = true
            var config = SwiftMessages.defaultConfig
            config.shouldAutorotate = false
            config.duration = .forever
            config.preferredStatusBarStyle = .lightContent
            config.presentationContext = .window(windowLevel: .normal)
            messages.show(config: config, view: view)
        }
        
        workItem?.cancel()
        let item = DispatchWorkItem {
            messages.hideAll()
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: item)
    }
}
