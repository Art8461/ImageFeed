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
}
