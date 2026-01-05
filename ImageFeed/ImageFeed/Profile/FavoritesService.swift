//
//  FavoritesService.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 05.01.2026.
//

import Foundation

final class FavoritesService {
    private let logger = AppLogger.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private(set) var likedPhotos: [Photo] = []
    private var isLoading = false
    
    func fetchFavorites(username: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isLoading else { return }
        isLoading = true
        
        guard let token = OAuth2TokenKeychainStorage.shared.token else {
            logger.warning("[FavoritesService] User not authorized")
            isLoading = false
            completion(.failure(NSError(domain: "FavoritesService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not authorized"])))
            return
        }
        
        var components = URLComponents(
            url: Constants.defaultBaseURL.appendingPathComponent("users/\(username)/likes"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "30")
        ]
        
        guard let url = components?.url else {
            isLoading = false
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error {
                self.logger.error("[FavoritesService] Network error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data else {
                let err = NetworkError.urlSessionError
                self.logger.warning("[FavoritesService] Data is nil")
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            
            do {
                let photos = try self.decoder.decode([Photo].self, from: data)
                self.likedPhotos = photos
                DispatchQueue.main.async { completion(.success(photos)) }
            } catch {
                self.logger.error("[FavoritesService] Decoding error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

