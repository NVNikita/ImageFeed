//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 11.02.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dissmis() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
