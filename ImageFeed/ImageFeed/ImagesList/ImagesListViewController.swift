//
//  ViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 12.08.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Публичные переменные
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Приватные переменные
    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    // MARK: - Публичные методы
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        tableView.separatorStyle = .none // Разделительные линии убраны
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // Отключение констрейнов
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Констрейны таблицы
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    // MARK: - Приватные методы
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        let image = UIImage(named: imageName)
        let text = dateFormatter.string(from: Date())
        
        // Лайк включён для чётных индексов, выключен для нечётных
        let isLiked = indexPath.row % 2 == 0
        cell.configure(with: image, text: text, isLiked: isLiked)
    }
    
    
    // MARK: - IBAction
    // (Пока пусто — добавить при необходимости)
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Реализация по необходимости
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row]
        
        guard let image = UIImage(named: imageName) else {
            return 200 // стандартная высота на случай ошибки
        }
        
        let horizontalInset: CGFloat = 16 * 2
        let imageViewWidth = tableView.bounds.width - horizontalInset
        let imageHeight = image.size.height * (imageViewWidth / image.size.width)
        
        let verticalInset: CGFloat = 12 * 2
        return imageHeight + verticalInset
    }
}
