//
//  BranchCell.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 9/11/21.
//

import UIKit

protocol BranchCellDelegate: AnyObject {
    func resendTo2Gis(with data: BranchDTO)
}

class BranchCell: UICollectionViewCell {
    private lazy var branchImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .brown
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.image = Asset.branch.image
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.text = "Сегодня: с 11:00 до 22:00"
        return label
    }()
    
    private lazy var branchLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.text = "NeoCafe Dzerzhinka"
        return label
    }()
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.text = "0553 343 321"
        return label
    }()
    
    private lazy var adressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.text = "бульвар Эркиндик, 35"
        return label
    }()
    
    private lazy var resendTo: UIButton = {
        let button = UIButton()
        button.setImage(Asset.paperPlaneTilt.image, for: .normal)
        button.tintColor = .white
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let phoneImage: UIImageView = {
        let view = UIImageView()
        view.image = Asset.phone.image
        view.tintColor = Asset.clientOrange.color
        return view
    }()
    
    private let adressImage: UIImageView = {
        let view = UIImageView()
        view.image = Asset.mapPin.image
        view.tintColor = Asset.clientOrange.color
        return view
    }()
    
    private var branch: BranchDTO?
    
    // MARK: - Properties
    weak var delegate: BranchCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
        resendTo.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
    }
    
    private func setUpSubviews() {
        addSubview(branchImageView)
        branchImageView.addSubview(timeLabel)
        branchImageView.addSubview(branchLabel)
        branchImageView.addSubview(phoneLabel)
        branchImageView.addSubview(phoneImage)
        branchImageView.addSubview(adressImage)
        branchImageView.addSubview(adressLabel)
        branchImageView.addSubview(resendTo)
        branchImageView.addSubview(adressLabel)
        branchImageView.bringSubviewToFront(resendTo)
    }
    
    private func setUpConstaints () {
        branchImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(15)
            make.width.equalTo(250)
        }
        branchLabel.snp.makeConstraints { make in
            make.bottom.equalTo(phoneLabel.snp.top).offset(-17)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(25)
        }
        phoneLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(15)
            make.width.greaterThanOrEqualTo(89)
        }
        phoneImage.snp.makeConstraints { make in
            make.trailing.equalTo(phoneLabel.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-16)
            make.height.width.equalTo(15)
        }
        adressLabel.snp.makeConstraints { make in
            make.leading.equalTo(adressImage.snp.trailing).offset(8)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(15)
            make.width.greaterThanOrEqualTo(89)
        }
        adressImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.width.equalTo(15)
        }
        resendTo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.width.equalTo(35)
        }
    }
    
    func display(branch: BranchDTO) {
        self.branch = branch
        branchLabel.text = branch.name
        phoneLabel.text = branch.phoneNumber
        adressLabel.text = branch.address
        if branch.link2gis == nil {
            resendTo.isHidden = true
        }
    }
    
    @objc
    private func resendTapped() {
        guard let branch = branch else { return }
        delegate?.resendTo2Gis(with: branch)
    }
}
