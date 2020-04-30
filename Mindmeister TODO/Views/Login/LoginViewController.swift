//
//  LoginViewController.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 14.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var loginWebView: WKWebView!
    
    private var authorizeUrl: String!
    private var authorizeUrlWithParams: String!
    private var redirectUrl: String!
    private let timeout = 10.0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationItem.hidesBackButton = true
        
        self.authorizeUrl = MMApiService.shared.getAuthorizeUrl()
        self.authorizeUrlWithParams = MMApiService.shared.getAuthorizeUrlWithParams()
        self.redirectUrl = MMApiService.shared.redirectUrl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginWebView.navigationDelegate = self
        
        let authorizeUrl = URL(string: self.authorizeUrlWithParams)!
        let request = URLRequest(url: authorizeUrl, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: self.timeout)
        self.loginWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if (url.starts(with: self.authorizeUrl)) {
                return decisionHandler(.allow)
            } else if (url.starts(with: self.redirectUrl)) {
                let authorizationCode = self.getAuthorizationCode(url: url)
                if (authorizationCode == nil) {
                    decisionHandler(.cancel)
                    return self.viewDidLoad()
                }
                MMApiService.shared.getAccessToken(authorizationCode: authorizationCode!) { (accessToken) in
                    if (accessToken.isEmpty) {
                        decisionHandler(.cancel)
                        return self.viewDidLoad()
                    }
                    SessionService.shared.setSession(session: accessToken)
                    
                    decisionHandler(.cancel)
                    DispatchQueue.main.async {
                        return self.performSegue(withIdentifier: MapsViewController.SEGUE_SHOW_MAPS, sender: nil)
                    }
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
    
    private func getAuthorizationCode(url: String) -> String! {
        var code:String?
        do {
            var redirectUrlRegex = self.redirectUrl.replacingOccurrences(of: "/", with: "\\/")
            if (!redirectUrlRegex.hasSuffix("/")) {
                redirectUrlRegex += "\\/"
            }
            let regex = try NSRegularExpression(pattern: "^\(redirectUrlRegex)\\?code=(.+)$", options: .caseInsensitive)
            let matches = regex.matches(in: url, options: [], range: NSRange(location: 0, length: url.utf8.count))
            if let match = matches.first {
                let range = match.range(at:1)
                if let swiftRange = Range(range, in: url) {
                    code = String(url[swiftRange])
                }
            }
        } catch {
            print(error)
        }
        
        return code
    }
}
