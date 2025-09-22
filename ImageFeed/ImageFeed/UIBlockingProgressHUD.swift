//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Artem Kuzmenko on 19.09.2025.
//

import UIKit
import ProgressHUD
final class UIBlockingProgressHUD {
    private static var window: UIWindow?{
        return UIApplication.shared.windows.first
    }
    static func show(){
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
        print("✅ Показываем HUD и блокируем экран")
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
        print("✅ Скрываем HUD и разблокируем экран")
    }
}
