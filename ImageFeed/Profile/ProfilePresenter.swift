//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 15.03.2025.
//

import Foundation
import UIKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileService, profileImageService: ProfileImageService) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        addObserver()
    }
    
    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main)
        { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    func viewDidLoad() {
        updateAvatar()
        updateProfileDetails()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.setAvatar(url: url)
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            print("[ProfileViewService]: [Error in updateProfileDetails]")
            return
        }
        
        view?.setProfileDetails(name: profile.name, loginName: profile.loginName, bio: profile.bio)
    }
        
    func didTapLogoutButton() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
            ProfileLogoutService.shared.logout()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        
        view?.presentAlert(alert)
    }
    
}
