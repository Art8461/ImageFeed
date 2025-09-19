//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//


import UIKit

final class SplashViewController: UIViewController {

    private let storage = OAuth2TokenStorage.shared
    private var hasSwitchedToTabBar = false // защита от повторного перехода

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🔹 SplashViewController появился. Токен =", storage.token ?? "nil")

        if let token = storage.token, !token.isEmpty {
            switchToTabBarController()
        } else {
            showAuthController()
        }
    }

    private func switchToTabBarController() {
        guard !hasSwitchedToTabBar else { return } // предотвращаем двойной вызов
        hasSwitchedToTabBar = true

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("❌ Не удалось получить активное окно")
            return
        }

        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        print("✅ TabBarController установлен как rootViewController")
    }

    private func showAuthController() {
        // Создаём AuthViewController через код
        let authVC = AuthViewController()
        authVC.delegate = self

        // Оборачиваем в UINavigationController, чтобы был NavigationBar
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen

        // Показываем модально
        present(navVC, animated: true)
        print("ℹ️ Открыт AuthViewController через код")
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("🔔 Авторизация завершена из AuthViewController")
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}
