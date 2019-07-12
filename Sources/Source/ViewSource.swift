//
//  ViewSource.swift
//  Fable
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

public typealias ViewGeneratorFn<Data, View> = (Data) -> View

public class ViewSource<Data, View: FableCardable> {
    public var viewGenerator: ViewGeneratorFn<Data, View>

    public init(viewGenerator: @escaping ViewGeneratorFn<Data, View>) {
        self.viewGenerator = viewGenerator
    }

    public func view(data: Data) -> View {
        return viewGenerator(data)
    }
}
