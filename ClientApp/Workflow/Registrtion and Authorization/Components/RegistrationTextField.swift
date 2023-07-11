//
//  RegistrationTextField.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import UIKit

class RegistrationTextField: UITextField {
    private lazy var mistakeLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
        configure()
    }
    
    private func setUpSubviews() {
        addSubview(mistakeLabel)
    }
    
    private func setUpConstaints () {
        mistakeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(snp.top).offset(-6)
        }
    }
    
    private func configure() {
        self.leftViewMode = .always
        self.layer.cornerRadius = 25
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.textColor = .black
        self.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    enum fieldType {
        case phone
        case name
        case date
    }
}

//MARK: - Public Function
extension RegistrationTextField {
    public func setBackgroundColor(with color: UIColor) {
        self.backgroundColor = color
    }
    
    public func setBorderColor(with color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    
    public func setKeyboardType(with type: UIKeyboardType = .alphabet) {
        self.keyboardType = type
    }
    
    public func setMistakeLabel(to label: String, textColor: UIColor = .lightGray) {
        mistakeLabel.isHidden = false
        mistakeLabel.text = label
        mistakeLabel.textColor = textColor
        shakeField()
    }
    
    public func hideMistakeLabel() {
        mistakeLabel.isHidden = true
        mistakeLabel.text = ""
    }
    
    public func setPlaceholder(with text: String, color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
    public func shakeField() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    public func setImage(with string: String) {
        self.setUpImage(imageName: string, on: .left)
    }
    
    public func setTextFieldFont(font: String, size: CGFloat) {
        self.font = UIFont.systemFont(ofSize: size)
    }
}
