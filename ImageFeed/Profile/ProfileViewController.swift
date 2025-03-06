//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 28.12.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var profileImage = UIImageView()
    private var labelName = UILabel()
    private var labelMail = UILabel()
    private var labelStatus = UILabel()
    private var buttonLogOut = UIButton()
    private var profileServise = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
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
            self?.updateAvatar()
        }
        
        // profileView
        view.backgroundColor = .ypBlack
        
        updateAvatar()
        updateProfileDetails()
        
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        print("ProfileViewController - updateAvatar is working")
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "UserPhoto"),
                                 options: [
                                    .processor(processor),
                                    .transition(.fade(3))
                                 ])
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
        
        guard let image = UIImage(named: "logOut") else {
            // обработка случая, когда изображение не найдено
            print("[ProfileViewController]: ['logOut' not found]")
            // устанавливаем изображение по умолчанию
            guard let defaultImage = UIImage(systemName: "ipad.and.arrow.forward") else {
                fatalError("[ProfileViewController]: ['person.crop.circle.fill' not found]")
            }
            buttonLogOut = UIButton.systemButton(with: defaultImage,
                                                 target: self,
                                                 action: #selector(Self.didTapButton))
            return
        }

        // если изображение найдено, создаем кнопку
        buttonLogOut = UIButton.systemButton(with: image,
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
        
        // profileImage
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        
        // labelName
        NSLayoutConstraint.activate([
            labelName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            labelName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        labelName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        labelName.textColor = .white
        labelName.text = "Екатерина Новикова"
        
        // labelMail
        NSLayoutConstraint.activate([
            labelMail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8),
            labelMail.leadingAnchor.constraint(equalTo: labelName.leadingAnchor)
        ])
        labelMail.font = UIFont.systemFont(ofSize: 13, weight: .light)
        labelMail.textColor = .mailLabel
        labelMail.text = "@ekaterina_nov"
        
        // labelStatus
        NSLayoutConstraint.activate([
            labelStatus.topAnchor.constraint(equalTo: labelMail.bottomAnchor, constant: 8),
            labelStatus.leadingAnchor.constraint(equalTo: labelName.leadingAnchor)

        ])
        labelStatus.textColor = .white
        labelStatus.font = UIFont.systemFont(ofSize: 13, weight: .light)
        labelStatus.text = "Hello, world!"
        
        //buttonLogOut
        NSLayoutConstraint.activate([
            buttonLogOut.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonLogOut.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
        buttonLogOut.tintColor = .logOutButton
        buttonLogOut.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonLogOut.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    @objc
    private func didTapButton() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
            ProfileLogoutService.shared.logout()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        
        self.present(alert, animated: true)
    }
}

