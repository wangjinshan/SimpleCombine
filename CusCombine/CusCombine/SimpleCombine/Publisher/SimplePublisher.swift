//
//  CusPublisher.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

// 发布者协议
public protocol SimplePublisher {

    associatedtype Output
    associatedtype Failure: Error
    // 接收订阅者
    func receive<Subscriber: SimpleSubscriber>(subscriber: Subscriber)
        where Failure == Subscriber.Failure, Output == Subscriber.Input
}

// 发布者需要的订阅能力
extension SimplePublisher {
    public func subscribe<Subscriber: SimpleSubscriber>(_ subscriber: Subscriber)
        where Failure == Subscriber.Failure, Output == Subscriber.Input {
        receive(subscriber: subscriber)
    }
}

