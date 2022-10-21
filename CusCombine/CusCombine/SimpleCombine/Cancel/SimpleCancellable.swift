//
//  CusCancellable.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

// 订阅内存管理
public protocol SimpleCancellable {
    func cancel()
}

extension SimpleCancellable {

    public func store<Cancellables: RangeReplaceableCollection>(in collection: inout Cancellables) where Cancellables.Element == SimpleAnyCancellable {
        SimpleAnyCancellable(self).store(in: &collection)
    }

    public func store(in set: inout Set<SimpleAnyCancellable>) {
        SimpleAnyCancellable(self).store(in: &set)
    }
}
