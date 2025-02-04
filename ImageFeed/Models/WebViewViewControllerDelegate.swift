//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 03.02.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    // WebViewViewController получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    // пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
