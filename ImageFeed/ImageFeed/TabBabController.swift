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
        setupTabBarIcons()
        setupNavigationAppearance()
    }
    // MARK: TAPBAR
    private func setupTabBarIcons() {
        guard let items = tabBar.items else { return }
        
        // Первый таб
        items[0].image = UIImage(named: "ImageListTapBar")
        items[0].selectedImage = UIImage(named: "ImageListTapBarActive")
        items[0].title = ""
        
        // Второй таб
        items[1].image = UIImage(named: "ProfileTabBar")
        items[1].selectedImage = UIImage(named: "ProfileTapBarActive")
        items[1].title = ""
        
        /*// Первый таб системная картинка четкая
        items[0].image = UIImage(systemName: "rectangle.stack.fill")
        items[0].selectedImage = UIImage(systemName: "rectangle.stack.fill")
        items[0].title = ""
        
        // Второй таб системная картинка
        items[1].image = UIImage(systemName: "person.crop.circle.fill")
        items[1].selectedImage = UIImage(systemName: "person.crop.circle.fill")
        items[1].title = ""*/
        
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
        
        // Цвет кнопок (back, done и т.д.)
        UINavigationBar.appearance().tintColor = .white

        // Применяем для всех состояний
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        }
}
