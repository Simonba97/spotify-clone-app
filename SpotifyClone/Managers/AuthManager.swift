//
//  AuthManager.swift
//  SpotifyClone
//
//  Created by Simón Bustamante Alzate on 17/07/24.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "25aa8ee4b935448f85fd348f01991c82"
        static let clientSecretID = "c9d95a49e8dc48c4a1851a443a5eebc9"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    }
    
    public var signInURL:  URL? {
        
        let baseUrl = "https://accounts.spotify.com/authorize"
        let scopeDefinition = "user-read-private"
        let redirectURI = "https://www.saimoncode.dev"
        let urlComplete = "\(baseUrl)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopeDefinition)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        
        return URL(string: urlComplete)
    }
    
    private init() {}
    
    var isSignedIn:Bool {
        // Validamos que el usuario ha iniciado sesión
        return accessToken != nil
    }
    
    private var accessToken:String? {
        return UserDefaults.standard.string(forKey: "access_token ")
    }
    
    private var refreshToken:String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate:Date? {
        return UserDefaults.standard.object(forKey: "expiration ") as? Date
    }
    
    private var shouldRefreshToke:Bool {
        
        // Validación si se debe refrescar el token o no
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        
        let currentDate = Date()
        let fiveMinutes:TimeInterval = 300
        
        // agregamos los cinco minutos y evaluamos con respecto a la fecha de expiración
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(code:String, completion: @escaping (Bool)-> Void){
        // Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "https://www.saimoncode.dev"),
        ]
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = "\(Constants.clientID):\(Constants.clientSecretID)"
        let data  = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
                
                
            } catch  {
                print(error.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    public func refreshIsNeeded(completion: @escaping (Bool) ->  Void){
                
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        // Refresh the token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = "\(Constants.clientID):\(Constants.clientSecretID)"
        let data  = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("Successfully refreshed")
                self?.cacheToken(result: result)
                completion(true)
                
                
            } catch  {
                print(error.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
        
        
    }
    
    private func cacheToken(result:AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expiration")
    }
}
