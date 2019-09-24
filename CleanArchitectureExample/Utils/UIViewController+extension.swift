//
//  UIViewController+extension.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 24/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import UIKit

extension UIViewController {
    func showToast(message: String, backgroundColor: UIColor = .black) {
        let toastLabel = UILabel(frame: CGRect(x: 40, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 80, height: 35))
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showErrorToast(message: String) {
        self.showToast(message: message, backgroundColor: .red)
    }
}

