//
//  CusSubscriptions.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

public enum SimpleSubscriptions {}

extension SimpleSubscriptions {
    public static let empty: SimpleSubscription = _EmptySubscription.singleton
}

extension SimpleSubscriptions {
    private struct _EmptySubscription: SimpleSubscription,
                                       CustomStringConvertible,
                                       CustomReflectable,
                                       CustomPlaygroundDisplayConvertible
    {
        let combineIdentifier = SimpleCombineIdentifier()

        private init() {}

        func request(_ demand: SimpleSubscribers.Demand) {}

        func cancel() {}

        fileprivate static let singleton = _EmptySubscription()

        var description: String { return "Empty" }

        var customMirror: Mirror { return Mirror(self, children: EmptyCollection()) }

        var playgroundDescription: Any { return description }
    }
}
