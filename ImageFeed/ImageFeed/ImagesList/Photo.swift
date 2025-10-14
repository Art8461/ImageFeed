//
//  Photo.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.10.2025.
//

import Foundation
import UIKit

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
            let formatter = ISO8601DateFormatter()
            createdAt = formatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
    }
}
