//
//  ImageFeedTestsUI.swift
//  ImageFeedTestsUI
//
//  Created by Artem Kuzmenko on 08.11.2025.
//

import XCTest

final class ImageFeedTestsUI: XCTestCase {

    private let app = XCUIApplication() // переменная приложения
        
        override func setUpWithError() throws {
            continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
            
            app.launch() // запускаем приложение перед каждым тестом
        }
        
        func testAuth() throws {
                // Нажимаем кнопку "Войти"
                let enterButton = app.buttons["Войти"]
                XCTAssertTrue(enterButton.waitForExistence(timeout: 5))
                enterButton.tap()
                
                // Ожидаем появления WebView
                let webView = app.webViews["UnsplashWebView"]
                XCTAssertTrue(webView.waitForExistence(timeout: 10))

                // Ждем загрузки страницы авторизации
                sleep(3)

                let loginTextField = webView.descendants(matching: .textField).element
                XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
                
                loginTextField.tap()
                loginTextField.typeText("ваш логин")
                webView.swipeUp()
                
                let passwordTextField = webView.descendants(matching: .secureTextField).element
                XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
                
                passwordTextField.tap()
                passwordTextField.typeText("ваш пароль")
                webView.swipeUp()
                
                // Нажимаем кнопку "Войти" в WebView
                let loginButton = webView.buttons["Login"]
                XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
                loginButton.tap()
                
                // Ожидаем появления таблицы с изображениями после авторизации
                let tablesQuery = app.tables
                let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
                
                XCTAssertTrue(cell.waitForExistence(timeout: 10))
            }
    
        func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let likeButtonCell = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        // Нажимаем на кнопку лайка (может быть "NoActive" или "like button on")
        let likeButton = likeButtonCell.buttons.firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 2))
        likeButton.tap()
        
        sleep(2)
        
        // Нажимаем на ячейку, чтобы открыть полноэкранное изображение
        likeButtonCell.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let exitSinglImage = app.buttons["exitSinglImage"]
        XCTAssertTrue(exitSinglImage.waitForExistence(timeout: 2))
        exitSinglImage.tap()
    }
    
        func testProfile() throws {
        sleep(20)
        app.tabBars.buttons["ProfileTab"].tap()
       
            XCTAssertTrue(app.staticTexts["profile_name_label"].exists)
            XCTAssertTrue(app.staticTexts["profile_nickname_label"].exists)
        
        app.buttons["logout button"].tap()
        
        // Ищем кнопку "Yes" напрямую, так как это кастомный алерт
        let yesButton = app.buttons["Да"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 2))
        yesButton.tap()
    }
    }
