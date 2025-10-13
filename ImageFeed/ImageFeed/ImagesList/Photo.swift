//
//  Photo.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.10.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.liked_by_user
        self.welcomeDescription = result.description
        
        if let createdAtString = result.created_at {
            let formatter = ISO8601DateFormatter()
            self.createdAt = formatter.date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
    }
}
