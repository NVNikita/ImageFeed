//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 28.12.2024.
//

import UIKit
import Kingfisher

public protocol ProfileViewProtocol: AnyObject {
    
    func setAvatar(url: URL)
    func setProfileDetails(name: String?, loginName: String?, bio: String?)
    func presentAlert(_ alert: UIAlertController)
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    
    
    // MARK: - Properties
    private var profileImage = UIImageView()
    private var labelName = UILabel()
    private var labelMail = UILabel()
    private var labelStatus = UILabel()
    private var buttonLogOut = UIButton()
    private var profileServise = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var presenter: ProfilePresenterProtocol!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        presenter = ProfilePresenter(profileService: ProfileService.shared,
                                     profileImageService: ProfileImageService.shared)
        presenter.view = self
        
        initializeUIComponents()
        setupConstraints()
        presenter.viewDidLoad()
    }
    
    func setAvatar(url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "UserPhoto"),
                                 options: [
                                    .processor(processor),
                                    .transition(.fade(3))
                                 ])
    }
    
    func setProfileDetails(name: String?, loginName: String?, bio: String?) {
        labelName.text = name
        labelMail.text = loginName
        labelStatus.text = bio
    }
    
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    private func initializeUIComponents() {
        labelName = UILabel()
        labelName.accessibilityIdentifier = "labelName"
        labelMail = UILabel()
        labelMail.accessibilityIdentifier = "labelMail"
        labelStatus = UILabel()
        
        profileImage = UIImageView()
        profileImage.image = UIImage(named: "avatar")
        
        guard let image = UIImage(named: "logOut") else {
            print("[ProfileViewController]: ['logOut' not found]")
            guard let defaultImage = UIImage(systemName: "ipad.and.arrow.forward") else {
                fatalError("[ProfileViewController]: ['person.crop.circle.fill' not found]")
            }
            
            buttonLogOut = UIButton.systemButton(with: defaultImage,
                                                 target: self,
                                                 action: #selector(Self.didTapButton))
            return
        }
        
        buttonLogOut = UIButton.systemButton(with: image,
                                             target: self,
                                             action: #selector(Self.didTapButton))
        buttonLogOut.accessibilityIdentifier = "buttonLogOut"
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
        presenter.didTapLogoutButton()
    }
}

