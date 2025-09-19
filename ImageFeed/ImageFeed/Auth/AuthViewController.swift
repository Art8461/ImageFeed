//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 29.08.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    let authLogo: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "AuthLogo")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let enter: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Войти", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(UIColor(red: 0x1A/255, green: 0x1B/255, blue: 0x22/255, alpha: 1), for: .normal)
        btn.backgroundColor = UIColor(red: 0xFF/255, green: 0xFF/255, blue: 0xFF/255, alpha: 0.8)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        print("🔹 AuthViewController loaded")
                
        view.addSubview(authLogo)
        view.addSubview(enter)
        enter.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
    }
    // Констрейнты
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authLogo.widthAnchor.constraint(equalToConstant: 60),
            authLogo.heightAnchor.constraint(equalToConstant: 60),
            
            enter.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enter.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            enter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -124),
            enter.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Кнопка "Войти"
    @objc private func enterButtonTapped() {
        print("➡️ Нажата кнопка Войти")
        let webVC = WebViewViewController()
        webVC.delegate = self
        self.navigationController?.pushViewController(webVC, animated: true)
        print("➡️ Открыт WebViewViewController")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidAuthenticate(_ vc: WebViewViewController) {
        print("✅ Пользователь успешно авторизовался в WebView")
        self.delegate?.didAuthenticate(self)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("⚠️ Пользователь отменил авторизацию в WebView")
        vc.dismiss(animated: true)
    }
}
