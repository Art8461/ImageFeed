//
//  TabBabController.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 14.08.2025.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarApparance()
        setupNavigationAppearance()
    }
    
    private func setupViewControllers() {
        // ImagesList
        let imagesListVC = ImagesListViewController()
        let imagesNav = UINavigationController(rootViewController: imagesListVC)
        imagesNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .imageListTapBar),
            selectedImage: UIImage(resource: .imageListTapBarActive)
        )
        imagesNav.tabBarItem.accessibilityIdentifier = "ImagesTab"
        
        // Profile
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .profileTabBar),
            selectedImage: UIImage(resource: .profileTapBarActive)
        )
        profileNav.tabBarItem.accessibilityIdentifier = "ProfileTab"
        
        viewControllers = [imagesNav, profileNav]
    }
    // MARK: TAPBAR
    private func setupTabBarApparance() {

        // Цвет выбранной иконки
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        tabBar.standardAppearance = appearance
    }
    
    // MARK: NAVIGATION
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // убирает прозрачность
        appearance.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) // тёмный фон
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white, // цвет заголовка
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        UINavigationBar.appearance().tintColor = .white
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
