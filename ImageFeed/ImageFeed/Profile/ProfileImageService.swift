//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 19.09.2025.
//

import Foundation

final class ProfileImageService {

    static let shared = ProfileImageService()
    private init() {}

    private(set) var avatarURL: String? {
        didSet {
            if let url = avatarURL {
                NotificationCenter.default.post(name: .didUpdateProfileImage, object: url)
            }
        }
    }

    private var task: URLSessionTask?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else { return }
        task?.cancel()
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let avatar = userResult.profileImage.small
                self?.avatarURL = avatar
                completion(.success(avatar))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task?.resume()
    }

    struct UserResult: Codable {
        struct ProfileImage: Codable {
            let small: String
        }
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
}

extension Notification.Name {
    static let didUpdateProfileImage = Notification.Name("didUpdateProfileImage")
}
