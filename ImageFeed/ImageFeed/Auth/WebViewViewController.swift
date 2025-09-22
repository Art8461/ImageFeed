//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 29.08.2025.
//

import UIKit
import WebKit

// MARK: - Delegate
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewControllerDidAuthenticate(_ vc: WebViewViewController)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    func webViewViewController(_ vc: WebViewViewController, didFailWithError error: Error)
}

// MARK: - Main Class
final class WebViewViewController: UIViewController {

    // MARK: - UI Elements
    private let webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .clear
        pv.progressTintColor = .black
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    // MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?
    private var progressObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔹 WebViewViewController загружен")
        setupViews()
        setupCustomBackButton()
        setupObservers()
        loadAuthPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground() // прозрачный фон
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear // убираем линию-тень
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(progressView)

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

    private func setupCustomBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "BackwardBlack"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - KVO (новое API)
    private func setupObservers() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            self.updateProgress()
        }
    }

    private func updateProgress() {
        let progress = Float(webView.estimatedProgress)
        progressView.progress = progress
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
        print("📊 Прогресс загрузки страницы: \(progress)")
    }

    // MARK: - Load Auth Page
    private func loadAuthPage() {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/authorize") else {
            print("❌ Ошибка: не удалось создать URLComponents")
            return
        }

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

        if let code = code {
            print("ℹ️ Извлекаем код из redirect URI: \(code)")
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

        if let code = extractCode(from: url) {
            handleAuthCode(code, decisionHandler: decisionHandler)
            return
        }

        decisionHandler(.allow)
    }

    private func handleAuthCode(
        _ code: String,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print("✅ Найден код авторизации: \(code)")
        
        UIBlockingProgressHUD.show()

        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }

            switch result {
            case .success(let token):
                print("✅ OAuth токен получен: \(token)")
                OAuth2TokenKeychainStorage.shared.token = token
                self.delegate?.webViewViewControllerDidAuthenticate(self)
            case .failure(let error):
                print("❌ Ошибка при получении OAuth токена: \(error)")
                self.delegate?.webViewViewController(self, didFailWithError: error)
            }
        }

        decisionHandler(.cancel)
    }
}
