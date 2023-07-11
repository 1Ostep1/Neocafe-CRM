//
//  PhoneSignUpViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import UIKit
import KeychainAccess

class PhoneRegistrationViewController: BaseRegistrationViewController {
    private lazy var registrationLabel: UILabel = {
        let label = UILabel()
        label.text = "Регистрация"
        label.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        label.textColor = .black
        return label
    }()
    
    private lazy var nameTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.setPlaceholder(with: "Имя", color: .gray)
        field.setImage(with: Asset.user.name)
        field.setBorderColor(with: .clear)
        field.setBackgroundColor(with: Asset.clientGray.color)
        field.setKeyboardType(with: .default)
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return field
    }()
    
    private lazy var phoneTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.setPlaceholder(with: "5555555", color: .gray)
        field.setImage(with: Asset.phone.name)
        field.setBorderColor(with: .clear)
        field.setBackgroundColor(with: Asset.clientGray.color)
        field.setKeyboardType(with: .numberPad)
        field.delegate = self
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return field
    }()
    
    private lazy var getCodeButton: RegistrationButton = {
        let button = RegistrationButton()
        button.setTitle("Получить код")
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
    public var viewModel: PhoneRegistrationViewModelType
    private var searchTerm: String?
    private var countryCode = "+996"
    
    init(vm: PhoneRegistrationViewModelType) {
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
        nameTextField.resignFirstResponder()
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(registrationLabel)
        view.addSubview(nameTextField)
        view.addSubview(phoneTextField)
        view.addSubview(getCodeButton)
        getCodeButton.addSubview(activity)
    }
    
    private func setUpConstaints () {
        registrationLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(35)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(registrationLabel.snp.bottom).offset(35)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        getCodeButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        activity.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.center.equalToSuperview()
        }
    }
    
    @objc
    private func getCodeButtonTapped() {
        requestCode()
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        searchTerm = textField.text
    }
    
    // MARK: - Request
    func requestCode() {
        guard let phone = phoneTextField.text,
              phone.count > 8,
              let name = nameTextField.text,
              name.count > 2 else { return }
        phoneTextField.resignFirstResponder()
        getCodeButton.isLoading = true
        let fullPhone = countryCode + phone
        let userInfo = RegistrationDTO(firstName: name, phoneNumber: fullPhone)
        let requestCode = { [unowned self] completion in
            self.viewModel.registerNewUser(user: userInfo, completion: completion)
        }
        
        withRetry(requestCode) { [weak self] (res) in
            guard let `self` = self else { return }
            self.getCodeButton.isLoading = false
            if case .success = res {
                let confirmationCodeVC = InjectionService.resolve(controller: PhoneConfirmationViewController.self)
                confirmationCodeVC.phoneNumber = phone
                self.navigationController?.pushViewController(confirmationCodeVC, animated: true)
            }
        }
    }
}

extension PhoneRegistrationViewController: UITextFieldDelegate {
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
            text.removeLast()
            textField.text = text
            phoneTextField.setMistakeLabel(to: "Invalid phone number length")
        } else {
            phoneTextField.hideMistakeLabel()
        }
    }
}
