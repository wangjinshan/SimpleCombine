//
//  CusAnyCancellable.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

public class SimpleAnyCancellable: SimpleCancellable, Hashable {
    
    private var _cancel: (() -> Void)?

    public init(_ cancel: @escaping () -> Void) {
        _cancel = cancel
    }

    public init<OtherCancellable: SimpleCancellable>(_ canceller: OtherCancellable) {
        _cancel = canceller.cancel
    }

    public func cancel() {
        _cancel?()
        _cancel = nil
    }

    public static func == (lhs: SimpleAnyCancellable, rhs: SimpleAnyCancellable) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    deinit {
        _cancel?()
    }
}

extension SimpleAnyCancellable {

    public func store<Cancellables: RangeReplaceableCollection>(in collection: inout Cancellables) where Cancellables.Element == SimpleAnyCancellable {
        collection.append(self)
    }

    public func store(in set: inout Set<SimpleAnyCancellable>) {
        set.insert(self)
    }
}
