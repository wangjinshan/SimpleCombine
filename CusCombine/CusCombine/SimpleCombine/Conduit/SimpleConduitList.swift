//
//  SimpleConduitList.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

internal enum SimpleConduitList<Output, Failure: Error> {
    case empty
    case single(ConduitBase<Output, Failure>)
    case many(Set<ConduitBase<Output, Failure>>)
}

extension SimpleConduitList: HasDefaultValue {
    init() {
        self = .empty
    }
}

extension SimpleConduitList {
    internal mutating func insert(_ conduit: ConduitBase<Output, Failure>) {
        switch self {
        case .empty:
            self = .single(conduit)
        case .single(conduit):
            break // This element already exists.
        case .single(let existingConduit):
            self = .many([existingConduit, conduit])
        case .many(var set):
            set.insert(conduit)
            self = .many(set)
        }
    }

    internal func forEach(
        _ body: (ConduitBase<Output, Failure>) throws -> Void
    ) rethrows {
        switch self {
        case .empty:
            break
        case .single(let conduit):
            try body(conduit)
        case .many(let set):
            try set.forEach(body)
        }
    }

    internal mutating func remove(_ conduit: ConduitBase<Output, Failure>) {
        switch self {
        case .single(conduit):
            self = .empty
        case .empty, .single:
            break
        case .many(var set):
            set.remove(conduit)
            self = .many(set)
        }
    }
}
