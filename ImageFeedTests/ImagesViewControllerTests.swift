//
//  ImagesViewCntrollerTests.swift
//  ImageFeedTests
//
//  Created by Никита Нагорный on 18.03.2025.
//

import Foundation
import XCTest
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    var view: ImagesListViewProtocol?
    
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var changeLikePhotoId: String?
    var changeLikeIsLike: Bool?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        view?.updateTableViewAnimated()
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(for photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void) {
        changeLikeCalled = true
        changeLikePhotoId = photoId
        changeLikeIsLike = isLike
        completion(true)
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return Photo(id: "testPhotoId", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "https://example.com", largeImageURL: "https://example.com", isLiked: false)
    }
    
    func numberOfPhotos() -> Int {
        return 1
    }
}

final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    
    var updateTableViewAnimatedCalled = false
    var showErrorMessage: String?
    var presenter: ImagesListPresenterProtocol?
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func showError(message: String) {
        showErrorMessage = message
    }
}

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled, "Метод viewDidLoad() не был вызван")
    }
    
    func testViewControllerCallsFetchPhotosNextPage() {
        
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.fetchPhotosNextPage()
        
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled, "Метод fetchPhotosNextPage() не был вызван")
    }
    
    func testViewControllerCallsChangeLike() {
        
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let photoId = "testPhotoId"
        let isLike = true
        
        presenter.changeLike(for: photoId, isLike: isLike) { _ in }
        
        XCTAssertTrue(presenter.changeLikeCalled, "Метод changeLike() не был вызван")
        XCTAssertEqual(presenter.changeLikePhotoId, photoId, "Неверный photoId передан в changeLike()")
        XCTAssertEqual(presenter.changeLikeIsLike, isLike, "Неверное значение isLike передано в changeLike()")
    }
    
    func testPresenterUpdatesViewWhenPhotosLoaded() {
        
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled, "Метод updateTableViewAnimated() не был вызван")
    }
    
    func testPresenterShowsErrorWhenFetchFails() {
        
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let errorMessage = "Ошибка загрузки фотографий"
        
        presenter.view?.showError(message: errorMessage)
        
        XCTAssertEqual(viewController.showErrorMessage, errorMessage, "Неверное сообщение об ошибке передано в showError()")
    }
}
