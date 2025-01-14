//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 28.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ProfileView
        view.backgroundColor = .ypBlack
        
        // Avatar photo
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        // LabelName
        let labelName = UILabel()
        
        labelName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelName)
        
        labelName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        labelName.textColor = .white
        labelName.text = "Екатерина Новикова"
        
        labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        labelName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        // mailName
        let labelMail = UILabel()
        
        labelMail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelMail)
        
        labelMail.font = UIFont.systemFont(ofSize: 13, weight: .light)
        labelMail.textColor = .mailLabel
        labelMail.text = "@ekaterina_nov"
        
        labelMail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8).isActive = true
        labelMail.leadingAnchor.constraint(equalTo: labelName.leadingAnchor).isActive = true
        
        // labelStatus
        let labelStatus = UILabel()
        
        labelStatus.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelStatus)
        
        labelStatus.textColor = .white
        labelStatus.font = UIFont.systemFont(ofSize: 13, weight: .light)
        labelStatus.text = "Hello, world!"
        
        labelStatus.topAnchor.constraint(equalTo: labelMail.bottomAnchor, constant: 8).isActive = true
        labelStatus.leadingAnchor.constraint(equalTo: labelName.leadingAnchor).isActive = true
        
        // button logOut
        let buttonLogOut = UIButton.systemButton(with: UIImage(named: "logOut")!,
                                                 target: self,
                                                 action: #selector(Self.didTapButton))
        
        buttonLogOut.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonLogOut)
        
        buttonLogOut.tintColor = .logOutButton
        buttonLogOut.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonLogOut.widthAnchor.constraint(equalToConstant: 44).isActive = true
        buttonLogOut.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buttonLogOut.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    // MARK: - Private Methods
    
    @objc
    private func didTapButton() {
        // TODO: - добавить логику при нажатии на кнопку
    }
}
