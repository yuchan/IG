//
//  IGClient.swift
//  IG
//
//  Created by Yusuke Ohashi on 2018/03/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation
import KeychainAccess

/**
 Main Class for Instagram Client.
 */
public class IG {
    fileprivate static let shared = IG()
    fileprivate var clientID = ""
    fileprivate var clientSecret = ""
    fileprivate var redirectURI = ""
    fileprivate let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)

    /**
     configure instagram API
     You can get clientID/clientSecret from https://developer.instagram.com/

     - parameter clientID: String client id
     - parameter clientSecret: String
     - parameter redirectURI: String
     */
    public static func configure(clientID: String, clientSecret: String, redirectURI: String) {
        shared.clientID = clientID
        shared.clientSecret = clientSecret
        shared.redirectURI = redirectURI
    }

    public static func getAccessToken(code: String, completion: @escaping (Bool, Error?) -> Void) {
        if let url = URL(string: "https://api.instagram.com/oauth/access_token") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameters = "client_id=\(shared.clientID)" +
                "&client_secret=\(shared.clientSecret)" +
                "&grant_type=authorization_code" +
                "&redirect_uri=\(shared.redirectURI)" +
            "&code=\(code)"
            request.httpBody = parameters.data(using: .utf8)
            shared.session.dataTask(with: request) { (data, response, error) in
                if error != nil, data == nil {
                    completion(false, error)
                } else {
                    do {
                        let response = try IGAuthResponse(data: data!)
                        try Keychain(service: "Instagram").set(response.accessToken, key: "access_token")
                        completion(true, nil)
                    } catch {
                        completion(false, error)
                    }
                }
                }.resume()
        } else {
            completion(false, IGError.unknown)
        }
    }

    public static func biography(accessToken: String, completion:@escaping (IGUser?, Error?) -> Void) {
        if let token = accessTokenFromKeychain(), let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=\(token)") {
            let request = URLRequest(url: url)
            shared.session.dataTask(with: request) { (data, response, error) in
                do {
                    if let data = data {
                        let user = try IGUser(data: data)
                        completion(user, nil)
                    } else {
                        completion(nil, error)
                    }
                } catch {
                    completion(nil, error)
                }
                }.resume()
        } else {
            completion(nil, IGError.invalidToken)
        }
    }
    
    private static func accessTokenFromKeychain() -> String? {
        do {
            guard let token = try Keychain(service: "Instagram").get("access_token") else {
                return nil
            }
            
            return token
        } catch {
            return nil
        }
    }
}

public extension IG {
    static func authenticationUrl() -> URL? {
        guard let url = URL(string: "https://api.instagram.com/oauth/authorize/?client_id=\(IG.shared.clientID)&redirect_uri=\(IG.shared.clientSecret)&response_type=code") else {
            return nil
        }
        return url
    }
}


