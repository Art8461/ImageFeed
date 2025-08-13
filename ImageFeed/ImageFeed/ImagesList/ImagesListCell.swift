//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.08.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var cellTextLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.masksToBounds = true
        // Прозрачный фон ячейки
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none // Отключаем выделение
        
        // Настраиваем внешний вид ImageView
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.clipsToBounds = true
        cellImageView.layer.cornerRadius = 16
        
        // Отключение констрейнов у ImageView
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        // Констрейны для ImageView
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        // Настройка текста
        cellTextLabel.textColor = UIColor.white
        cellTextLabel.font = UIFont(name: "SFProText-Regular", size: 13)
        cellTextLabel.numberOfLines = 2
        // Отключение констрейнов у cellTextLabel
        cellTextLabel.translatesAutoresizingMaskIntoConstraints = false
        // Констрейны для cellTextLabel
        NSLayoutConstraint.activate([
            cellTextLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            cellTextLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            cellTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImageView.trailingAnchor, constant: -8)
        ])
        
        // Настраиваем кнопки лайка
        likeButton.setImage(UIImage(named: "NoActive"), for: .normal)
        likeButton.setImage(UIImage(named: "Active"), for: .selected)
        likeButton.setTitle("", for: .normal)
        likeButton.setTitle("", for: .selected)
        
        likeButton.tintColor = .clear

        // Отключение констрейнов у likeButton
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        // Констрейны для likeButton
        NSLayoutConstraint.activate([
                likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                likeButton.widthAnchor.constraint(equalToConstant: 44),
                likeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    @IBAction private func didTapLike(_ sender: Any) {
        likeButton.isSelected.toggle() // переключаем состояние
    }
    
    // Метод для конфигурации ячейки
    func configure(with image: UIImage?, text: String, isLiked: Bool) {
        cellImageView.image = image
        cellTextLabel.text = text
        likeButton.isSelected = isLiked
    }
}
