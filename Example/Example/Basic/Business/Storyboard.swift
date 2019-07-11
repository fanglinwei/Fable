//
//  Storyboard.swift
//  Example
//
//  Created by calm on 2019/7/11.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit

enum StoryBoard: String {
    case real               = "Real"
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }
    
    func instance<T>() -> T {
        return storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}
