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
            
            // a)
            if self.currentCode == code {
                print("⚠️ Запрос с кодом \(code) уже выполняется, добавляем completion")
                self.currentCompletions.append(completion)
                return
            }

            // b)
            self.currentCode = code
            self.currentCompletions = [completion]
            print("➡️ Старт fetchOAuthToken для кода: \(code)")

            self.performNetworkCall(code: code) { result in
                // c)
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
            completion(.failure(NetworkError.invalidRequest))
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

        let task = URLSession.shared.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                let accessToken = tokenResponse.accessToken
                OAuth2TokenKeychainStorage.shared.token = accessToken
                completion(.success(accessToken))
            case .failure(let error):
                print("[OAuth2Service]: fetchOAuthToken Error - \(error.localizedDescription), код: \(code)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
