//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 12.08.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Запуск сцены
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let splashVC = SplashViewController()
        let navVC = UINavigationController(rootViewController: splashVC) // <-- вот тут
        window.rootViewController = navVC
        window.makeKeyAndVisible()
    }

    // MARK: - Обработка редиректа OAuth
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }

        // Проверяем, что это редирект с Unsplash
        if url.scheme == "imagefeed", let code = extractCode(from: url) {
            OAuth2Service.shared.fetchOAuthToken(code) { result in
                switch result {
                case .success(let token):
                    print("✅ OAuth токен получен: \(token)")
                    // Уведомляем, что пользователь авторизовался
                    NotificationCenter.default.post(name: .didAuthenticate, object: nil)
                case .failure(let error):
                    print("❌ Ошибка OAuth: \(error)")
                }
            }
        }
    }

    private func extractCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }

    // MARK: - Стандартные методы UISceneDelegate
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

// MARK: - Уведомление о логине
extension Notification.Name {
    static let didAuthenticate = Notification.Name("didAuthenticate")
}
