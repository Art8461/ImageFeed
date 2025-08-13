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
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        
        // Отключение констрейнов
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // Констрейны таблицы
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @IBOutlet weak var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        let image = UIImage(named: imageName)
        let text = dateFormatter.string(from: Date())
        
        // Лайк включён для чётных индексов, выключен для нечётных
        let isLiked = indexPath.row % 2 == 0

        cell.configure(with: image, text: text, isLiked: isLiked)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1
        
        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath) // 3
        return imageListCell // 4
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Получаем имя картинки из массива
        let imageName = photosName[indexPath.row]
        
        // Получаем UIImage
        guard let image = UIImage(named: imageName) else {
            return 200 // стандартная высота на случай ошибки
        }
        
        // Ширина imageView = ширина таблицы минус отступы
        let horizontalInset: CGFloat = 16 * 2 // если есть отступы слева и справа
        let imageViewWidth = tableView.bounds.width - horizontalInset
        
        // Вычисляем высоту imageView по пропорциям
        let imageHeight = image.size.height * (imageViewWidth / image.size.width)
        
        // Добавляем вертикальные отступы сверху и снизу (если есть)
        let verticalInset: CGFloat = 12 * 2
        
        return imageHeight + verticalInset
    }

}

