//
//  SimpleSubscribers.Completion.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

extension SimpleSubscribers {

    public enum Completion<Failure: Error> {
        case finished
        case failure(Failure)
    }
}

extension SimpleSubscribers.Completion: Equatable where Failure: Equatable {}

extension SimpleSubscribers.Completion: Hashable where Failure: Hashable {}
