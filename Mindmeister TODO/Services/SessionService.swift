//
//  SessionService.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 27.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

class SessionService {
    
    public static let ACCESS_TOKEN_KEY = "access_token"
    public static let shared = SessionService()
    
    public func setSession(session: String) {
        UserDefaults.standard.set(session, forKey: SessionService.ACCESS_TOKEN_KEY)
    }
    
    public func getSession() -> String? {
        UserDefaults.standard.string(forKey: SessionService.ACCESS_TOKEN_KEY)
    }
    
    public func removeSession() {
        UserDefaults.standard.removeObject(forKey: SessionService.ACCESS_TOKEN_KEY)
    }
}
