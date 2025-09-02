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

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("❌ Ошибка: неверный URL для запроса токена")
            completion(.failure(NSError(domain: "OAuth2", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        print("➡️ Формируем POST-запрос для получения токена")
        
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
        let bodyString = bodyComponents.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        print("ℹ️ Тело запроса: \(bodyString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Сетевая ошибка: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Ошибка: нет HTTP-ответа")
                DispatchQueue.main.async { completion(.failure(NSError(domain: "OAuth2", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"]))) }
                return
            }
            
            print("ℹ️ HTTP статус код:", httpResponse.statusCode)
            
            guard let data = data else {
                print("❌ Ошибка: нет данных в ответе")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                }
                return
            }

            print("📩 Ответ Unsplash: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = tokenResponse.accessToken
                OAuth2TokenStorage.shared.token = accessToken
                print("✅ Токен успешно получен:", accessToken)
                DispatchQueue.main.async { completion(.success(accessToken)) }
            } catch {
                print("❌ Ошибка при декодировании токена:", error)
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token parsing failed: \(error)"])))
                }
            }
        }
        task.resume()
    }
}
