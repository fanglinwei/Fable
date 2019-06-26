//
//  ViewController.swift
//  Example
//
//  Created by calm on 2019/6/12.
//  Copyright © 2019 calm. All rights reserved.
//

import UIKit
import Fable

class ViewController: UIViewController {

    
    @IBOutlet weak var fableView: FableView!
    
    lazy var dataSource = ArrayDataSource<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()

        dataSource.append(["1111", "222", "3333", "123123", "123123", "LLE", "LEE"])
    }
    
    private func setup()  {
        
        let siewSource = ViewSource { (data: String) -> UIViewController in
            let c = TestController()
            c.set(text: data)
            return c
        }
        
        let action = ActionSource<String>()
        action.swipeThresholdRatioMargin.delegate(on: self) { (self,context) -> CGFloat in
            return 0.5
        }
        
        action.didRunOutOfDatas.delegate(on: self) { (self, context) in
            print("didRunOutOfDatas\(context.data)")
            self.dataSource.append(["杯子", "LLL", "1111", "2222"])
        }
        
        action.didRunOutOfVisibles.delegate(on: self) { (self, context) in
            print("didRunOutOfVisibles")
        }
        
        action.didShowCard.delegate(on: self) { (self, context) in
            print(context.data)
        }
        
        action.willResetCard.delegate(on: self) { (self, context) in
            print("willResetCard\(context.data)")
        }
        
        action.didResetCard.delegate(on: self) { (self, context) in
            print("didResetCard\(context.data)")
        }
        
        action.slideThroughContext.delegate(on: self) { (self, _) -> Any? in
            return "1993"
        }
        
        action.shouldSwipeCard.delegate(on: self) { (self, arg1) -> Bool in
            let (_, _, context) = arg1
            print("shouldSwipeCard\(context ?? "")")
            return true
        }
        
        action.didSwipeCard.delegate(on: self) { (self, arg1) in
            let (_, _, context) = arg1
            print("didSwipeCard\(context ?? "")")
        }
        
        let provider = BasicProvider(dataSource: dataSource, viewSource: siewSource, actionSource: action)
        
        fableView.provider = provider
    }
}

extension ViewController {
    
    @IBAction func sw(_ sender: Any) {
        fableView.swipe(.left)
    }
    @IBAction func sr(_ sender: Any) {
        fableView.swipe(.right)
    }
}

class TestController: UIViewController {
    
    lazy var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.backgroundColor = UIColor.init(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.frame = view.bounds
    }
    
    func set(text: String) {
        label.text = text
    }
    
    deinit { print("deinit:\t\(self.classForCoder)") }
}
