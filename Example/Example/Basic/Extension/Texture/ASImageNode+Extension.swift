//
//  ASImageNode+Extension.swift
//  Social
//
//  Created by calm on 2019/6/19.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import AsyncDisplayKit

extension ASImageNode {
    
    convenience init(image: UIImage?) {
        self.init()
        self.image = image
    }
}
