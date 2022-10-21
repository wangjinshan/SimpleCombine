//
//  SimpleSubscribers.Assign.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/30.
//

import Foundation

extension SimpleSubscribers {
    public final class Assign<Root, Input>: SimpleSubscriber,
                                            SimpleCancellable,
                                            CustomStringConvertible,
                                            CustomReflectable,
                                            CustomPlaygroundDisplayConvertible {
        
        public typealias Input = Input
        public typealias Failure = Never
        
        private let lock = NSLock()
        
        public private(set) var object: Root?
        public let keyPath: ReferenceWritableKeyPath<Root, Input>
        private var status = SimpleSubscriptionStatus.awaitingSubscription
        
        public var description: String { return "Assign \(Root.self)." }
        
        public var customMirror: Mirror {
            let children: [Mirror.Child] = [
                ("object", object as Any),
                ("keyPath", keyPath),
                ("status", status as Any)
            ]
            return Mirror(self, children: children)
        }
        
        public var playgroundDescription: Any { return description }
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }
        
        public func receive(subscription: SimpleSubscription) {
            lock.lock()
            guard case .awaitingSubscription = status else {
                lock.unlock()
                subscription.cancel()
                return
            }
            status = .subscribed(subscription)
            lock.unlock()
            subscription.request(.unlimited)
        }
        
        // 在接收到消息的时候把Input的值,通过keypath 设置到object里面去
        public func receive(_ input: Input) -> SimpleSubscribers.Demand {
            lock.lock()
            guard case .subscribed = status, let object = self.object else {
                lock.unlock()
                return .none
            }
            lock.unlock()
            object[keyPath: keyPath] = input
            return .none
        }
        
        public func receive(completion: SimpleSubscribers.Completion<Never>) {
            lock.lock()
            guard case .subscribed = status else {
                lock.unlock()
                return
            }
            terminateAndConsumeLock()
        }
        
        public func cancel() {
            lock.lock()
            guard case let .subscribed(subscription) = status else {
                lock.unlock()
                return
            }
            terminateAndConsumeLock()
            subscription.cancel()
        }
        
        private func terminateAndConsumeLock() {
            status = .terminal
            withExtendedLifetime(object) {
                object = nil
                lock.unlock()
            }
        }
    }
}

extension SimplePublisher where Failure == Never {
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> SimpleAnyCancellable {
        let subscriber = SimpleSubscribers.Assign<Root, Output>(object: object, keyPath: keyPath)
        receive(subscriber: subscriber)
        return SimpleAnyCancellable(subscriber)
    }
}
