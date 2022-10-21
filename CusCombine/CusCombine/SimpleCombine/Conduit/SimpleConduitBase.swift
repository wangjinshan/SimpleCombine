//
//  SimpleConduitBase.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

internal protocol HasDefaultValue {
    init()
}

extension HasDefaultValue {

    @inline(__always)
    internal mutating func take() -> Self {
        let taken = self
        self = .init()
        return taken
    }
}

extension Array: HasDefaultValue {}

extension Dictionary: HasDefaultValue {}

extension Optional: HasDefaultValue {
    init() {
        self = nil
    }
}

// MARK: - Base
internal class ConduitBase<Output, Failure: Error>: SimpleSubscription {
    
    internal func request(_ demand: SimpleSubscribers.Demand) { }
    
    internal init() {}

    internal func offer(_ output: Output) {}

    internal func finish(completion: SimpleSubscribers.Completion<Failure>) {}

    internal func cancel() {}
}

// MARK: - 内部使用的集合
extension ConduitBase: Equatable {
    internal static func == (lhs: ConduitBase<Output, Failure>,
                             rhs: ConduitBase<Output, Failure>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension ConduitBase: Hashable {
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

internal enum ConduitList<Output, Failure: Error> {
    case empty
    case single(ConduitBase<Output, Failure>)
    case many(Set<ConduitBase<Output, Failure>>)
}

extension ConduitList: HasDefaultValue {
    init() {
        self = .empty
    }
}

extension ConduitList {
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

