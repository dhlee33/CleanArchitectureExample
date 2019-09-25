//
//  BaseViewController.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    let toastLabel: ToastLabel = {
        let label = ToastLabel()
        let reactor = ToastLabelReactor()
        label.configure(reactor: reactor)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        toastLabel.frame = CGRect(x: 40, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 80, height: 35)
        self.view.addSubview(toastLabel)
    }
}
