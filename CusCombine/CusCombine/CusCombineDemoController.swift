//
//  CusCombineDemoController.swift
//  PushDemo
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

class CusCombineDemoController: UIViewController {
    
    let up = SimplePassthroughSubject<String, Never>()
    var cancellable: [SimpleAnyCancellable] = []
    
    let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 44))
    
    deinit {
        print("销毁了")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        normalDemo()
        assignDemo()
    }
}

extension CusCombineDemoController {
    func normalDemo() {
        // 订阅
        up.sink { str in
            print("------\(str)-----")
        }.store(in: &cancellable)
        
        // 订阅
        let sub = SimpleSubscribers.Sink<String, Never> { _ in
        } receiveValue: { input in
            print(input)
        }
        sub.store(in: &cancellable)
        up.receive(subscriber: sub)
        
        // 符号操作
        up.filter { output in
            return output == "王金山"
        }.sink { output in
            print("输出的数据是: " + output)
        }.store(in: &cancellable)
        
        // 发送数据
        up.send("王金山")
        
        button.backgroundColor = .cyan
        button.setTitle("文字", for: .normal)
        view.addSubview(button)
        
        button.tapPublisher.sink { info in
            print(info)
        }.store(in: &cancellable)
    }
}

extension CusCombineDemoController {
    func assignDemo() {
        class Student{
           var name: String = ""
        }
        let student = Student()
        up.assign(to: \.name, on: student).store(in: &cancellable)
        up.send("王金山")
        print(student.name)
    }
}


