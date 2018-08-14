//
//  HomeVC+Stitch.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/18/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Stitch

extension HomeVC {
    
    func login(with info: UserTokenInfo) {
        
        LoadingIndicator.startAnimating()
        
        guard let jwt = info.userJWT else { return }
        
        loggedInUser = info.user
        
        self.client.login(with: jwt) { [weak self] result in
            
            LoadingIndicator.stopAnimating()
            
            guard result == .success else {
                self?.showAlert(with: "Unable to login", message: "Reason: \(result.errorDescription ?? "NA")")
                self?.client.disconnect()
                self?.loggedInUser = nil
                return
            }
            
            if let user = self?.client.account.user {
                print("DEMO - login successful and here is our \(user)")
            } else {
                print("Login success but user not found. Weird !!")
            }
            
            self?.showAlertToStartChat()
        }
    }
    
    func createConversation(with title: String, join: Bool) {
        
        LoadingIndicator.startAnimating()
        
        self.client.conversation.new(with: title,
                                     shouldJoin: join, { conversation in
                                        
                                        LoadingIndicator.stopAnimating()
                                        DispatchQueue.main.async { [weak self] in
                                            self?.performSegue(withIdentifier: "ChatSceneSegue", sender: conversation)
                                        }
                                        
        }, onError: { [weak self] error in
            
            LoadingIndicator.stopAnimating()
            self?.showAlert(with: "Unable to create conversation", message: "Reason: \(error.localizedDescription)")
            self?.client.disconnect()
            
            }, onComplete: {
                
                LoadingIndicator.stopAnimating()
                print(#function, "Complete")
        });
    }
    
    func joinConversation(with uuid: String) {
        
        LoadingIndicator.startAnimating()
        
        guard let userId = self.client.account.user?.uuid ?? loggedInUser?.id else { return }
        
        self.client.conversation.join(userId: userId,
                                      memberId: nil,
            uuid: uuid, { [weak self] state in
                
                LoadingIndicator.stopAnimating()
                print(#function, state)
                
                if state == "joined" {      
                    
                    self?.client.conversation.conversation(with: uuid, { conversation in
                        
                        LoadingIndicator.stopAnimating()
                        DispatchQueue.main.async { [weak self] in
                            self?.performSegue(withIdentifier: "ChatSceneSegue", sender: conversation)
                        }
                        
                    }, onError: { [weak self] error in
                        LoadingIndicator.stopAnimating()
                        self?.showAlert(with: "Unable to fetch conversation", message: "Reason: \(error.localizedDescription)")
                        self?.client.disconnect()
                    })
                }
                
        }) { [weak self] error in
            LoadingIndicator.stopAnimating()
            self?.showAlert(with: "Unable to join conversation", message: "Reason: \(error.localizedDescription)")
            self?.client.disconnect()
        }
    }
    
    func fetchAllExistingConversation() {
        
        LoadingIndicator.startAnimating()
        
        self.client.conversation.all({ [weak self] conversationInfo in
            
            LoadingIndicator.stopAnimating()
            self?.showAvailableConversation(conversationInfo)
            
        }) { [weak self] error in
            
            LoadingIndicator.stopAnimating()
            self?.showAlert(with: "Unable to fetch existing conversation", message: "Reason: \(error.localizedDescription)")
            self?.client.disconnect()
        }
    }
}

