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

        task?.cancel() // отменяем предыдущий запрос
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "ProfileImageService", code: 0, userInfo: nil)))
                return
            }

            do {
                let result = try JSONDecoder().decode(UserResult.self, from: data)
                let avatar = result.profileImage.small
                self?.avatarURL = avatar
                completion(.success(avatar))
            } catch {
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
