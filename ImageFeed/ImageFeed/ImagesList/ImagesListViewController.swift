//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 12.08.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let logger = AppLogger.shared

    private var isOpeningSingleImage = false // 🔒 Защита от повторных нажатий

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        return tv
    }()
    private let refreshControl = UIRefreshControl()

    private let imagesListService = ImagesListService.shared
    private var observer: NSObjectProtocol?
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug("ImagesListViewController viewDidLoad")
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        setupTableView()
        setupObservers()
        imagesListService.fetchPhotosNextPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.debug("ImagesListViewController viewWillAppear")
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupObservers() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos

        if oldCount != newCount {
            logger.info("Adding \(newCount - oldCount) new photos to tableView")
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    @objc private func refreshTriggered() {
        guard !imagesListService.isLoading else {
            refreshControl.endRefreshing()
            return
        }
        imagesListService.reset()
        photos = []
        tableView.reloadData()
        imagesListService.fetchPhotosNextPage { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.configure(
            thumbURL: photo.thumbImageURL,
            highURL: photo.regularImageURL,
            text: text,
            isLiked: photo.isLiked
        )
        cell.delegate = self
        logger.debug("Configured cell for row \(indexPath.row), photoId=\(photo.id)")
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else { return UITableViewCell() }

        configCell(for: cell, with: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let photo = photos[indexPath.row]
        logger.debug("Tapped photoId=\(photo.id) at row \(indexPath.row)")

        guard let fullImageURL = URL(string: photo.largeImageURL) else {
            logger.warning("Invalid fullImageURL for photoId=\(photo.id)")
            return
        }

        let singleImageVC = SingleImageViewController()
        singleImageVC.fullImageURL = fullImageURL
        singleImageVC.photoId = photo.id
        singleImageVC.isLiked = photo.isLiked
        singleImageVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(singleImageVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageWidth = tableView.bounds.width - 16 * 2
        let imageHeight = photo.size.height * (imageWidth / photo.size.width)
        return imageHeight + 12 * 2
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count && !imagesListService.isLoading {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        logger.info("Tapping like for photoId=\(photo.id), current isLiked=\(photo.isLiked)")

        // Показываем блокирующий HUD
        UIBlockingProgressHUD.show()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // Скрываем HUD
                UIBlockingProgressHUD.dismiss()

                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    self.logger.info("Successfully changed like for photoId=\(photo.id) to \(self.photos[indexPath.row].isLiked)")
                case .failure(let error):
                    self.logger.error("Failed to change like for photoId=\(photo.id): \(error)")
                    self.showLikeError(error: error)
                }
            }
        }
    }
    
    private func showLikeError(error: Error) {
        let alert = UIAlertController(
            title: "Не удалось поставить лайк",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

