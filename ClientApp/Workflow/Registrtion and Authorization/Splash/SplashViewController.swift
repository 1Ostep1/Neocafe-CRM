//
//  ViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import UIKit
import Swinject

class SplashViewController: BaseRegistrationViewController {
    private lazy var registrationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Регистрация", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(registrationTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var authorizationButton: RegistrationButton = {
        let button = RegistrationButton()
        button.setTitle("Войти")
        button.addTarget(self, action: #selector(authorizationTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Injection
    var viewModel: SplashViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isAuthorized {
            let controller = BaseTabViewController()
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
    
    init(viewModel vm: SplashViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(authorizationButton)
        view.addSubview(registrationButton)
    }
    
    private func setUpConstaints () {
        authorizationButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
//            make.centerY.equalToSuperview().inset(50)
        }
        registrationButton.snp.makeConstraints { make in
            make.top.equalTo(authorizationButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-70)
        }
    }
    
    @objc
    private func registrationTapped() {
        let registrationVC = InjectionService.resolve(controller: PhoneRegistrationViewController.self)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    @objc
    private func authorizationTapped() {
        let authVC = InjectionService.resolve(controller: AuthViewController.self)
        navigationController?.pushViewController(authVC, animated: true)
    }
}

