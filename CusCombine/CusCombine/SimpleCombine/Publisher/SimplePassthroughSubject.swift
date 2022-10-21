//
//  CusPassthroughSubject.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

// 具体的发布者
class SimplePassthroughSubject<Output, Failure: Error>: SimpleSubject {
    
    private let lock = NSLock()

    private var active = true

    private var completion: SimpleSubscribers.Completion<Failure>?

    private var downstreams = ConduitList<Output, Failure>.empty

    internal var upstreamSubscriptions: [SimpleSubscription] = []

    internal var hasAnyDownstreamDemand = false

    public init() {}

    deinit {
        for subscription in upstreamSubscriptions {
            subscription.cancel()
        }
    }
    
    public func receive<Downstream: SimpleSubscriber>(subscriber: Downstream)
        where Output == Downstream.Input, Failure == Downstream.Failure
    {
        lock.lock()
        if active {
            let conduit = Conduit(parent: self, downstream: subscriber)
            downstreams.insert(conduit)
            lock.unlock()
            subscriber.receive(subscription: conduit)
        } else {
            let completion = self.completion!
            lock.unlock()
            subscriber.receive(subscription: SimpleSubscriptions.empty)
            subscriber.receive(completion: completion)
        }
    }

    // 管道内部使用的发送的契约
    public func send(subscription: SimpleSubscription) {
        lock.lock()
        upstreamSubscriptions.append(subscription)
        let hasAnyDownstreamDemand = self.hasAnyDownstreamDemand
        lock.unlock()
        if hasAnyDownstreamDemand {
            subscription.request(.unlimited)
        }
    }
    
    public func send(_ input: Output) {
        lock.lock()
        guard active else {
            lock.unlock()
            return
        }
        let downstreams = self.downstreams
        lock.unlock()
        downstreams.forEach { conduit in
            conduit.offer(input)
        }
    }

    public func send(completion: SimpleSubscribers.Completion<Failure>) {
        lock.lock()
        guard active else {
            lock.unlock()
            return
        }
        active = false
        self.completion = completion
        let downstreams = self.downstreams.take()
        lock.unlock()
        downstreams.forEach { conduit in
            conduit.finish(completion: completion)
        }
    }

    private func acknowledgeDownstreamDemand() {
        lock.lock()
        if hasAnyDownstreamDemand {
            lock.unlock()
            return
        }
        hasAnyDownstreamDemand = true
        let upstreamSubscriptions = self.upstreamSubscriptions
        lock.unlock()
        for subscription in upstreamSubscriptions {
            subscription.request(.unlimited)
        }
    }

    private func disassociate(_ conduit: ConduitBase<Output, Failure>) {
        lock.lock()
        guard active else {
            lock.unlock()
            return
        }
        downstreams.remove(conduit)
        lock.unlock()
    }
}

extension SimplePassthroughSubject {

    private final class Conduit<Downstream: SimpleSubscriber>
        : ConduitBase<Output, Failure>,
          CustomStringConvertible,
          CustomReflectable,
          CustomPlaygroundDisplayConvertible
        where Downstream.Input == Output, Downstream.Failure == Failure
    {

        fileprivate var parent: SimplePassthroughSubject?

        fileprivate var downstream: Downstream?

        fileprivate var demand = SimpleSubscribers.Demand.none

        private var lock = NSLock()

        private var downstreamLock = NSLock()

        fileprivate init(parent: SimplePassthroughSubject,
                         downstream: Downstream) {
            self.parent = parent
            self.downstream = downstream
        }

        override func offer(_ output: Output) {
            lock.lock()
            guard demand > 0, let downstream = self.downstream else {
                lock.unlock()
                return
            }
            demand -= 1
            lock.unlock()
            downstreamLock.lock()
            let newDemand = downstream.receive(output)
            downstreamLock.unlock()
            guard newDemand > 0 else { return }
            lock.lock()
            demand += newDemand
            lock.unlock()
        }

        override func finish(completion: SimpleSubscribers.Completion<Failure>) {
            lock.lock()
            guard let downstream = self.downstream.take() else {
                lock.unlock()
                return
            }
            let parent = self.parent.take()
            lock.unlock()
            parent?.disassociate(self)
            downstreamLock.lock()
            downstream.receive(completion: completion)
            downstreamLock.unlock()
        }

        override func request(_ demand: SimpleSubscribers.Demand) {
            demand.assertNonZero()
            lock.lock()
            if self.downstream == nil {
                lock.unlock()
                return
            }
            self.demand += demand
            let parent = self.parent
            lock.unlock()
            parent?.acknowledgeDownstreamDemand()
        }

        override func cancel() {
            lock.lock()
            if downstream.take() == nil {
                lock.unlock()
                return
            }
            let parent = self.parent.take()
            lock.unlock()
            parent?.disassociate(self)
        }

        var description: String { return "PassthroughSubject" }

        var customMirror: Mirror {
            lock.lock()
            defer { lock.unlock() }
            let children: [Mirror.Child] = [
                ("parent", parent as Any),
                ("downstream", downstream as Any),
                ("demand", demand),
                ("subject", parent as Any)
            ]
            return Mirror(self, children: children)
        }

        var playgroundDescription: Any { return description }
    }
}
