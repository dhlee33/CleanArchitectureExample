//
//  BaseViewController.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    let infoToast: ToastLabel = {
        let label = ToastLabel()
        let reactor = ToastLabelReactor()
        label.configure(reactor: reactor, backgroundColor: .black)
        return label
    }()
    let errorToast: ToastLabel = {
        let label = ToastLabel()
        let reactor = ToastLabelReactor()
        label.configure(reactor: reactor, backgroundColor: .red)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        infoToast.frame = CGRect(x: 40, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 80, height: 35)
        errorToast.frame = CGRect(x: 40, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 80, height: 35)
        self.view.addSubview(infoToast)
        self.view.addSubview(errorToast)
    }
}
