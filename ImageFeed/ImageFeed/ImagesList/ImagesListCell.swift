//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.08.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Публичные переменные
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlet
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Приватные переменные
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Публичные методы
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
        
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // ImageView
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.clipsToBounds = true
        cellImageView.layer.cornerRadius = 16
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        // Label
        cellTextLabel.textColor = UIColor.white
        cellTextLabel.font = UIFont(name: "SFProText-Regular", size: 13)
        cellTextLabel.numberOfLines = 2
        cellTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellTextLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            cellTextLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            cellTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImageView.trailingAnchor, constant: -8)
        ])
        
        // Like Button
        likeButton.setImage(UIImage(named: "NoActive"), for: .normal)
        likeButton.setImage(UIImage(named: "Active"), for: .selected)
        likeButton.setTitle("", for: .normal)
        likeButton.setTitle("", for: .selected)
        likeButton.tintColor = .clear
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    func configure(with image: UIImage?, text: String, isLiked: Bool) {
        cellImageView.image = image
        cellTextLabel.text = text
        likeButton.isSelected = isLiked
    }
    
    // MARK: - Приватные методы
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0).cgColor, // низ — сплошной
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor  // верх — прозрачный
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 1.0) // снизу
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)   // вверх
        
        cellImageView.layer.addSublayer(gradient)
        self.gradientLayer = gradient
    }
    
    private func updateGradientFrame() {
        gradientLayer?.frame = CGRect(
            x: 0,
            y: cellImageView.bounds.height - 30,
            width: cellImageView.bounds.width,
            height: 30
        )
    }
    
    // MARK: - IBAction
    @IBAction private func didTapLike(_ sender: Any) {
        likeButton.isSelected.toggle()
    }
}
