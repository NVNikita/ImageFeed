//
//  ProfileViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Никита Нагорный on 18.03.2025.
//

import Foundation

import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?
    
    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    var updateAvatarCalled = false
    var updateProfileDetailsCalled = true
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
        view?.setAvatar(url: URL(string: "https://example.com/avatar.jpg")!)
    }
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true // Устанавливаем флаг при вызове
        view?.setProfileDetails(name: "Test Name", loginName: "Test Login", bio: "Test Bio") // Имитируем вызов setProfileDetails
    }
}

final class ProfileViewSpy: ProfileViewProtocol {
    
    var view: ProfileViewProtocol?
    var setAvatarCalled = false
    var setProfileDetailsCalled = false
    var presentAlertCalled = false
    var updateProfileDetailsCalled = false
    
    var avatarURL: URL?
    var profileName: String?
    var profileLoginName: String?
    var profileBio: String?
    var presentedAlert: UIAlertController?
    
    func setAvatar(url: URL) {
        setAvatarCalled = true
        avatarURL = url
    }
    
    func setProfileDetails(name: String?, loginName: String?, bio: String?) {
        setProfileDetailsCalled = true
        profileName = name
        profileLoginName = loginName
        profileBio = bio
    }
    
    func presentAlert(_ alert: UIAlertController) {
        presentAlertCalled = true
        presentedAlert = alert
    }
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true
        view?.setProfileDetails(name: "Test Name", loginName: "Test Login", bio: "Test Bio")
    }
}

final class ProfilePresenterTests: XCTestCase {
    
    func testPresenterCallsViewDidLoad() {
        
        let view = ProfileViewSpy()
        let presenter = ProfilePresenterSpy()
        
        presenter.view = view
        presenter.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled, "Метод viewDidLoad() не был вызван")
    }
    
    func testPresenterCallsDidTapLogoutButton() {
        
        let view = ProfileViewSpy()
        let presenter = ProfilePresenterSpy()
        
        presenter.view = view
        presenter.didTapLogoutButton()
        
        XCTAssertTrue(presenter.didTapLogoutButtonCalled, "Метод didTapLogoutButton() не был вызван")
    }
    
    func testPresenterUpdatesAvatar() {
        
        let view = ProfileViewSpy()
        let presenter = ProfilePresenterSpy()
        
        presenter.view = view
        presenter.updateAvatar()
        
        XCTAssertTrue(view.setAvatarCalled, "Метод setAvatar(url:) не был вызван")
    }
    
    func testPresenterUpdatesProfileDetails() {
        
        let view = ProfileViewSpy()
        let presenter = ProfilePresenterSpy()
        
        presenter.view = view
        
        presenter.updateProfileDetails()
        
        XCTAssertTrue(presenter.updateProfileDetailsCalled, "Метод updateProfileDetails() не был вызван")
        
        XCTAssertTrue(view.setProfileDetailsCalled, "Метод setProfileDetails(name:loginName:bio:) не был вызван")
        
        XCTAssertEqual(view.profileName, "Test Name", "Некорректное имя")
        XCTAssertEqual(view.profileLoginName, "Test Login", "Некорректный логин")
        XCTAssertEqual(view.profileBio, "Test Bio", "Некорректное био")
    }
    
    func testPresenterPresentsAlertOnLogout() {
        let view = ProfileViewSpy()
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let presenter = ProfilePresenter(profileService: profileService, profileImageService: profileImageService)
        
        presenter.view = view
        presenter.didTapLogoutButton()
        
        XCTAssertTrue(view.presentAlertCalled, "Метод presentAlert(_:) не был вызван")
        XCTAssertNotNil(view.presentedAlert, "Alert не был представлен")
    }
}
