//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//

import Foundation

final class OAuth2TokenStorage {

    static let shared = OAuth2TokenStorage()
    
    private init() {}

    private let tokenKey = "OAuth2Token"
    private let defaults = UserDefaults.standard

    var token: String? {
        get {
            let value = defaults.string(forKey: tokenKey)
            print("🔹 Читаю токен из UserDefaults:", value ?? "nil")
            return value
        }
        set {
            defaults.set(newValue, forKey: tokenKey)
            print("✅ Токен сохранён:", newValue ?? "nil")
        }
    }
}
