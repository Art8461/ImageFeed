//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//


import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private var hasSwitchedToTabBar = false // защита от повторного перехода

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🔹 SplashViewController появился. Токен =", storage.token ?? "nil")

        if let token = storage.token, !token.isEmpty {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        print("✅ TabBarController установлен как rootViewController")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier,
           let nav = segue.destination as? UINavigationController,
           let authVC = nav.viewControllers.first as? AuthViewController {
            authVC.delegate = self
            print("ℹ️ AuthViewController подготовлен и делегат установлен")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("🔔 Авторизация завершена из AuthViewController")
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}
