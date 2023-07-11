//
//  OrderButtonsView.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 13/11/21.
//

import UIKit

protocol OrderButtonsViewDelegate: AnyObject {
    func addMoreTap()
    func orderTap()
    func orderTypeTap(type: OrderButtonsView.OrderType)
}

class OrderButtonsView: UICollectionReusableView {
    enum OrderType: String {
        case takeAway = "IN"
        case atTheVenue = "OUT"
    }
    
    private lazy var sumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.attributedText = buildSumLabelAttributeText("520 c")
        return label
    }()
    
    private lazy var addMoreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Asset.clientOrange.color, for: .normal)
        button.backgroundColor = Asset.clientBackround.color
        button.layer.borderColor = Asset.clientOrange.color.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.setTitle("Добавить еще", for: .normal)
        button.addTarget(self, action: #selector(addMoreTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var orderButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Asset.clientOrange.color
        button.layer.cornerRadius = 10
        button.setTitle("Заказать", for: .normal)
        button.addTarget(self, action: #selector(orderTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var takeawayButton: RegistrationButton = {
        let button = RegistrationButton()
        button.setTitle("Возьму с собой")
        button.isInvert()
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = Asset.clientGray.color
        button.addTarget(self, action: #selector(takeawayTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var inTheCafeButton: RegistrationButton = {
        let button = RegistrationButton()
        button.setTitle("В заведении")
        button.addTarget(self, action: #selector(inTheCafeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var orderTypeStackView: UIStackView = {
       let view = UIStackView()
        view.addArrangedSubview(takeawayButton)
        view.addArrangedSubview(inTheCafeButton)
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.alignment = .fill
        view.spacing = 5
        return view
    }()
    
    weak var delegate: OrderButtonsViewDelegate?
    private var orderType: OrderType = .atTheVenue {
        didSet {
            stylyzeOrderType(orderType)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
    }
    
    public func display(item: String) {
        sumLabel.attributedText = buildSumLabelAttributeText(item)
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        addSubview(sumLabel)
        addSubview(addMoreButton)
        addSubview(orderButton)
        addSubview(orderTypeStackView)
    }
    
    private func setUpConstaints() {
        addMoreButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        sumLabel.snp.makeConstraints { make in
            make.top.equalTo(addMoreButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        orderTypeStackView.snp.makeConstraints { make in
            make.top.equalTo(sumLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        orderButton.snp.makeConstraints { make in
            make.top.equalTo(orderTypeStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
    }
    
    @objc
    private func addMoreTapped() {
        delegate?.addMoreTap()
    }
    
    @objc
    private func orderTapped() {
        delegate?.orderTap()
    }
    
    @objc
    private func takeawayTapped() {
        delegate?.orderTypeTap(type: .takeAway)
        orderType = .takeAway
    }
    
    @objc
    private func inTheCafeTapped() {
        delegate?.orderTypeTap(type: .atTheVenue)
        orderType = .atTheVenue
    }
    
    private func buildSumLabelAttributeText(_ item: String) -> NSMutableAttributedString {
        let attrs1 = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold),
            NSAttributedString.Key.foregroundColor: Asset.clientOrange.color
        ]
        let attrs2 = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let attributedString1 = NSMutableAttributedString(string: "Итого: ", attributes: attrs2)
        let attributedString2 = NSMutableAttributedString(string: item, attributes: attrs1)
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    private func stylyzeOrderType(_ type: OrderType) {
        UIView.animate(withDuration: 0.3) { [self] in
            switch type {
            case .takeAway:
                takeawayButton.layer.cornerRadius = 25
                takeawayButton.backgroundColor = Asset.clientOrange.color
                takeawayButton.setTitleColor(.white, for: .normal)
                
                inTheCafeButton.setTitleColor(.black, for: .normal)
                inTheCafeButton.isInvert()
                inTheCafeButton.backgroundColor = Asset.clientGray.color
            default:
                inTheCafeButton.layer.cornerRadius = 25
                inTheCafeButton.backgroundColor = Asset.clientOrange.color
                inTheCafeButton.setTitleColor(.white, for: .normal)
                
                takeawayButton.setTitleColor(.black, for: .normal)
                takeawayButton.isInvert()
                takeawayButton.backgroundColor = Asset.clientGray.color
            }
        }
    }
}
