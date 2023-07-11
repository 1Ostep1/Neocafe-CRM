//
//  CategoryItemCell.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 23/11/21.
//

import UIKit

class CategoryItemCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        label.textAlignment = .center
        label.layer.masksToBounds = false
        return label
    }()
    
    private lazy var featuredPhotoView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    private lazy var contentContainer: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var imageView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        contentView.addSubview(contentContainer)
        contentView.addSubview(featuredPhotoView)
        
        contentContainer.addSubview(imageView)
        contentContainer.addSubview(titleLabel)
        
        imageView.addSubview(featuredPhotoView)
        
        featuredPhotoView.clipsToBounds = true
        
        imageView.backgroundColor = UIColor(red: 1, green: 0.88, blue: 0.454, alpha: 1)
        imageView.layer.cornerRadius = 20
       
        setupConstraint()
    }
    
    func setupConstraint() {
        contentContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(26)
        }
        featuredPhotoView.snp.makeConstraints { make in
            make.height.equalTo(imageView.snp.height).multipliedBy(0.65)
            make.width.equalTo(featuredPhotoView.snp.height)
            make.centerX.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func display(cell: CategoryDTO) {
        titleLabel.text = cell.name
        
        switch cell.name {
        case "Кофе":
            featuredPhotoView.image = Asset.coffee.image
        case "Десерты":
            featuredPhotoView.image = Asset.desserts.image
        case "Коктейли":
            featuredPhotoView.image = Asset.cocktails.image
        case "Выпечка":
            featuredPhotoView.image = Asset.bakery.image
        case "Чаи":
            featuredPhotoView.image = Asset.tea.image
        default:
            featuredPhotoView.image = Asset.coffee.image
        }
    }
}
