//
//  CusSubscriber.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

// 接收者协议
public protocol SimpleSubscriber: SimpleCombineIdentifierConvertible {
    
    associatedtype Input
    associatedtype Failure: Error
    
    func receive(subscription: SimpleSubscription)
    
    func receive(_ input: Input) -> SimpleSubscribers.Demand
    
    func receive(completion: SimpleSubscribers.Completion<Failure>)
}

extension SimpleSubscriber where Input == Void {

    public func receive() -> SimpleSubscribers.Demand {
        return receive(())
    }
}
