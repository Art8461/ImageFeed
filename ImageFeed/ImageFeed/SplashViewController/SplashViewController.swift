//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 01.09.2025.
//


import UIKit

final class SplashViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenKeychainStorage.shared
    private var hasSwitchedToTabBar = false // защита от повторного перехода

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🔹 SplashViewController появился. Токен =", storage.token ?? "nil")

        if let token = storage.token, !token.isEmpty {
            fetchProfile(token: token)
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
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    
                    switch result {
                    case .success(let profile):
                        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                        }
                        // профиль обновляется в ProfileService.shared.profile внутри fetchProfile
                        self?.switchToTabBarController() // только после загрузки
                    case .failure(let error):
                        print("❌ Ошибка загрузки профиля: \(error)")
                        self?.handleProfileLoadFailure(error: error)
                    }
                }
            }
        }
    
    private func handleProfileLoadFailure(error: Error) {
        // 401/403 — не стираем токен, даём выбор: повторить или вручную выйти и авторизоваться заново
        if case NetworkError.httpStatusCode(let code) = error, (code == 401 || code == 403) {
            let alert = UIAlertController(
                title: "Доступ отклонён",
                message: "Сервер вернул код \(code). Можно повторить попытку или войти заново.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                guard let token = self?.storage.token else { return }
                self?.fetchProfile(token: token)
            })
            alert.addAction(UIAlertAction(title: "Войти заново", style: .destructive) { [weak self] _ in
                self?.storage.token = nil
                self?.hasSwitchedToTabBar = false
                self?.showAuthController()
            })
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            present(alert, animated: true)
            return
        }

        // временные сетевые/другие ошибки — сохраняем токен и даём шанс повторить
        let message: String
        if case NetworkError.urlRequestError(let underlying) = error {
            message = underlying.localizedDescription
        } else {
            message = "Не удалось загрузить профиль. Проверьте подключение к интернету и попробуйте ещё раз."
        }
        
        let alert = UIAlertController(
            title: "Ошибка загрузки профиля",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let token = self?.storage.token else { return }
            self?.fetchProfile(token: token)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
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
            guard let token = self?.storage.token else { return }
            self?.fetchProfile(token: token)
        }
    }
}
