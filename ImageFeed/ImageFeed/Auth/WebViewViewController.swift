//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 29.08.2025.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewControllerDidAuthenticate(_ vc: WebViewViewController)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    private let webView = WKWebView()
    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .clear
        pv.progressTintColor = .black
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔹 WebViewViewController загружен")
        setupViews()
        loadAuthPage()
        setupObservers()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        webView.navigationDelegate = self
        progressView.progress = 0
        progressView.tintColor = .systemBlue
        print("ℹ️ WKWebView и прогрессбар добавлены, делегат назначен")
    }
    
    // MARK: - KVO
    private func setupObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() {
        let progress = Float(webView.estimatedProgress)
        progressView.progress = progress
        let shouldHide = fabs(webView.estimatedProgress - 1.0) <= 0.0001
        progressView.isHidden = shouldHide
        
        // Логирование прогресса
        print("📊 Прогресс загрузки страницы: \(progress)")
        if shouldHide {
            print("✅ Прогресс завершён, скрываю прогрессбар")
        }
    }
    
    // MARK: - Load Auth Page
    private func loadAuthPage() {
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = components.url else {
            print("❌ Ошибка: не удалось сформировать URL авторизации")
            return
        }
        print("➡️ Загружаем страницу авторизации Unsplash: \(url.absoluteString)")
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - Extract Code
    private func extractCode(from url: URL) -> String? {
        guard url.absoluteString.starts(with: Constants.redirectURI) else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let code = components?.queryItems?.first(where: { $0.name == "code" })?.value
        if code != nil {
            print("ℹ️ Извлекаем код из redirect URI: \(code!)")
        }
        return code
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        print("🔹 Навигация на URL: \(url.absoluteString)")
        
        // Проверяем, есть ли код авторизации
        if let code = extractCode(from: url) {
            handleAuthCode(code, decisionHandler: decisionHandler)
            return
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - Private helpers
    private func handleAuthCode(
        _ code: String,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print("✅ Найден код авторизации: \(code)")
        
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            switch result {
            case .success(let token):
                print("✅ OAuth токен получен: \(token)")
                OAuth2TokenStorage.shared.token = token
                DispatchQueue.main.async {
                    self?.delegate?.webViewViewControllerDidAuthenticate(self!)
                }
            case .failure(let error):
                print("❌ Ошибка при получении OAuth токена: \(error)")
            }
        }
        
        decisionHandler(.cancel)
    }
}
