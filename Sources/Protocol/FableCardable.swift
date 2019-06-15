//
//  FableCardable.swift
//  Fable
//
//  Created by calm on 2019/6/4.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import Foundation

public typealias FableCard = FableCardable

public protocol FableCardable: class {
    
    var _content: UIView { get }
    func removeFromSuper()
}

extension UIView: FableCardable {}
extension UIViewController: FableCardable {}

extension FableCardable where Self: UIView {
    public var _content: UIView {
        return self
    }
    
    public func removeFromSuper() {
        removeFromSuperview()
    }
}

extension FableCardable where Self: UIViewController {
    
    public var _content: UIView {
        return view
    }
    
    public func removeFromSuper() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
