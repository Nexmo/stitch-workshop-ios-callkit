//
//  HomeVC+Network.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/18/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Alamofire

extension HomeVC {
    
    func createUser(with username: String, admin: Bool = true) {
        
        let url = NexmoURLs.url(for: .users)
        
        let parameters = ["username": username, "admin": admin ? "true" : "false"]
        
        LoadingIndicator.startAnimating()
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters).responseData { [weak self] response in
                            
                            LoadingIndicator.stopAnimating()
                            
                            guard response.result.isSuccess else {
                                self?.showAlert(with: "Error", message: "Unable to create user.")
                                return
                            }
                            
                            guard let jsonData = response.result.value else { return }
                            
                            let info = try? JSONDecoder().decode(UserTokenInfo.self, from: jsonData)
                            
                            guard let userInfo = info else {
                                self?.showAlert(with: "Error", message: "Something went wrong. Invalid data received.")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self?.login(with: userInfo)
                            }
        }
    }
    
    func fetchExistingUsers() {
        
        let url = NexmoURLs.url(for: .users)
        
        LoadingIndicator.startAnimating()
        
        Alamofire.request(url).responseData { [weak self] response in
            
            LoadingIndicator.stopAnimating()
            
            guard response.result.isSuccess else {
                self?.showAlert(with: "Error", message: "Unable to fetch extisting user.")
                return
            }
            
            guard let jsonData = response.result.value else { return }
            
            let users = try? JSONDecoder().decode([User].self, from: jsonData)
            
            guard let allUsers = users, allUsers.isEmpty == false else {
                self?.showAlert(with: "Error", message: "No existing user found.")
                return
            }
            
            DispatchQueue.main.async {
                self?.showAvailableUsers(allUsers)
            }
        }
    }
    
    func authenticationUser(with name: String, completion: @escaping ((String) -> Void)) {
        
        let url = NexmoURLs.url(for: .authentication) + "/" + name
        
        LoadingIndicator.startAnimating()
        
        Alamofire.request(url).responseJSON { [weak self] response in
            
            LoadingIndicator.stopAnimating()
            
            guard let json = response.result.value as? [String: Any],
                let userJWT = json["user_jwt"] as? String else {
                    self?.showAlert(with: "Error", message: "Invalid user.")
                    return
            }
            
            completion(userJWT)
        }
    }
}

