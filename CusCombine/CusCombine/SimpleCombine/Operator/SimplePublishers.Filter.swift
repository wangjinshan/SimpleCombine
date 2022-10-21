//
//  CusPublishers.Filter.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/28.
//

extension SimplePublisher {
    public func filter( isIncluded: @escaping (Output) -> Bool) -> SimplePublishers.Filter<Self> {
        return SimplePublishers.Filter(upstream: self, isIncluded: isIncluded)
    }
}

extension SimplePublishers {
    
    // 操作符号类, 通过一些列的操作符号,可以过滤掉自己需要的数据
    public struct Filter<Upstream: SimplePublisher>: SimplePublisher {
                
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream

        public let isIncluded: (Upstream.Output) -> Bool
        
        init(upstream: Upstream, isIncluded: @escaping (Output) -> Bool) {
            self.upstream = upstream
            self.isIncluded = isIncluded
        }
        
        public func receive<Subscriber>(subscriber: Subscriber) where Subscriber : SimpleSubscriber, Upstream.Failure == Subscriber.Failure, Upstream.Output == Subscriber.Input {
            upstream.subscribe(Inner(downstream: subscriber, filter: isIncluded))
        }
    }
}

extension SimplePublishers.Filter {
    // 处理消息的管道对象
    private struct Inner<Downstream: SimpleSubscriber>
        : SimpleSubscriber,
          CustomStringConvertible,
          CustomReflectable,
          CustomPlaygroundDisplayConvertible
    where Upstream.Output == Downstream.Input, Upstream.Failure == Downstream.Failure {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        let downstream: Downstream
        let filter: (Input) -> Bool
        
        init(downstream: Downstream, filter: @escaping (Input) -> Bool) {
            self.downstream = downstream
            self.filter = filter
        }
        
        func receive(subscription: SimpleSubscription) {
            downstream.receive(subscription: subscription)
        }
        
        func receive(_ input: Upstream.Output) -> SimpleSubscribers.Demand {
            if filter(input) { // 判断满足的条件
                return downstream.receive(input)
            }
            return .max(1)
        }
        
        func receive(completion: SimpleSubscribers.Completion<Failure>) {
            downstream.receive(completion: completion)
        }

        var combineIdentifier = SimpleCombineIdentifier()
        
        var description: String { return "Filter" }

        var customMirror: Mirror {
            return Mirror(self, children: EmptyCollection())
        }

        var playgroundDescription: Any { return description }
    }
}
