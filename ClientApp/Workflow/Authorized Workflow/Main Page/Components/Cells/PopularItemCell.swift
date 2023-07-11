//
//  PopularItemCell.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 23/11/21.
//

import UIKit
import SDWebImage

protocol PopularItemDelegate: AnyObject {
    func updateItems(with items: ListOrderDetailsDto)
}

class PopularItemCell: UICollectionViewCell {
    public lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.clipsToBounds = true
        image.backgroundColor = .clear
        return image
    }()
    
    public lazy var contentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Капучино"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    public lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.text = "Кофейный напиток"
        return label
    }()
    
    public lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "190 с"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = Asset.clientOrange.color
        return label
    }()
    
    private lazy var stepperControl: StepperView = {
        var stepper = StepperView()
        stepper.minimumNumberOfItems = 0
        stepper.additionButtonColor = Asset.clientOrange.color
        stepper.decreaseButtonColor = Asset.clientMain.color
        stepper.delegate = self
        return stepper
    }()
    
    var dish: ListOrderDetailsDto?
    
    weak var delegate: PopularItemDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        contentView.backgroundColor = .clear
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        contentView.addSubview(contentContainer)
        contentView.addSubview(imageView)
        contentView.addSubview(stepperControl)
        contentContainer.addSubview(nameLabel)
        contentContainer.addSubview(descriptionLabel)
        contentContainer.addSubview(priceLabel)
    }
    
    private func setUpConstaints() {
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(imageView.snp.height) //magic line
        }
        contentContainer.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.height.equalTo(imageView.snp.height).multipliedBy(0.88)
            make.centerY.trailing.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
        }
        stepperControl.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(94)
        }
        priceLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    
    func display(cell: ListOrderDetailsDto) {
        dish = cell
        nameLabel.text = cell.name
        descriptionLabel.text = cell.name
        priceLabel.text = "\(cell.price) c"
        imageView.sd_setImage(with: cell.urlImage?.url)
        stepperControl.quantityOfItems = cell.quantity
    }
    
//    func display(cell: DishDTO) {
//        dish = cell
//        nameLabel.text = cell.name
//        priceLabel.text = "\(cell.price) c"
//        descriptionLabel.text = cell.description
//        imageView.sd_setImage(with: cell.imageUrl)
//    }
}

extension PopularItemCell: HidableStepperDelegate {
    func stepperWillHideDecreaseButton() {
        
    }
    
    func stepperWillRevealDecreaseButton() {
        
    }
    
    func updateValue(with count: Int) {
        guard var dish = dish else { return }
        dish.quantity = count
        delegate?.updateItems(with: dish)
    }
}
