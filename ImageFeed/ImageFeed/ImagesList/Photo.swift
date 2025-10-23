//
//  Photo.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.10.2025.
//

import Foundation

struct Photo: Decodable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool

    private enum CodingKeys: String, CodingKey {
        case id, description, width, height, urls, liked_by_user, created_at
    }

    private enum UrlsKeys: String, CodingKey {
        case thumb, full
    }

    init(
        id: String,
        size: CGSize,
        createdAt: Date?,
        description: String?,
        thumbImageURL: String,
        largeImageURL: String,
        isLiked: Bool
    ) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.description = description
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }

    // Decodable init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        let width = try container.decode(Int.self, forKey: .width)
        let height = try container.decode(Int.self, forKey: .height)
        size = CGSize(width: width, height: height)
        isLiked = try container.decode(Bool.self, forKey: .liked_by_user)

        let urlsContainer = try container.nestedContainer(keyedBy: UrlsKeys.self, forKey: .urls)
        thumbImageURL = try urlsContainer.decode(String.self, forKey: .thumb)
        largeImageURL = try urlsContainer.decode(String.self, forKey: .full)

        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .created_at) {
            createdAt = Photo.iso8601Formatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
    }

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()

    // MARK: - Copying with modification
    func withToggledLike() -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            description: description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: !isLiked
        )
    }

    func withLike(_ isLiked: Bool) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            description: description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}
