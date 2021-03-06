//
//  OrderCell.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 13/11/21.
//

import UIKit

class OrderCell: UICollectionViewCell {
    
    private lazy var orderImageView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.calendar.image
        return view
    }()
    
    private lazy var orderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.text = "Capucino (190c/шт)"
        return label
    }()
    
    private lazy var orderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.text = "Coffee"
        return label
    }()
    
    private lazy var sumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = Asset.clientOrange.color
        label.text = "0с"
        return label
    }()
    
    private lazy var substractButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.layer.cornerRadius = 14
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = Asset.clientGray.color
        button.tag = 0
        button.addTarget(self, action: #selector(addSubstractItemTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.textColor = .white
        button.backgroundColor = Asset.clientOrange.color
        button.tag = 1
        button.addTarget(self, action: #selector(addSubstractItemTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.text = "1"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.addArrangedSubview(substractButton)
        stack.addArrangedSubview(countLabel)
        stack.addArrangedSubview(addButton)
        return stack
    }()
    
    private var count = 0 {
        didSet {
            sumLabel.text = "\(count * 190)с"
            countLabel.text = "\(count)"
            orderCount?(count * 190)
        }
    }
    
    public var orderCount: ((Int) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
        self.contentView.layer.cornerRadius = 24
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        addSubview(orderImageView)
        addSubview(orderLabel)
        addSubview(orderDescriptionLabel)
        addSubview(sumLabel)
        addSubview(stackView)
    }
    
    private func setUpConstaints () {
        orderImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(89)
        }
        orderLabel.snp.makeConstraints { make in
            make.leading.equalTo(orderImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(orderImageView).offset(8)
            make.height.equalTo(20)
        }
        orderDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(orderLabel.snp.bottom).offset(8)
            make.leading.equalTo(orderLabel)
            make.height.equalTo(20)
            make.width.equalTo(150)
        }
        sumLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-28)
            make.leading.equalTo(orderDescriptionLabel.snp.trailing).offset(8)
            make.height.equalTo(15)
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(sumLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
    }
    
    func display(dish: OrderDTO) {
//        orderLabel.text = dish
    }
    
    @objc
    private func addSubstractItemTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if count > 0 {
                count -= 1
            }
        case 1:
            count += 1
        default:
            fatalError()
        }
    }
}
