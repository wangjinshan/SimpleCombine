//
//  ViewController.swift
//  CusCombine
//
//  Created by 王金山 on 2022/9/27.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    @IBAction func combineAction(_ sender: Any) {
        let vc = CusCombineDemoController()
        present(vc, animated: true)
    }
}

