//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.10.2025.
//

import UIKit

struct PhotoResult: Decodable {
    let id: String
    let created_at: String?
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let liked_by_user: Bool
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}
