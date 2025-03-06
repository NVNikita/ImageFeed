//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 07.03.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.resetProfileData()
        ProfileImageService.shared.resetAvatar()
        ImagesListService.shared.resetPhotos()
        switchToLoginScreen()
        
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToLoginScreen() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = scene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else {
                print("[ProfileLogoutService]: [Error window or sceneDelegate]")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                print("[ProfileLogoutService]: [Error load LoginViewController from Storyboard]")
                return
            }
            
            let navigationController = UINavigationController(rootViewController: authViewController)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
    
