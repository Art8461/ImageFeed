//
//  AppLogger.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 21.10.2025.
//


import Logging

enum AppLogger {
    static let shared: Logger = {
        var logger = Logger(label: "com.artem.ImageFeed")
        logger.logLevel = .debug
        return logger
    }()
}
