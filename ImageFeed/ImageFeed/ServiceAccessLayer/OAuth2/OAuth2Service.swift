//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private var currentCode: String?
    private var currentCompletions: [(Result<String, Error>) -> Void] = []
    private let queue = DispatchQueue(label: "OAuth2Service.Queue", attributes: .concurrent)

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async(flags: .barrier) {
            
            // a) Если запрос с этим кодом уже выполняется — подписываем новый completion
            if self.currentCode == code {
                print("⚠️ Запрос с кодом \(code) уже выполняется, добавляем completion")
                self.currentCompletions.append(completion)
                return
            }

            // b) Новый код — сбрасываем старые задачи и запускаем новый запрос
            self.currentCode = code
            self.currentCompletions = [completion]
            print("➡️ Старт fetchOAuthToken для кода: \(code)")

            self.performNetworkCall(code: code) { result in
                // c) Обработка результата: вызываем все completion
                self.queue.async(flags: .barrier) {
                    let completions = self.currentCompletions
                    self.currentCompletions = []
                    self.currentCode = nil

                    DispatchQueue.main.async {
                        completions.forEach { $0(result) }
                    }
                }
            }
        }
    }

    // Сетевой вызов к Unsplash
    private func performNetworkCall(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "OAuth2", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyComponents = [
            "client_id=\(Constants.accessKey)",
            "client_secret=\(Constants.secretKey)",
            "redirect_uri=\(Constants.redirectURI)",
            "code=\(code)",
            "grant_type=authorization_code"
        ]
        request.httpBody = bodyComponents.joined(separator: "&").data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "OAuth2", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = tokenResponse.accessToken
                OAuth2TokenStorage.shared.token = accessToken
                completion(.success(accessToken))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
