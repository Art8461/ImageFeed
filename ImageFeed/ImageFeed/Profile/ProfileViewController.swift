//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 14.08.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var photoProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var descriptionProfile: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func exitButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Публичные методы
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)

        // PhotoProfile
        photoProfile.contentMode = .scaleAspectFill
        photoProfile.image = UIImage(systemName: "person.crop.circle.fill")
        photoProfile.clipsToBounds = true
        photoProfile.layer.cornerRadius = 35
        photoProfile.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoProfile.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoProfile.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            photoProfile.widthAnchor.constraint(equalToConstant: 70),
            photoProfile.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // UserName
        userName.textColor = UIColor.white
        userName.font = UIFont(name: "SFProText-Bold", size: 23)
        userName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: photoProfile.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        // User NickName
        userNickName.textColor = UIColor.gray
        userNickName.font = UIFont(name: "SFProText-Regular", size: 13)
        userNickName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNickName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userNickName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        // Description Profile
        descriptionProfile.textColor = UIColor.white
        descriptionProfile.font = UIFont(name: "SFProText-Regular", size: 13)
        descriptionProfile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionProfile.topAnchor.constraint(equalTo: userNickName.bottomAnchor, constant: 8),
            descriptionProfile.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionProfile.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        // Exit Button
        exitButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        exitButton.tintColor = .systemRed
        exitButton.setTitle("", for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
