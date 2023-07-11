//
//  ProfileOrderCell.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 10/11/21.
//

import UIKit

class ProfileOrderCell: UICollectionViewCell {
    private lazy var branchImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var branchLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.text = "NeoCafe Dzerzhinka"
        return label
    }()
    
    private lazy var productsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Латте, Капучино, Багров..."
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "14 августа"
        label.textColor = .darkGray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUp()
    }
    
    private func setUp() {
        backgroundColor = Asset.clientBackround.color
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        addSubview(branchImage)
        addSubview(branchLabel)
        addSubview(productsLabel)
        addSubview(dateLabel)
    }
    
    private func setUpConstaints () {
        branchImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(89)
            make.bottom.equalToSuperview().offset(-9)
        }
        branchLabel.snp.makeConstraints { make in
            make.top.equalTo(branchImage).offset(20)
            make.leading.equalTo(branchImage.snp.trailing).offset(16)
            make.height.equalTo(22)
            make.trailing.equalToSuperview().offset(-16)
        }
        productsLabel.snp.makeConstraints { make in
            make.top.equalTo(branchLabel.snp.bottom).offset(16)
            make.leading.equalTo(branchImage.snp.trailing).offset(16)
            make.height.equalTo(22)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-16)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(productsLabel)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(15)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    func display(_ item: HistoryDTO) {
        branchLabel.text = item.branchName
        productsLabel.text = item.listOrderDetailsDto.map({ $0.name }).joined(separator: ", ")
        dateLabel.text = item.orderTime//.toDate().toString(dateFormat: "MMM d, yyyy")
    }
}

extension ProfileViewController {
    enum HeaderType: String {
        case current = "Актуальные"
        case closed = "Завершенные"
    }
    
    class Header: UICollectionReusableView {
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            label.text = "Актуальные"
            label.textColor = .black
            return label
        }()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setUp()
        }
        
        func display(with text: HeaderType) {
            titleLabel.text = text.rawValue
        }
        
        private func setUp() {
            backgroundColor = Asset.clientBackround.color
            setUpSubviews()
            setUpConstaints()
        }
        
        private func setUpSubviews() {
            addSubview(titleLabel)
        }
        
        private func setUpConstaints () {
            titleLabel.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(16)
                make.trailing.bottom.equalToSuperview().offset(-16)
            }
        }
    }
}
