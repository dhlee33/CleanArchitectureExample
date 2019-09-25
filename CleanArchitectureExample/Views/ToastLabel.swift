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
import RxCocoa

final class ToastLabel: UILabel, View {
    var disposeBag = DisposeBag()
    
    typealias Reactor = ToastLabelReactor
    
    func configure(reactor: ToastLabelReactor) {
        self.reactor = reactor
        self.textColor = .white
        self.textAlignment = .center
        self.alpha = 0
        self.clipsToBounds = true
    }
    
    func bind(reactor: Reactor) {
        reactor.state.map { $0.text }
            .subscribe(onNext: { [weak self] text in
                guard let self = self, let text = text, !text.isEmpty else { return }
                self.backgroundColor = reactor.currentState.backgroundColor
                self.text = text
                self.alpha = 1
                UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                    self.alpha = 0
                })
            }).disposed(by: disposeBag)
    }
}

extension Reactive where Base: ToastLabel {
    var info: Binder<String> {
        return Binder(self.base) { label, string in
            label.reactor?.action.onNext(.info(string))
        }
    }

    var error: Binder<String> {
        return Binder(self.base) { label, string in
            label.reactor?.action.onNext(.error(string))
        }
    }
}
