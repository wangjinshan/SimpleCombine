//
//  CusCombineIdentifier.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

private var __identifier: UInt64 = 0

internal func __nextCombineIdentifier() -> UInt64 {
    defer { __identifier += 1 }
    return __identifier
}

public struct SimpleCombineIdentifier: Hashable, CustomStringConvertible {

    private let rawValue: UInt64

    public init() {
        rawValue = __nextCombineIdentifier()
    }

    public init(_ obj: AnyObject) {
        rawValue = UInt64(UInt(bitPattern: ObjectIdentifier(obj)))
    }

    public var description: String {
        return "0x\(String(rawValue, radix: 16))"
    }
}
