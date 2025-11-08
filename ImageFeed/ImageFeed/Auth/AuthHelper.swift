//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 29.08.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
        print("🔹 AuthHelper инициализирован с конфигурацией:")
        print("   - authURLString: \(configuration.authURLString)")
        print("   - redirectURI: \(configuration.redirectURI)")
        print("   - accessKey: \(configuration.accessKey)")
        print("   - accessScope: \(configuration.accessScope)")
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            print("❌ Ошибка: не удалось создать URL для авторизации")
            return nil
        }
        print("➡️ Создан URL запроса: \(url.absoluteString)")
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            print("❌ Ошибка: не удалось создать URLComponents из строки: \(configuration.authURLString)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("❌ Ошибка: не удалось создать URL из компонентов")
            return nil
        }
        
        return url
    }
    
    func code(from url: URL) -> String? {
        // Проверка для пути /oauth/authorize/native
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            print("✅ Код найден через путь /oauth/authorize/native: \(codeItem.value ?? "nil")")
            return codeItem.value
        }
        
        // Проверка для redirect URI (imagefeed://auth)
        if url.absoluteString.starts(with: configuration.redirectURI),
           let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            print("✅ Код найден через redirect URI: \(codeItem.value ?? "nil")")
            return codeItem.value
        }
        
        return nil
    }
}

