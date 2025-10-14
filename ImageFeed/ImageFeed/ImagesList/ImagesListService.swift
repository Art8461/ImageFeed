//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 13.10.2025.
//

import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private(set) var isLoading = false
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer { self?.isLoading = false }
            guard let self = self else { return }
            guard let data = data, error == nil else { return }
            
            do {
                let newPhotos = try JSONDecoder().decode([Photo].self, from: data)
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
                print("Ошибка декодирования: \(error)")
            }
        }.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var photo = self.photos[index]
                    photo.isLiked = !photo.isLiked
                    self.photos[index] = photo
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: nil
                    )
                }
                
                completion(.success(()))
            }
        }.resume()
    }
}
