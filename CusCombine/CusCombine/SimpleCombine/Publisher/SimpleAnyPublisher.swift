//
//  CusAnyPublisher.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/28.
//

extension SimplePublisher {

    @inlinable
    public func eraseToAnyPublisher() -> SimpleAnyPublisher<Output, Failure> {
        return .init(self)
    }
}

public struct SimpleAnyPublisher<Output, Failure: Error>: CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    
    @usableFromInline
    internal let box: PublisherBoxBase<Output, Failure>

    @inlinable
    public init<PublisherType: SimplePublisher>(_ publisher: PublisherType) where Output == PublisherType.Output, Failure == PublisherType.Failure {
        if let erased = publisher as? SimpleAnyPublisher<Output, Failure> {
            box = erased.box
        } else {
            box = PublisherBox(base: publisher)
        }
    }

    public var description: String {
        return "AnyPublisher"
    }

    public var playgroundDescription: Any {
        return description
    }
}

extension SimpleAnyPublisher: SimplePublisher {

    @inlinable
    public func receive<Downstream: SimpleSubscriber>(subscriber: Downstream)
        where Output == Downstream.Input, Failure == Downstream.Failure {
        box.receive(subscriber: subscriber)
    }
}

@usableFromInline
internal class PublisherBoxBase<Output, Failure: Error>: SimplePublisher {

    @inlinable
    internal init() {}

    @usableFromInline
    internal func receive<Downstream: SimpleSubscriber>(subscriber: Downstream)
        where Failure == Downstream.Failure, Output == Downstream.Input {}
}

@usableFromInline
internal final class PublisherBox<PublisherType: SimplePublisher>: PublisherBoxBase<PublisherType.Output, PublisherType.Failure> {
    @usableFromInline
    internal let base: PublisherType

    @inlinable
    internal init(base: PublisherType) {
        self.base = base
        super.init()
    }

    @inlinable
    override internal func receive<Downstream: SimpleSubscriber>(subscriber: Downstream)
        where Failure == Downstream.Failure, Output == Downstream.Input {
        base.receive(subscriber: subscriber)
    }
}
