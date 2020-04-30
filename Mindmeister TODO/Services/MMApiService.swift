//
//  MMApiService.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 26.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

class MMApiService {
    
    public static let MM_CLIENT_ID_KEY = "MM client id"
    public static let MM_CLIENT_SECRET_KEY = "MM client secret"
    public static let MM_AUTH_URL_KEY = "MM auth url"
    public static let MM_API_V1_URL_KEY = "MM api v1 url"
    public static let MM_API_V2_URL_KEY = "MM api v2 url"
    public static let MM_REDIRECT_URL_KEY = "MM redirect url"
    public static let shared = MMApiService()
    
    private let clientId: String
    private let clientSecret: String
    private let scopes = ["mindmeister", "userinfo.profile", "userinfo.email"]
    private let responseType = "code"
    private let grantType = "authorization_code"
    
    private(set) var oauth2Url: String
    private(set) var apiV1Url: String
    private(set) var apiV2Url: String
    private(set) var redirectUrl: String
    
    init() {
        self.clientId = Bundle.main.infoDictionary![MMApiService.MM_CLIENT_ID_KEY] as! String
        self.clientSecret = Bundle.main.infoDictionary![MMApiService.MM_CLIENT_SECRET_KEY] as! String
        self.oauth2Url = Bundle.main.infoDictionary![MMApiService.MM_AUTH_URL_KEY] as! String
        self.apiV1Url = Bundle.main.infoDictionary![MMApiService.MM_API_V1_URL_KEY] as! String
        self.apiV2Url = Bundle.main.infoDictionary![MMApiService.MM_API_V2_URL_KEY] as! String
        self.redirectUrl = Bundle.main.infoDictionary![MMApiService.MM_REDIRECT_URL_KEY] as! String
    }
    
    public func getAuthorizeUrl() -> String {
        return "\(self.oauth2Url)/authorize"
    }
    
    public func getAuthorizeUrlWithParams() -> String {
        let query = [
            "client_id=\(self.clientId)",
            "scope=\(self.scopes.joined(separator: "%20"))",
            "response_type=\(self.responseType)",
            "redirect_uri=\(self.redirectUrl)",
        ]
        return "\(self.getAuthorizeUrl())?\(query.joined(separator: "&"))"
    }
    
    public func getAccessTokenUrlWithParams(authorizationCode: String) -> String {
        let query = [
            "code=\(authorizationCode)",
            "client_id=\(self.clientId)",
            "client_secret=\(self.clientSecret)",
            "grant_type=\(self.grantType)",
            "redirect_uri=\(self.redirectUrl)",
        ]
        return "\(self.oauth2Url)/token?\(query.joined(separator: "&"))"
    }
    
    public func getAccessToken(authorizationCode: String, onComplete: @escaping (String) -> ()) {
        let accessTokenUrl = URL(string: self.getAccessTokenUrlWithParams(authorizationCode: authorizationCode))!
        var request = URLRequest(url: accessTokenUrl)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (data != nil) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        if let accessToken = json["access_token"] as? String {
                            return onComplete(accessToken)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    public func getTokenInfo(session: String, onComplete: @escaping (Bool) -> ()) {
        let tokenInfoUrl = URL(string: "\(self.oauth2Url)/token/info")!
        var request = URLRequest(url: tokenInfoUrl)
        request.httpMethod = "GET"
        request.setValue("Bearer \(session)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (data != nil) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        if let _ = json["error"] as? [String: String] {
                            return onComplete(false)
                        } else {
                            return onComplete(true)
                        }
                    }
                } catch {
                    return onComplete(false)
                }
                return onComplete(true)
            }
            return onComplete(false)
        }
        task.resume()
    }
    
    public func getMapList(onComplete: @escaping([MapListMap]) -> ()) {
        self.makeV1ApiRequest(httpMethod: "GET", apiMethod: "mm.maps.getList", params: nil, onComplete: { (response:ApiResponse<MapListApiResponseRsp>) in
            return onComplete((response.rsp?.maps?.map)!)
        }, onError: {
            
        })
    }
    
    public func getMap(mapId: String, onComplete: @escaping(MapApiResponseRsp) -> ()) {
        let params = ["map_id": mapId]
        self.makeV1ApiRequest(httpMethod: "GET", apiMethod: "mm.maps.getMap", params: params, onComplete: { (response:ApiResponse<MapApiResponseRsp>) in
            return onComplete(response.rsp!)
        }, onError: {
            
        })
    }
    
    public func setIdeaIcon(mapId: String, ideaId: String, icon: String, onComplete: @escaping(IdeaChangeApiResponseRsp) -> ()) {
        let params = [
            "map_id": mapId,
            "idea_id": ideaId,
            "icon": icon
        ]
        self.makeV1ApiRequest(httpMethod: "GET", apiMethod: "mm.ideas.change", params: params, onComplete: { (response:ApiResponse<IdeaChangeApiResponseRsp>) in
            return onComplete(response.rsp!)
        }, onError: {
            
        })
    }
    
    private func makeV1ApiRequest<T>(httpMethod: String, apiMethod: String, params: [String: String]?, onComplete: @escaping(ApiResponse<T>) -> (), onError: @escaping() -> ()) {
        var urlStr = "\(self.apiV1Url)?method=\(apiMethod)"
        if let params = params {
            if (params.count > 0) {
                var p = [String]()
                for (key, value) in params {
                    p.append(key + "=" + value)
                }
                urlStr += "&\(p.joined(separator: "&"))"
            }
        }
        let apiUrl = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        print(apiUrl)
        if let session = SessionService.shared.getSession() {
            var request = URLRequest(url: apiUrl)
            request.httpMethod = httpMethod
            request.setValue("Bearer \(session)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        if let json = try JSONDecoder().decode(ApiResponse<T>.self, from: data) as? ApiResponse<T> {
                            return onComplete(json)
                        }
                    } catch {
                        print(error)
                        return onError()
                    }
                }
                return onError()
            }
            task.resume()
        } else {
            return onError()
        }
    }
    
}
