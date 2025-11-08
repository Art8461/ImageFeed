//
//  Constants.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 28.08.2025.
//

import Foundation

enum Constants {
    static let accessKey = "YFJSwQsXo7OtGjQG4ti2tRRVffpczgpEOSGNBNTQYp0"
    static let secretKey = "ktqiiceXvhBCAwHbPTCOvPhnQC7gHkFalR93lFPFNK4"
    static let redirectURI = "imagefeed://auth"
    static let accessScope = "public+read_user+write_likes"

    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}
