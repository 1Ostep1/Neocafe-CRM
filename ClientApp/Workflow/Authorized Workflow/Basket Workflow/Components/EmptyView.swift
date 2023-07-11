//
//  EmptyView.swift
//  ClientApp
//
//  Created by Ramazan Iusupov on 22/4/23.
//

import UIKit

class EmptyView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .black
        label.text = "Вы еще ничего не выбрали"
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        let image = Asset.animal.image
        view.image = image
        return view
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Asset.clientOrange.color
        button.layer.cornerRadius = 10
        button.setTitle("В меню", for: .normal)
        button.addTarget(self, action: #selector(menuTap), for: .touchUpInside)
        return button
    }()
    
    public var menuTapped: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(menuButton)
    }
    
    private func setUpConstaints() {
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview().offset(-90)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(250)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(30)
        }
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(70)
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
    }
    
    @objc
    private func menuTap() {
        menuTapped?()
    }
}
