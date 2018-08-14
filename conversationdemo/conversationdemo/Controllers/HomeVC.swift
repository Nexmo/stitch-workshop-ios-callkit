//
//  HomeVC.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/18/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Stitch
import Alamofire

class HomeVC: UIViewController {
    
    // MARK: - IBOutlets
    
    
    // MARK: - Data
    
    var loggedInUser: User?
    
    let client: ConversationClient = {
        let config = Stitch.Configuration.init(with: .info,
                                               autoReconnect: false,
                                               autoDownload: false,
                                               clearAllData: true,
                                               pushNotifications: true)
        ConversationClient.configuration = config
        return ConversationClient.instance
    }()
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Actions
    
    @IBAction func loginAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Login", message: "How would you like to login?", preferredStyle: .alert)
        
        let newUserAction = UIAlertAction(title: "New User", style: .default, handler: { [weak self] _ in
            self?.presentNewUserOptions()
        })
        
        let returningUserAction = UIAlertAction(title: "Returning User", style: .default, handler: { [weak self] _ in
            self?.fetchExistingUsers()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(newUserAction)
        alert.addAction(returningUserAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func chatAction(_ sender: Any) {
        
        self.client.disconnect()
    }
    
    // MARK: - Alerts
    
    func presentNewUserOptions() {
        
        let alert = UIAlertController(title: "Enter your username.", message: nil, preferredStyle: .alert)
        
        let asAdminAction = UIAlertAction(title: "Create as admin", style: .default, handler: { [weak self] _ in
            guard let username = alert.textFields?.first?.text, username.isEmpty == false else { return }
            self?.createUser(with: username)
        })
        
        let normalUserAction = UIAlertAction(title: "Create normal user", style: .default, handler: { [weak self] _ in
            guard let username = alert.textFields?.first?.text, username.isEmpty == false else { return }
            self?.createUser(with: username, admin: false)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(asAdminAction)
        alert.addAction(normalUserAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in textField.placeholder = "Username" }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAvailableUsers(_ users: [User]) {
        
        let alert = UIAlertController(title: "Select User !!", message: nil, preferredStyle: .alert)
        
        users.forEach { user in
            let userAction = UIAlertAction(title: user.name, style: .default, handler: { [weak self] _ in
                guard let name = user.name else { return }
                self?.authenticationUser(with: name, completion: { userJWT in
                    DispatchQueue.main.async {
                        let userInfo = UserTokenInfo(user: user, userJWT: userJWT)
                        self?.login(with: userInfo)
                    }
                })
            })
            alert.addAction(userAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAvailableConversation(_ conversation: [[String:String]]) {
        
        let alert = UIAlertController(title: "Select Conversation !!", message: nil, preferredStyle: .alert)
        
        conversation.forEach { convo in
            guard let name = convo["name"] else { return }
            let conversationAction = UIAlertAction(title: name, style: .default, handler: { [weak self] _ in
                guard let uuid = convo["uuid"] else { return }
                self?.joinConversation(with: uuid)
            })
            alert.addAction(conversationAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertToStartChat() {
        
        let alert = UIAlertController(title: "Conversation", message: "Enter display name for your conversation.", preferredStyle: .alert)
        
        let startAction = UIAlertAction(title: "Start", style: .default, handler: { [weak self] _ in
            let displayName = alert.textFields?.first?.text ?? "No name"
            self?.createConversation(with: displayName, join: true)
        })
        alert.addAction(startAction)
        
        let joinExistingAction = UIAlertAction(title: "Join existing conversation", style: .default, handler: { [weak self] _ in
            self?.fetchAllExistingConversation()
        })
        alert.addAction(joinExistingAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in textField.placeholder = "Display Name..." }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(with title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "ChatSceneSegue",
            let chatVC = segue.destination as? ChatVC,
            let conversation = sender as? Stitch.Conversation else { return }
        
        chatVC.conversation = conversation
    }
}

