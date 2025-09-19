//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 14.08.2025.
//

import UIKit
import WebKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Элементы
    private let photoProfile: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "avatar")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userName: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.text = "Имя пользователя"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNickName: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = "@nickname"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionProfile: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.text = "Описание профиля"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: - Публичные методы
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateProfile(_:)),
            name: .didUpdateProfile,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateProfileImage(_:)),
            name: .didUpdateProfileImage,
            object: nil
        )
        
        if let profile = ProfileService.shared.profile {
                    updateProfileUI(profile: profile)
                }
                if let avatar = ProfileImageService.shared.avatarURL {
                    updateAvatar(urlString: avatar)
                }
    }
    //скрываем навигейшн
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Настройка интерфейса
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        view.addSubview(photoProfile)
        view.addSubview(userName)
        view.addSubview(userNickName)
        view.addSubview(descriptionProfile)
        view.addSubview(exitButton)
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
    }
    
    // MARK: - Констрейнты
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фото профиля
            photoProfile.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoProfile.widthAnchor.constraint(equalToConstant: 70),
            photoProfile.heightAnchor.constraint(equalToConstant: 70),
            
            // Имя пользователя
            userName.topAnchor.constraint(equalTo: photoProfile.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Никнейм
            userNickName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userNickName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Описание профиля
            descriptionProfile.topAnchor.constraint(equalTo: userNickName.bottomAnchor, constant: 8),
            descriptionProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionProfile.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Кнопка выхода
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func didUpdateProfile(_ notification: Notification) {
        guard let profile = notification.object as? ProfileService.Profile else { return }
        updateProfileUI(profile: profile)
    }
    
    @objc private func didUpdateProfileImage(_ notification: Notification) {
            guard let urlString = notification.object as? String else { return }
            updateAvatar(urlString: urlString)
        }
    
    private func updateAvatar(urlString: String) {
            guard let url = URL(string: urlString) else { return }
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.photoProfile.image = image
                    }
                }
            }
        }
    
    private func updateProfileUI(profile: ProfileService.Profile) {
        userName.text = profile.name
        userNickName.text = profile.loginName
        descriptionProfile.text = profile.bio
    }
    
    // MARK: - Действия
    @objc private func exitButtonTapped() {
        // 1️⃣ Очистка токена
        OAuth2TokenStorage.shared.token = nil
        print("🔹 Пользователь вышел — токен удалён")
        
        // 2️⃣ Очистка cookies и данных WebView
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    print("🗑 Удалены данные для: \(record.displayName)")
                }
            }
        }
        // 2️⃣ Переключение на SplashViewController
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let splashVC = SplashViewController()
        let navVC = UINavigationController(rootViewController: splashVC)
        window.rootViewController = navVC
        window.makeKeyAndVisible()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
