//
//  Speed.swift
//  Fable
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

public enum Speed {
    case `default`
    case slow
    case moderate
    case fast
    case custom(TimeInterval)
    
    var value: TimeInterval {
        switch self {
        case .default: return 0.8
        case .fast: return 0.4
        case .moderate: return 1.5
        case .slow: return 2.0
        case .custom(let value): return value
        }
    }
}
