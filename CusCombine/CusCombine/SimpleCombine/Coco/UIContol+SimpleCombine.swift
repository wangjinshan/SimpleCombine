//
//  UIContol+SimpleCombine.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/28.
//

import UIKit

public extension UIControl {
    func controlEventPublisher(for events: UIControl.Event) -> SimpleAnyPublisher<UIControl, Never> {
       return SimplePublishers.ControlEvent(control: self, events: events)
                  .eraseToAnyPublisher()
    }
}
