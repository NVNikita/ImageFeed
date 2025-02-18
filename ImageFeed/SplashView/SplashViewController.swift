//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 03.02.2025.
//

import UIKit
import ProgressHUD
 
final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    // MARK: - Private Prperties
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // првоерка ключа
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Prifate Methods
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] rezult in
            UIBlockingProgressHUD.dismis()
            
            guard let self = self else { return }
            
            switch rezult {
            case .success:
                self.switchToTabBarController()
            case .failure:
                print("ERROR load profile")
            }
        }
    }
    
    private func switchToTabBarController() {
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
}

// MARK: - Extensions

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            // установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
           }
    }
}

// обрабатываем процесс авторизации
extension SplashViewController {
    func didAuthenticate(_ vc: AuthViewController, code: String) {
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismis()
                switch result {
                case .success(let token):
                    // токен получен
                    self.storage.token = token
                    print("Token: \(token)")
                    
                    if let token = self.storage.token {
                        self.fetchProfile(token: token)
                    }
                    self.switchToTabBarController()
                case .failure(let error):
                    // ошибка
                    // TODO: 11 sprint
                    print("Error: \(error)")
                }
            }
        }
    }
}

