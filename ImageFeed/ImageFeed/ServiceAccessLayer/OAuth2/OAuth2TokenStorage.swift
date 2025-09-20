//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenKeychainStorage {

    static let shared = OAuth2TokenKeychainStorage()
    private init() {}

    private let key = "unsplash_access_token"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: key)
        }
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: key)
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }
}
