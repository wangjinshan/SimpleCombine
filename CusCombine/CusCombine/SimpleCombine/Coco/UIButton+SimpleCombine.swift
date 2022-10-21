//
//  UIButton+SimpleCombine.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/28.
//

import UIKit

extension UIButton {
    var tapPublisher: SimpleAnyPublisher<UIControl, Never> {
        return controlEventPublisher(for: .touchUpInside)
    }
}
