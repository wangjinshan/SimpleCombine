//
//  CusSubject.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

// 发送数据协议
public protocol SimpleSubject: AnyObject, SimplePublisher {
    func send(_ value: Output)
    func send(completion: SimpleSubscribers.Completion<Failure>)
    func send(subscription: SimpleSubscription)
}
