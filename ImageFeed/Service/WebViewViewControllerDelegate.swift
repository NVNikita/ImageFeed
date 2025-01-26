//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 26.01.2025.
//

import Foundation

protocol WebViewViewControllerDelegate {
    // WebViewViewController получил код
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    // пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
