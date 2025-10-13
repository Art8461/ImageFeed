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
    private var isLoading = false
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        lastLoadedPage += 1
        let urlString = "https://api.unsplash.com/photos?page=\(lastLoadedPage)&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer { self?.isLoading = false }
            
            guard let self = self else { return }
            guard let data = data, error == nil else {
                print("Ошибка загрузки: \(String(describing: error))")
                return
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодирования: \(error)")
            }
        }
        task.resume()
    }
}
