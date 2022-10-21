//
//  SimpleSubscriptionStatus.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

internal enum SimpleSubscriptionStatus {
    case awaitingSubscription
    case subscribed(SimpleSubscription)
    case pendingTerminal(SimpleSubscription)
    case terminal
}

extension SimpleSubscriptionStatus {
    internal var isAwaitingSubscription: Bool {
        switch self {
        case .awaitingSubscription:
            return true
        default:
            return false
        }
    }

    internal var subscription: SimpleSubscription? {
        switch self {
        case .awaitingSubscription, .terminal:
            return nil
        case let .subscribed(subscription), let .pendingTerminal(subscription):
            return subscription
        }
    }
}
