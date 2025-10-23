//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.10.2025.
//

import Foundation

final class ImagesListService {
    private let logger = AppLogger.shared
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private let decoder = JSONDecoder() // ✅ Один экземпляр на весь сервис
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private(set) var isLoading = false
    
    // MARK: - Fetch Photos
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&client_id=\(Constants.accessKey)"
        
        guard let url = URL(string: urlString) else {
            logger.debug("fetchPhotosNextPage called, isLoading=\(isLoading)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer { self?.isLoading = false }
            guard let self else { return }
            
            if let error {
                self.logger.error("[ImagesListService.fetchPhotosNextPage]: [Network Error] [page=\(nextPage)] \(error)")
                return
            }
            
            guard let data else {
                self.logger.warning("[fetchPhotosNextPage] Data is nil on page \(nextPage)")
                return
            }
            
            do {
                let newPhotos = try self.decoder.decode([Photo].self, from: data) // ✅ используем общий decoder
                let uniquePhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains(where: { $0.id == newPhoto.id })
                }
                
                guard !uniquePhotos.isEmpty else { return }
                self.photos.append(contentsOf: uniquePhotos)
                self.lastLoadedPage = nextPage
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: nil
                    )
                }
            } catch {
                let jsonString = String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data"
                self.logger.error("""
                [ImagesListService.fetchPhotosNextPage]: [Decoding Error] [page=\(nextPage)]: \(error)
                [Raw Data]: \(jsonString)
                """)
            }
        }.resume()
    }
    
    // MARK: - Change Like
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let accessToken = OAuth2TokenKeychainStorage.shared.token else {
            logger.warning("[changeLike] User not authorized")
            completion(.failure(NSError(domain: "ImagesListService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not authorized"])))
            return
        }
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ImagesListService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        logger.debug("[changeLike] Sending \(isLike ? "POST" : "DELETE") request for photoId \(photoId)")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self else { return }

            if let error {
                logger.error("[changeLike] Network error for photoId \(photoId): \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                logger.error("[changeLike] Invalid response for photoId \(photoId), statusCode: \(code)")
                completion(.failure(NSError(domain: "ImagesListService", code: code,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            DispatchQueue.main.async {
                self.logger.info("[changeLike] Photo \(photoId) successfully \(isLike ? "liked" : "unliked")")
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var photo = self.photos[index]
                    photo.isLiked = isLike
                    self.photos[index] = photo

                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
                completion(.success(()))
            }
        }.resume()
    }
}
