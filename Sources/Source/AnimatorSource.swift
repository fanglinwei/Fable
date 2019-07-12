//
//  AnimatorSource.swift
//  Fable
//
//  Created by calm on 2019/7/12.
//  Copyright © 2019 calm. All rights reserved.
//

import Foundation

public typealias AnimatorGeneratorFn = () -> Animator
public class AnimatorSource {
    public var animatorGeneratorFn: AnimatorGeneratorFn
    
    public init(animatorGeneratorFn: @escaping AnimatorGeneratorFn) {
        self.animatorGeneratorFn = animatorGeneratorFn
    }
    
    public static let angleAnimator = AnimatorSource { () -> AngleAnimator in
        return AngleAnimator()
    }
}
