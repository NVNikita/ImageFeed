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
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private lazy var splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // првоерка ключа
        if let token = storage.token {
            fetchProfile(token: token)
            print("SplashViewController - token [\(token)]")
        } else {
            showAuthViewController()
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
    
    private func addSplashView() {
        view.addSubview(splashImageView)
        view.backgroundColor = .ypBlack
        
        splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func showAuthViewController() {
        let authViewController = AuthViewController()
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        authViewController.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
    
    private func switchToTabBarController() {
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[SplashViewCOntroller]: [Invalid window configuration]")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
}

// MARK: - Extensions

// обрабатываем процесс авторизации
extension SplashViewController {
    func didAuthenticate(_ vc: AuthViewController, code: String) {
        vc.dismiss(animated: true) {
            OAuth2Service.shared.fetchOAuthToken(code: code) { [ weak self ] result in
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(let token):
                        self?.storage.token = token
                        print("SplashViewController - add token in tokenStorage")
                        
                        if let token = self?.storage.token {
                            self?.fetchProfile(token: token)
                        }
                    case .failure(let error):
                        print("[SplashViewController]: [Error - \(error)]")
                    }
                }
            }
        }
    }
}

extension SplashViewController {
    private func fetchProfile(token: String) {
        
            UIBlockingProgressHUD.show()
            
            profileService.fetchProfile(token) { [ weak self ] result in
                UIBlockingProgressHUD.dismis()
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    print("SplashViewController - \(profile.username) username")
                    print("SplashViewController - Profile image URL = true")
                    profileImageService.fetchProfileImageURL(username: profile.username, token: token) { _ in }
                    self.switchToTabBarController()
            case .failure(let error):
                let alert = UIAlertController(title: "Что-то пошло не так",
                                              message: "Не удалось войти в систему",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
                print("[SplashViewController]: [ERROR load profile] [\(error)]")
            }
        }
    }
}
