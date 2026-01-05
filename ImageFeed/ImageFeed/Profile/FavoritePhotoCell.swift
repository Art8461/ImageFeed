//
//  FavoritePhotoCell.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 05.01.2026.
//

import UIKit
import Kingfisher

final class FavoritePhotoCell: UICollectionViewCell {
    static let reuseId = "FavoritePhotoCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
    func configure(urlString: String) {
        guard let url = URL(string: urlString) else {
            imageView.image = UIImage(resource: .stub)
            return
        }
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .stub),
            options: [.transition(.fade(0.2)), .cacheOriginalImage]
        )
    }
}

