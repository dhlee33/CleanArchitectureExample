//
//  ToastManager.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 2021/03/28.
//  Copyright © 2021 이동현. All rights reserved.
//

import UIKit
import RxSwift

protocol ToastManager {
    func showToast(_ type: ToastType)
}

enum ToastType: Equatable {
    case error(String)
    case success(String)

    var message: String {
        switch self {
        case .error(let message), .success(let message):
            return message
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .error:
            return .systemRed
        case .success:
            return .systemGreen
        }
    }

    static var generalError: ToastType {
        return .error("An error has occurred")
    }
}

final class ToastViewController: UIViewController, ToastManager {
    static let shared = ToastViewController()
    private let toastStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }

    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)

        configure()
        bindEvent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        view.isUserInteractionEnabled = false

        view.addSubview(toastStackView)

        toastStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(18)
        }
    }

    private func bindEvent() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let ss = self else { return }
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    ss.toastStackView.snp.updateConstraints { make in
                        make.bottom.equalTo(ss.view.safeAreaLayoutGuide).inset(keyboardHeight + 18 - ss.view.safeAreaInsets.bottom)
                    }
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let ss = self else { return }
                ss.toastStackView.snp.updateConstraints { make in
                    make.bottom.equalTo(ss.view.safeAreaLayoutGuide).inset(18)
                }
            })
            .disposed(by: disposeBag)

    }

    func showToast(_ type: ToastType) {
        let view = ToastView(type: type)

        if let toastView = toastStackView.arrangedSubviews.first(where: { ($0 as? ToastView)?.type == type }) {
            UIView.animate(withDuration: 0.1) {
                toastView.alpha = 0
            } completion: { [weak self] _ in
                self?.toastStackView.removeArrangedSubview(toastView)
                toastView.removeFromSuperview()
                view.alpha = 0
                self?.toastStackView.addArrangedSubview(view)
                UIView.animate(withDuration: 0.1) {
                    view.alpha = 1
                }
            }
        } else {
            toastStackView.addArrangedSubview(view)
        }

        Single.just(Void())
            .delay(2, scheduler: MainScheduler.asyncInstance)
            .debug("$$$")
            .subscribe(onSuccess: { [weak self] _ in
                UIView.animate(withDuration: 0.5) {
                    view.alpha = 0
                } completion: { _ in
                    self?.toastStackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            })
            .disposed(by: view.disposeBag)
    }
}

private final class ToastView: UIView {
    private let messageLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 12, weight: .medium)
    }

    let type: ToastType
    let disposeBag = DisposeBag()

    init(type: ToastType) {
        self.type = type
        super.init(frame: .zero)

        layer.cornerRadius = 4
        backgroundColor = type.backgroundColor
        messageLabel.text = type.message

        addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(17)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
