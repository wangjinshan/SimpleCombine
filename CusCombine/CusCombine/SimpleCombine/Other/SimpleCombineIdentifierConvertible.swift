//
//  SimpleCombineIdentifierConvertible.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

public protocol SimpleCombineIdentifierConvertible {
    var combineIdentifier: SimpleCombineIdentifier { get }
}

extension SimpleCombineIdentifierConvertible where Self: AnyObject {

    public var combineIdentifier: SimpleCombineIdentifier {
        return SimpleCombineIdentifier(self)
    }
}
