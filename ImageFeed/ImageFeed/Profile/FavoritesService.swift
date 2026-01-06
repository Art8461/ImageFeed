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
    private var currentPage = 0
    private let perPage = 30
    private var hasMore = true
    
    func reset() {
        likedPhotos = []
        isLoading = false
        currentPage = 0
        hasMore = true
    }
    
    func fetchNextPage(username: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isLoading, hasMore else { return }
        isLoading = true
        currentPage += 1
        
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
            URLQueryItem(name: "page", value: "\(currentPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
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
                self.likedPhotos.append(contentsOf: photos)
                if photos.count < self.perPage { self.hasMore = false }
                DispatchQueue.main.async { completion(.success(self.likedPhotos)) }
            } catch {
                self.logger.error("[FavoritesService] Decoding error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

