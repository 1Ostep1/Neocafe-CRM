//
//  ConfirmationCodeViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import UIKit

class ConfirmationCodeViewController: BaseRegistrationViewController {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите 4-х значный код, отправленный на номер 0552 321 123"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textField1: UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.font = UIFont.systemFont(ofSize: 40, weight: .regular)
        field.textAlignment = .center
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        return field
    }()
    
    private lazy var textField2: UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.font = UIFont.systemFont(ofSize: 40, weight: .regular)
        field.textAlignment = .center
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        return field
    }()
    
    private lazy var textField3: UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.font = UIFont.systemFont(ofSize: 40, weight: .regular)
        field.textAlignment = .center
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        return field
    }()
    
    private lazy var textField4: UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.font = UIFont.systemFont(ofSize: 40, weight: .regular)
        field.textAlignment = .center
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        return field
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(textField1)
        stack.addArrangedSubview(textField2)
        stack.addArrangedSubview(textField3)
        stack.addArrangedSubview(textField4)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 2
        return stack
    }()
    
    private lazy var logInButton: RegistrationButton = {
        let button = RegistrationButton()
        button.setTitle("Войти")
        button.addTarget(self, action: #selector(getCodeTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var resendButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Asset.clientGray2.color, for: .normal)
        button.setTitle("Отправить ещё раз", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(resendOTP), for: .touchUpInside)
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
    private var confirmationCode = ""
    private var counter = 60 {
        didSet {
            resendButton.isEnabled = counter == 0 ? true : false
            resendButton.alpha = counter == 0 ? 1 : 0.5
        }
    }
    var phoneNumber = ""
    
    // MARK: - Injection
    var viewModel: AuthViewModelType
    
    init(vm: AuthViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField1.becomeFirstResponder()
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func configure() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        configureTextField()
        setUp()
    }
    
    private func setUpSubviews() {
        view.addSubview(textLabel)
        view.addSubview(horizontalStack)
        view.addSubview(logInButton)
        view.addSubview(resendButton)
        resendButton.addSubview(activity)
    }
    
    private func setUpConstaints () {
        textLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().inset(40)
        }
        horizontalStack.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(40)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth * 180 / 375)
        }
        logInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(horizontalStack.snp.bottom).offset(50)
            make.height.equalTo(60)
        }
        resendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(logInButton.snp.bottom).offset(16)
            make.height.equalTo(60)
        }
        activity.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.center.equalToSuperview()
        }
    }
    
    private func configureTextField() {
        textLabel.text = "Введите 4-х значный код, \nотправленный на номер \(phoneNumber)"
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField1.setBottomBorder()
        textField2.setBottomBorder()
        textField3.setBottomBorder()
        textField4.setBottomBorder()
    }
    
    @objc
    private func getCodeTapped(_ sender: UIButton) {
        checkCode()
    }
    
    // MARK: - Request
    private func checkCode() {
        if phoneNumber.count > 8,
           confirmationCode.count > 3 {
            isLoading = true
            let confirmationCodeCompletion = { [unowned self] completion in
                self.viewModel.confirmAuthCode(for: self.phoneNumber, confirmationCode: self.confirmationCode, completion: completion)
            }
            logInButton.isLoading = true
            defer { logInButton.isLoading = false }
            
            withRetry(confirmationCodeCompletion) { [weak self] response in
                self?.isLoading = false
                if case .success = response {
                    let tabBarVC = BaseTabViewController()
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self?.present(tabBarVC, animated: true)
                } 
            }
        }
    }
    
    @objc
    private func resendOTP() {
        resendOTPRequest()
        counter = 60
    }
    
    @objc
    private func updateCounter() {
        if counter > 0 {
            resendButton.setTitle("Отправить ещё раз(\(counter))", for: .normal)
            counter -= 1
        } else {
            resendButton.setTitle("Отправить ещё раз", for: .normal)
        }
    }
    
    private func resendOTPRequest() {
        isLoading = true
        viewModel.authorizeUser(user: .init(phoneNumber: phoneNumber)) { [weak self] _ in
            self?.isLoading = false
        }
    }
}

extension ConfirmationCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1  && string.count > 0) {
            if (textField == textField1) {
                textField2.becomeFirstResponder()
            } else if (textField == textField2) {
                textField3.becomeFirstResponder()
            } else if (textField == textField3) {
                textField4.becomeFirstResponder()
            } else if (textField == textField4) {
                checkCode()
            }
            
            textField.text = string
            confirmationCode += string
            return false
        } else if ((textField.text?.count)! >= 1  && string.count == 0) {
            if (textField == textField2) {
                textField1.becomeFirstResponder()
            } else if (textField == textField3) {
                textField2.becomeFirstResponder()
            } else if (textField == textField4) {
                textField3.becomeFirstResponder()
            } else {
                if textField4.text != "" {
                    logInButton.alpha = 1
                    logInButton.isEnabled = true
                }
            }
            textField.text = ""
            return false
        } else if ((textField.text?.count)! >= 1) {
            textField.text = string
            return false
        }
        return true
    }
}
