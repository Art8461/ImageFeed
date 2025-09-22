//
//  CustomExitAlert.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 20.09.2025.
//


import UIKit

final class CustomExitAlert: UIViewController {
    
    // MARK: - UI Элементы
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.8)
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Пока, пока!"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Уверены, что хотите выйти?"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Да", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let noButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нет", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let buttonSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let verticalButtonSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Callback
    var onConfirmExit: (() -> Void)?
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(yesButton)
        containerView.addSubview(noButton)
        
        containerView.addSubview(buttonSeparator)
        containerView.addSubview(verticalButtonSeparator)
        
        yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 270),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            yesButton.topAnchor.constraint(equalTo: buttonSeparator.bottomAnchor),
            yesButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            yesButton.trailingAnchor.constraint(equalTo: containerView.centerXAnchor),
            yesButton.heightAnchor.constraint(equalToConstant: 44),
            yesButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            noButton.topAnchor.constraint(equalTo: buttonSeparator.bottomAnchor),
            noButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor),
            noButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            noButton.heightAnchor.constraint(equalToConstant: 44),
            noButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Линия горизонтальная между сообщением и кнопками
            buttonSeparator.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            buttonSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Линия вертикальная между кнопками
            verticalButtonSeparator.topAnchor.constraint(equalTo: buttonSeparator.bottomAnchor),
            verticalButtonSeparator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            verticalButtonSeparator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            verticalButtonSeparator.widthAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Действия кнопок
    @objc private func yesTapped() {
        dismiss(animated: true) {
            self.onConfirmExit?()
        }
    }
    
    @objc private func noTapped() {
        dismiss(animated: true)
    }
}
