//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 25.01.2025.
//

import WebKit
import UIKit

// адресс запроса
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController {
    
    // MARK: IBOulets
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private var webView: WKWebView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthView()
        
        webView.navigationDelegate = self
    }
    
    // подписка обсервера
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    // отписываемся
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // отслеживаем и реагируем на изменение загрузки webivew
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods
    
    // обновляем состояние UIProgressView
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    } 
    
    private func loadAuthView() {
        // инициализация адреса запроса
        guard var urlComponents = URLComponents(
            string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Error init url unsplash")
            return
        }
        
        //инициализируем структуру URLComponents с указанием адреса запроса
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        // url для запроса
        guard let url = urlComponents.url else {
            print("Error url unsplash for webView")
            return
        }
        
        // формируем urlRequest и передаем его webView для загрузки
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: IBActions
    
    @IBAction private func buttonOutDidTap(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - Extensions

extension WebViewViewController: WKNavigationDelegate {
    // пользователь готовится совершить навигационные действия
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
         if let code = code(from: navigationAction) {
                delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                decisionHandler(.cancel)
          } else {
                decisionHandler(.allow)
            }
    }
    
    // возващает код авторизации, если он получен
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
