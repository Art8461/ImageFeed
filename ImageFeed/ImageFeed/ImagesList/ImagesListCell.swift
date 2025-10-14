//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.08.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Публичные переменные
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - UI элементы
    private let cellImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let cellTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "NoActive")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setImage(UIImage(named: "Active")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btn.tintColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Приватные переменные
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupGradient()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(cellTextLabel)
        contentView.addSubview(likeButton)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ImageView
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Label
            cellTextLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            cellTextLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            cellTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImageView.trailingAnchor, constant: -8),
            
            // Like Button
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        
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
    
    // MARK: - Конфигурация
    func configure(with urlString: String, text: String, isLiked: Bool) {
        cellTextLabel.text = text
        likeButton.isSelected = isLiked
        
        let placeholder = UIImage(named: "Stub")
        
        if let url = URL(string: urlString) {
            cellImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(0.3)), .cacheOriginalImage]
            )
        } else {
            cellImageView.image = placeholder
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = UIImage(named: "Stub")
    }
    
    // MARK: - Actions
    @objc private func didTapLike() {
        likeButton.isSelected.toggle()
    }
}
