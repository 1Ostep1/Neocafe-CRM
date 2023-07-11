//
//  ProfileEditViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 10/11/21.
//

import UIKit

class ProfileEditViewController: BaseViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.text = "Редактирование"
        return label
    }()
    
    private lazy var nameTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.setPlaceholder(with: "Ramazan", color: .gray)
        field.setImage(with: Asset.user.name)
        field.setBorderColor(with: .clear)
        field.setBackgroundColor(with: Asset.clientGray.color)
        field.setKeyboardType(with: .default)
        return field
    }()
    
    private lazy var phoneTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.isUserInteractionEnabled = false
        field.setPlaceholder(with: "5555555", color: .gray)
        field.setImage(with: Asset.phone.name)
        field.setBorderColor(with: .clear)
        field.setBackgroundColor(with: Asset.clientGray.color)
        field.setKeyboardType(with: .numberPad)
        field.tintColor = .darkGray
        return field
    }()
    
    private lazy var birthdayTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.setPlaceholder(with: "21.12.12", color: .gray)
        field.setImage(with: Asset.calendar.name)
        field.setBorderColor(with: .clear)
        field.setBackgroundColor(with: Asset.clientGray.color)
        field.addInputViewDatePicker(target: self, selector: #selector(doneButtonPressed))
        return field
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.backgroundColor = Asset.clientOrange.color
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(saveProfileInfo), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        return indicator
    }()
    
    // MARK: - Injection
    var viewModel: ProfileViewModelType!
    
    private var isLoading = false {
        didSet {
            activityIndicator.isHidden = !isLoading
            if isLoading {
                activityIndicator.startAnimating()
                saveButton.alpha = 0.5
                saveButton.isEnabled = false
            }
            activityIndicator.stopAnimating()
            saveButton.alpha = 1
            saveButton.isEnabled = true
        }
    }
    
    private var bDayDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        setUp()
    }
    
    init(vm: ProfileViewModelType) {
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
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(phoneTextField)
        view.addSubview(birthdayTextField)
        view.addSubview(saveButton)
        saveButton.addSubview(activityIndicator)
    }
    
    private func setUpConstaints () {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }
        birthdayTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(birthdayTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
    }
    
    @objc
    private func saveProfileInfo() {
        suggestChanges()
    }
    
    @objc
    private func doneButtonPressed() {
        if let datePicker = birthdayTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            birthdayTextField.text = dateFormatter.string(from: datePicker.date)
            bDayDate = datePicker.date
        }
        birthdayTextField.resignFirstResponder()
     }
    
    private func getUserInfo() {
        withRetry(viewModel.getUserInfo) { [weak self] res in
            if case .success(let info) = res {
                self?.setUserInfo(user: info)
            }
        }
    }
    
    private func editProfile() {
        guard let birthDay = bDayDate,
              let name = nameTextField.text else {
            return
        }
        isLoading = true
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let formattedDate = formatter.string(from: birthDay)
        
        let editProfileCompletion = { [unowned self] completion in
            viewModel.editProfile(name: name, birthDate: formattedDate, completion: completion)
        }
        
        withRetry(editProfileCompletion) { [weak self] res in
            if case .success() = res {
                self?.isLoading = false
                self?.getUserInfo()
            } else if case .failure(let err) = res {
                print(err.localizedDescription)
            }
        }
    }
    
    private func setUserInfo(user: UserProfileDTO) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy"
        let resultString = inputFormatter.string(from: user.bdate.toDate())
        
        nameTextField.text = user.name
        birthdayTextField.text = resultString
        bDayDate = user.bdate.toDate()
        phoneTextField.text = user.phoneNumber.replacingOccurrences(of: "+996", with: "")
        navigationController?.popViewController(animated: true)
    }
    
    private func suggestChanges() {
        let alert = UIAlertController(
            title: "Изменения не сохранены",
            message: "Хотите покинуть страницу редактирования?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] action in
            self?.editProfile()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }
}
