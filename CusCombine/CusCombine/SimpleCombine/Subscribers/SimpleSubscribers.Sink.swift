//
//  SimpleSubscribers.Sink.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

extension SimpleSubscribers {

    public final class Sink<Input, Failure: Error>
        : SimpleSubscriber,
          SimpleCancellable,
          CustomStringConvertible,
          CustomReflectable,
          CustomPlaygroundDisplayConvertible
    {
        
        public var receiveValue: (Input) -> Void

        public var receiveCompletion: (SimpleSubscribers.Completion<Failure>) -> Void

        private var status = SimpleSubscriptionStatus.awaitingSubscription

        private let lock = NSLock()

        public var description: String { return "Sink" }

        public var customMirror: Mirror {
            return Mirror(self, children: EmptyCollection())
        }

        public var playgroundDescription: Any { return description }

        public init(
            receiveCompletion: @escaping (SimpleSubscribers.Completion<Failure>) -> Void,
            receiveValue: @escaping ((Input) -> Void)
        ) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
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

        public func receive(_ value: Input) -> SimpleSubscribers.Demand {
            lock.lock()
            let receiveValue = self.receiveValue
            lock.unlock()
            receiveValue(value)
            return .none
        }

        public func receive(completion: SimpleSubscribers.Completion<Failure>) {
            lock.lock()
            status = .terminal
            let receiveCompletion = self.receiveCompletion
            self.receiveCompletion = { _ in }

            withExtendedLifetime(receiveValue) {
                receiveValue = { _ in }
                lock.unlock()
            }

            receiveCompletion(completion)
        }

        public func cancel() {
            lock.lock()
            guard case let .subscribed(subscription) = status else {
                lock.unlock()
                return
            }
            status = .terminal
            withExtendedLifetime((receiveValue, receiveCompletion)) {
                receiveCompletion = { _ in }
                receiveValue = { _ in }
                lock.unlock()
            }
            subscription.cancel()
        }
    }
}

extension SimplePublisher {

    public func sink(
        receiveValue: @escaping (Output) -> Void
    ) -> SimpleAnyCancellable {
        let subscriber = SimpleSubscribers.Sink<Output, Failure>(
            receiveCompletion: { _ in },
            receiveValue: receiveValue
        )
        subscribe(subscriber)
        return SimpleAnyCancellable(subscriber)
    }
}
