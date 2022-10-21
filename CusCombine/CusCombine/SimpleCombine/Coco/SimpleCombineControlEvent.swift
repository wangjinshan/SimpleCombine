//
//  SimpleCombineControlEvent.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/28.
//

import UIKit

public extension SimplePublishers {

    struct ControlEvent<Control: UIControl>: SimplePublisher {
        
        public typealias Output = UIControl
        public typealias Failure = Never

        private let control: Control
        private let controlEvents: Control.Event

        public init(control: Control,
                    events: Control.Event) {
            self.control = control
            self.controlEvents = events
        }

        public func receive<Subscriber: SimpleSubscriber>(subscriber: Subscriber) where Subscriber.Failure == Failure, Subscriber.Input == Output {
            let subscription = CocoSubscription(subscriber: subscriber,
                                            control: control,
                                            event: controlEvents)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension SimplePublishers.ControlEvent {
    
    private final class CocoSubscription<Subscriber: SimpleSubscriber, Control: UIControl>: SimpleSubscription where Subscriber.Input == Output {
        
        private var subscriber: Subscriber?
        
        init(subscriber: Subscriber, control: Control, event: Control.Event) {
            self.subscriber = subscriber
            control.addTarget(self, action: #selector(handleEvent(control:)), for: event)
        }

        func request(_ demand: SimpleSubscribers.Demand) {
        }

        func cancel() {
            subscriber = nil
        }

        @objc private func handleEvent(control: UIControl) {
            _ = subscriber?.receive(control)
        }
    }
}
