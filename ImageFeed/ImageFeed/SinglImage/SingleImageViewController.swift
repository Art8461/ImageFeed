//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 15.08.2025.
//

import UIKit

class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
        }
    }
    
    @IBOutlet weak var exitSinglImage: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollZoom: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image else { return }
        imageView.image = image
        
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        // ScrollZoom
        scrollZoom.delegate = self
        scrollZoom.minimumZoomScale = 0.1
        scrollZoom.maximumZoomScale = 1.25
        
        scrollZoom.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollZoom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollZoom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollZoom.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollZoom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollZoom.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollZoom.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollZoom.frameLayoutGuide.heightAnchor)
        ])
        
        // Exit Button
        exitSinglImage.setImage(UIImage(named: "Backward"), for: .normal)
        exitSinglImage.tintColor = .white
        exitSinglImage.setTitle("", for: .normal)
        exitSinglImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exitSinglImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            exitSinglImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            exitSinglImage.widthAnchor.constraint(equalToConstant: 24),
            exitSinglImage.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        
        // Share Button
        shareButton.setImage(UIImage(named: "Sharing"), for: .normal)
        shareButton.tintColor = .white
        shareButton.setTitle("", for: .normal)
        shareButton.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) // или любой другой
        shareButton.layer.cornerRadius = 25 // половина ширины/высоты для круга
        shareButton.clipsToBounds = true
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -51),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        view.bringSubviewToFront(shareButton)
        view.bringSubviewToFront(exitSinglImage)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
        
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
        
        let verticalInset = imageSize.height < scrollViewSize.height
        ? (scrollViewSize.height - imageSize.height) / 2
        : 0
        let horizontalInset = imageSize.width < scrollViewSize.width
        ? (scrollViewSize.width - imageSize.width) / 2
        : 0
        
        scrollZoom.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
