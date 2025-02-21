//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 28.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var profileImage: UIImageView!
    private var labelName: UILabel!
    private var labelMail: UILabel!
    private var labelStatus: UILabel!
    private var buttonLogOut: UIButton!
    private var profileServise = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUIComponents()
        setupConstraints()
        
        profileImageServiceObserver = NotificationCenter.default
                    .addObserver(
                        forName: ProfileImageService.didChangeNotification,
                        object: nil,
                        queue: .main)
                        { [weak self] _ in
                        guard let self = self else { return }
                        self.updateAvatar()
                    }
                updateAvatar()
        
        // profileView
        view.backgroundColor = .ypBlack
        
        updateProfileDetails()
    }
    
    private func updateAvatar() {
        guard
            let profileImage = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImage)
        else { return }
        // TODO: - обновить аватар с помощью кингфисшер
    }
    
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else {
            print("[ProfileViewService]: [Error in updateProfileDetails]")
            return
        }
        
        labelName.text = profile.name
        labelMail.text = profile.loginName
        labelStatus.text = profile.bio
    }
    
    // MARK: - Private Methods
    private func initializeUIComponents() {
        labelName = UILabel()
        labelMail = UILabel()
        labelStatus = UILabel()
        
        profileImage = UIImageView()
        profileImage.image = UIImage(named: "avatar")
        
        buttonLogOut = UIButton.systemButton(with: UIImage(named: "logOut")!,
                                             target: self,
                                             action: #selector(Self.didTapButton))
    }
    
    private func setupConstraints() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        labelName.translatesAutoresizingMaskIntoConstraints = false
        labelMail.translatesAutoresizingMaskIntoConstraints = false
        labelStatus.translatesAutoresizingMaskIntoConstraints = false
        buttonLogOut.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImage)
        view.addSubview(labelName)
        view.addSubview(labelMail)
        view.addSubview(labelStatus)
        view.addSubview(buttonLogOut)
        
        // profileImage constraints
        profileImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        // labelName constraints
        labelName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        labelName.textColor = .white
        labelName.text = "Екатерина Новикова"
        labelName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8).isActive = true
        labelName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        // labelMail constraints
        labelMail.font = UIFont.systemFont(ofSize: 13, weight: .light)
        labelMail.textColor = .mailLabel
        labelMail.text = "@ekaterina_nov"
        labelMail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8).isActive = true
        labelMail.leadingAnchor.constraint(equalTo: labelName.leadingAnchor).isActive = true
        
        // labelStatus constraints
        labelStatus.textColor = .white
        labelStatus.font = UIFont.systemFont(ofSize: 13, weight: .light)
        labelStatus.text = "Hello, world!"
        labelStatus.topAnchor.constraint(equalTo: labelMail.bottomAnchor, constant: 8).isActive = true
        labelStatus.leadingAnchor.constraint(equalTo: labelName.leadingAnchor).isActive = true
        
        // buttonLogout constraints
        buttonLogOut.tintColor = .logOutButton
        buttonLogOut.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonLogOut.widthAnchor.constraint(equalToConstant: 44).isActive = true
        buttonLogOut.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buttonLogOut.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapButton() {
        // TODO: - добавить логику при нажатии на кнопку
    }
}
