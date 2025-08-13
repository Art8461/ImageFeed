//
//  ViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 12.08.2025.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200 //фиксированная высота ячейки
        tableView.separatorStyle = .none //Разделительные линии убраны
        
        // Отключение констрейнов
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // Констрейны таблицы
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @IBOutlet weak var tableView: UITableView!
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configCell(for cell: ImagesListCell) {
        let image = UIImage(named: "0")
        let text = "Пример текста"
        let isLiked = false

        cell.configure(with: image, text: text, isLiked: isLiked)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1
        
        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }
        
        configCell(for: imageListCell) // 3
        return imageListCell // 4
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

