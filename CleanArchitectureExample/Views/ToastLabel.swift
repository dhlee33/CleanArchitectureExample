//
//  ToastView.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 25/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift

final class ToastLabel: UILabel, View {
    var disposeBag = DisposeBag()
    
    typealias Reactor = ToastLabelReactor
    
    func configure(reactor: ToastLabelReactor, backgroundColor: UIColor) {
        self.reactor = reactor
        self.backgroundColor = backgroundColor
        self.textColor = .white
        self.textAlignment = .center
        self.alpha = 0
        self.clipsToBounds = true
    }
    
    func bind(reactor: Reactor) {
        reactor.state.map { $0.text }
            .subscribe(onNext: { [weak self] text in
                guard let self = self, let text = text, !text.isEmpty else { return }
                self.text = text
                self.alpha = 1
                UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                    self.alpha = 0
                })
            }).disposed(by: disposeBag)
    }
}
