//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 19.09.2025.
//

import Foundation

final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    
    private init() {}
    
    private(set) var profile: Profile?{
        didSet {
            NotificationCenter.default.post(name: .didUpdateProfile, object: profile)
        }
    }
    // MARK: - Модель для декодирования ответа от Unsplash
    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    
    // MARK: - Модель для UI
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(from result: ProfileResult) {
            self.username = result.username
            self.name = [result.firstName, result.lastName].compactMap { $0 }.joined(separator: " ")
            self.loginName = "@\(result.username)"
            self.bio = result.bio
        }
    }
    
    // MARK: - Метод создания URLRequest
    private func makeRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Метод для получения профиля
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
extension Notification.Name {
    static let didUpdateProfile = Notification.Name("didUpdateProfile")
}
