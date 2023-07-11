//
//  AuthViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import UIKit

class AuthViewController: BaseRegistrationViewController {
    private lazy var authLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход"
        label.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        label.textColor = .black
        return label
    }()
    
    private lazy var phoneTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.setPlaceholder(with: "505-21-11-02", color: .lightGray)
        field.setImage(with: Asset.phone.name)
        field.setBorderColor(with: .clear)
        field.setBackgroundColor(with: Asset.clientGray.color)
        field.setKeyboardType(with: .numberPad)
        field.tintColor = .black
        field.delegate = self
        return field
    }()
    
    private lazy var getCodeButton: RegistrationButton = {
        let button = RegistrationButton()
        button.setTitle("Получить код")
        button.isEnabled = false
        button.addTarget(self, action: #selector(getCodeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activity: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    private var isLoading: Bool = false {
        didSet {
            _ = isLoading ? activity.startAnimating() : activity.stopAnimating()
        }
    }
    // MARK: - Injection
    var viewModel: AuthViewModelType
    
    init(vm: AuthViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(authLabel)
        view.addSubview(getCodeButton)
        view.addSubview(phoneTextField)
        getCodeButton.addSubview(activity)
    }
    
    private func setUpConstaints () {
        authLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(120)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(35)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(authLabel.snp.bottom).offset(35)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(56)
        }
        
        getCodeButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        
        activity.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.center.equalToSuperview()
        }
    }
    
    @objc
    private func getCodeButtonTapped() {
      requestCode()
    }
    
    // MARK: - Request
    func requestCode() {
        guard let phone = phoneTextField.text, phone.count == 14 else {
            phoneTextField.setMistakeLabel(to: "Введите корректный номер телефона!", textColor: .red)
            return
        }
        phoneTextField.resignFirstResponder()
        getCodeButton.isLoading = true

        let fullPhone = phone.replacingOccurrences(of: " ", with: "")
        let authPayload = AuthorizationDTO(phoneNumber: fullPhone)
        let requestCode = { [unowned self] completion in
            self.viewModel.authorizeUser(user: authPayload, completion: completion)
        }

        withRetry(requestCode) { [weak self] res in
            guard let `self` = self else { return }
            let confirmationCodeVC = InjectionService.resolve(controller: ConfirmationCodeViewController.self)
            confirmationCodeVC.phoneNumber = fullPhone
            if case .success = res {
                self.navigationController?.pushViewController(confirmationCodeVC, animated: true)
            }
            self.getCodeButton.isLoading = false
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestCode()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = "+996 "
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard var text = textField.text else { return }
        getCodeButton.isEnabled = text.count > 0
        if text.count > 14 {
            phoneTextField.setMistakeLabel(to: "Invalid phone number length")
            text.removeLast()
            textField.text = text
        } else {
            phoneTextField.hideMistakeLabel()
        }
    }
}
