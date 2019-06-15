//
//  Extension.swift
//  Fable
//
//  Created by calm on 2019/6/3.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import UIKit

enum Velocity {}

// MARK: - 向量力度辅助计算函数
extension Velocity {
    
    static func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
    static func relative(forVelocity velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0 else { return 0 }
        return velocity / (targetValue - currentValue)
    }
}

extension UISpringTimingParameters {
    
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}

extension UIView {
    
    @available(iOS 9, *)
    func fillToSuperview() {
        // https://videos.letsbuildthatapp.com/
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            let left = leftAnchor.constraint(equalTo: superview.leftAnchor)
            let right = rightAnchor.constraint(equalTo: superview.rightAnchor)
            let top = topAnchor.constraint(equalTo: superview.topAnchor)
            let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            NSLayoutConstraint.activate([left, right, top, bottom])
        }
    }
}

extension CGAffineTransform {
    
    /*
     仿射矩阵变换
     目标图形以(x, y)为轴心逆时针旋转theta弧度，变换矩阵为：
     [ cos(theta)   -sin(theta)     x-x*cos+y*sin]
     [ sin(theta)   cos(theta)      y-x*sin-y*cos ]
     [ 0             0                  1        ]
     相当于两次平移变换与一次原点旋转变换的复合：
     [1 0 x] [cos(theta) -sin(theta) 0]  [1 0- x]
     [0 1 y] [sin(theta) cos(theta)  0]  [0 1 -y]
     [0 0 1] [ 0          0          1]  [0 0 1]
     这里是以空间任一点为圆心旋转的情况。
     ---------------------
     参考: https://blog.csdn.net/holdsky/article/details/40681155
     */
    /// 围绕视图外一点旋转
    ///
    /// - Parameters:
    ///   - center: 视图中心点
    ///   - point: 原点
    ///   - angle: 旋转角度
    /// - Returns: 新的CGAffineTransform
    static func rotateAroundPoint(center: CGPoint,  dot point: CGPoint, angle: CGFloat) -> CGAffineTransform{
        let x = point.x - center.x //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
        let y = point.y - center.y //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
        let trans = CGAffineTransform(translationX: x, y: y)
            .rotated(by: angle)
            .translatedBy(x: -x, y: -y)
        return trans
    }
}

extension Array {
    
    @discardableResult
    mutating func safeRemoveFirst() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return removeFirst()
    }
    
    mutating func safeRemoveLast() -> Element? {
        guard !isEmpty else {
            return nil
        }
        return removeLast()
    }
}
