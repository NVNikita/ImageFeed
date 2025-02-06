//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 03.02.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
