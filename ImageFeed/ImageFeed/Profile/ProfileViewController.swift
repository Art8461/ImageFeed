//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 14.08.2025.
//

import UIKit
import WebKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Элементы
    private let photoProfile: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(resource: .avatar)
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
        label.accessibilityIdentifier = "profile_name_label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNickName: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = "@nickname"
        label.accessibilityIdentifier = "profile_nickname_label"
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
        button.accessibilityIdentifier = "logout button"
        return button
    }()
    
    private let favoritesTitle: UILabel = {
        let label = UILabel()
        label.text = "Избранное"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var favoritesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FavoritePhotoCell.self, forCellWithReuseIdentifier: FavoritePhotoCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Observers (новый API)
    private var profileObserver: NSObjectProtocol?
    private var profileImageObserver: NSObjectProtocol?
    
    // MARK: - Data
    private let profileService = ProfileService.shared
    private let favoritesService = FavoritesService()
    private var favoritePhotos: [Photo] = []
    private var isRefreshingProfile = false
    private var currentUsername: String?
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        // Подписка на обновление профиля
        profileObserver = NotificationCenter.default.addObserver(
            forName: .didUpdateProfile,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let profile = notification.object as? ProfileService.Profile else { return }
            self.updateProfileUI(profile: profile)
        }
        
        // Подписка на обновление аватарки
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: .didUpdateProfileImage,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let urlString = notification.object as? String else { return }
            self.updateAvatar(urlString: urlString)
        }
        
        // Если данные уже есть — обновляем сразу
        if let profile = ProfileService.shared.profile {
            updateProfileUI(profile: profile)
        }
        if let avatar = ProfileImageService.shared.avatarURL {
            updateAvatar(urlString: avatar)
        }
        
        refreshProfileIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshProfileIfNeeded()
    }
    
    // MARK: - Настройка интерфейса
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        view.addSubview(photoProfile)
        view.addSubview(userName)
        view.addSubview(userNickName)
        view.addSubview(descriptionProfile)
        view.addSubview(exitButton)
        view.addSubview(favoritesTitle)
        view.addSubview(favoritesCollection)
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Констрейнты
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoProfile.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoProfile.widthAnchor.constraint(equalToConstant: 70),
            photoProfile.heightAnchor.constraint(equalToConstant: 70),
            
            userName.topAnchor.constraint(equalTo: photoProfile.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            userNickName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userNickName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionProfile.topAnchor.constraint(equalTo: userNickName.bottomAnchor, constant: 8),
            descriptionProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionProfile.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            favoritesTitle.topAnchor.constraint(equalTo: descriptionProfile.bottomAnchor, constant: 24),
            favoritesTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favoritesTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            favoritesCollection.topAnchor.constraint(equalTo: favoritesTitle.bottomAnchor, constant: 12),
            favoritesCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favoritesCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoritesCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Обновления UI
    private func updateAvatar(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        photoProfile.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .avatar),
            options: [
                .transition(.fade(0.3)), // плавное появление
                .cacheOriginalImage       // кеширование
            ],
            completionHandler: { result in
                switch result {
                case .success(let value):
                    print("✅ Аватар успешно загружен: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("[ProfileViewController]: updateAvatar Error - \(error.localizedDescription), URL: \(urlString)")
                }
            }
        )
    }
    
    private func updateProfileUI(profile: ProfileService.Profile) {
        userName.text = profile.name
        userNickName.text = profile.loginName
        descriptionProfile.text = profile.bio
        currentUsername = profile.username
        loadFavorites(username: profile.username)
    }
    
    private func refreshProfileIfNeeded() {
        guard !isRefreshingProfile else { return }
        guard let token = OAuth2TokenKeychainStorage.shared.token else { return }
        isRefreshingProfile = true
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isRefreshingProfile = false
                switch result {
                case .success(let profile):
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    self.updateProfileUI(profile: profile)
                case .failure(let error):
                    print("[ProfileViewController] Failed to refresh profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadFavorites(username: String) {
        favoritesService.reset()
        favoritesService.fetchNextPage(username: username) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let photos):
                self.favoritePhotos = photos
                self.favoritesCollection.reloadData()
            case .failure(let error):
                print("[ProfileViewController] Failed to load favorites: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Действия

    @objc private func exitButtonTapped() {
        let alert = CustomExitAlert()
        alert.modalPresentationStyle = .overFullScreen
        alert.modalTransitionStyle = .crossDissolve
        alert.onConfirmExit = { [weak self] in
            guard self != nil else { return }
            
            // 1️⃣ Очистка токена
            OAuth2TokenKeychainStorage.shared.token = nil
            print("🔹 Пользователь вышел — токен удалён")
            
            // 2️⃣ Очистка cookies и данных WKWebView
            HTTPCookieStorage.shared.removeCookies(since: .distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                        print("🗑 Удалены данные для: \(record.displayName)")
                    }
                }
            }
            
            // 3️⃣ Переход на SplashViewController
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let splashVC = SplashViewController()
            let navVC = UINavigationController(rootViewController: splashVC)
            window.rootViewController = navVC
            window.makeKeyAndVisible()
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favoritePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoritePhotoCell.reuseId,
            for: indexPath
        ) as? FavoritePhotoCell else { return UICollectionViewCell() }
        let photo = favoritePhotos[indexPath.item]
        cell.configure(urlString: photo.thumbImageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = favoritePhotos[indexPath.item]
        guard let url = URL(string: photo.largeImageURL) else { return }
        let single = SingleImageViewController()
        single.fullImageURL = url
        single.photoId = photo.id
        single.isLiked = photo.isLiked
        single.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(single, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let username = currentUsername else { return }
        let threshold = favoritePhotos.count - 4
        if indexPath.item >= threshold {
            favoritesService.fetchNextPage(username: username) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let photos):
                    self.favoritePhotos = photos
                    self.favoritesCollection.reloadData()
                case .failure(let error):
                    print("[ProfileViewController] Failed to load more favorites: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 6 * 2 // two gaps between 3 items
        let width = (collectionView.bounds.width - totalSpacing) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
}
