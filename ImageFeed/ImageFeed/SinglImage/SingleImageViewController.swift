//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 15.08.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var fullImageURL: URL?
    
    // MARK: - UI
        private let scrollZoom: UIScrollView = {
            let sv = UIScrollView()
            sv.minimumZoomScale = 0.1
            sv.maximumZoomScale = 1.25
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.showsVerticalScrollIndicator = false
            sv.showsHorizontalScrollIndicator = false
            return sv
        }()

        private let imageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()

        private let exitSinglImage: UIButton = {
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(resource: .backward), for: .normal)
            btn.tintColor = .white
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()

        private let shareButton: UIButton = {
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(resource: .sharing), for: .normal)
            btn.tintColor = .white
            btn.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
            btn.layer.cornerRadius = 25
            btn.clipsToBounds = true
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        setupUI()
        setupConstraints()
        loadImage()
    }
    private func setupUI() {
        view.addSubview(scrollZoom)
        scrollZoom.addSubview(imageView)
        view.addSubview(exitSinglImage)
        view.addSubview(shareButton)
        
        scrollZoom.delegate = self
        
        exitSinglImage.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
           NSLayoutConstraint.activate([
        // ScrollZoom
            scrollZoom.topAnchor.constraint(equalTo: view.topAnchor),
            scrollZoom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollZoom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollZoom.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        // Image
            imageView.topAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollZoom.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollZoom.frameLayoutGuide.heightAnchor),
            
        // Exit Button
            exitSinglImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            exitSinglImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            exitSinglImage.widthAnchor.constraint(equalToConstant: 24),
            exitSinglImage.heightAnchor.constraint(equalToConstant: 24),
            
        // Share Button
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -51),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadImage() {
        guard let url = fullImageURL else {
            showError()
            return
        }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()  // HUD точно уберётся
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.imageView.frame.size = value.image.size
                    self.scrollZoom.contentSize = value.image.size
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.showError()
                }
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController( title: "Что-то пошло не так.", message: "Попробовать ещё раз?", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) {
            [weak self] _ in self?.loadImage()
        })
        present(alert, animated: true)
    }
    // MARK: - Actions
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShareButton() {
        guard let image=imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }
    
    private func centerImageInScrollView() {
        let scrollViewSize = scrollZoom.bounds.size
        let imageSize = imageView.frame.size
        
        let verticalInset = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        let horizontalInset = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        
        scrollZoom.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
