//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//


import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔹 SplashViewController загружен")

        // Подписка на уведомление о завершении авторизации
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAuthenticateNotification),
            name: .didAuthenticate,
            object: nil
        )
        print("ℹ️ Подписка на уведомление didAuthenticate установлена")
    }

    @objc private func didAuthenticateNotification() {
        print("🔔 Получено уведомление о завершении авторизации")
        if storage.token != nil {
            print("✅ Пользователь авторизован через кастомный редирект. Токен =", storage.token!)
            switchToTabBarController()
        } else {
            print("⚠️ Токен отсутствует при уведомлении")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🔹 SplashViewController появился. Текущий токен =", storage.token ?? "nil")

        if storage.token != nil {
            print("✅ Токен найден, переключаюсь на TabBar")
            switchToTabBarController()
        } else {
            print("ℹ️ Токен не найден, открываю экран авторизации")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("❌ Не удалось получить активное окно")
            return
        }

        print("➡️ Переключение на TabBarController")
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        print("✅ TabBarController установлен как rootViewController")
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("❌ Ошибка при подготовке AuthViewController")
                return
            }
            viewController.delegate = self
            print("ℹ️ AuthViewController подготовлен и делегат установлен")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("🔔 didAuthenticate вызван из AuthViewController")
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if self.storage.token != nil {
                print("✅ Авторизация успешна, переключаюсь на TabBar. Токен =", self.storage.token!)
                self.switchToTabBarController()
            } else {
                print("⚠️ Токен ещё не успел сохраниться")
            }
        }
    }
}
