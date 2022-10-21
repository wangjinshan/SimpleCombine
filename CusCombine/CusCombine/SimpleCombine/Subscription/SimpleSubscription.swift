//
//  CusSubscription.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

// 定义的契约
public protocol SimpleSubscription: SimpleCancellable, SimpleCombineIdentifierConvertible {
    func request(_ demand: SimpleSubscribers.Demand)
}
