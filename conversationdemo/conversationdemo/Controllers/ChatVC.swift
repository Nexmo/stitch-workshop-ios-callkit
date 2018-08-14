//
//  ChatVC.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/20/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Stitch

class ChatVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var chatTableView: UITableView!
        
    @IBOutlet weak var typingLabel: UILabel!
    
    @IBOutlet weak var endCallButton: UIButton!
    
    // MARK: - Data
    
    let client: ConversationClient = {
        return ConversationClient.instance
    }()
    
    var conversation: Stitch.Conversation?
    
    var call: Call? {
        didSet {
            DispatchQueue.main.async { [weak self] in self?.endCallButton.isHidden = (self?.call == nil) }
        }
    }
    
    var whoIsTyping = Set<String>()
    
    lazy var textMessages: [TextMessage] = []
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = conversation?.name
        
        observeChatMessages()
        observeTypingStatus()
    }
    
    // MARK: - NSObject Methods
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) && UIPasteboard.general.image != nil {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    override func paste(_ sender: Any?) {
        
        showSendCopiedImageAlert()
    }
    
    // MARK: - Actions
    
    @IBAction func addBarAction(_ sender: Any) {
        
        showInviteMemberAlert()
    }
    
    @IBAction func infoBarAction(_ sender: Any) {
        
        showAllActiveUsersAlert()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        guard let text = inputTextField.text else { return }
        
        send(text)
    }
    
    @IBAction func endCallAction(_ sender: Any) {
        
        conversation?.media.disable()
    }
    
    // MARK: - Private Methods
    
    func showAllActiveUsersAlert() {
        
        let alert = UIAlertController(title: "View or edit users", message: nil, preferredStyle: .alert)
        
        conversation?.members.forEach { member in
            let userAction = UIAlertAction(title: member.user.name, style: .default, handler: { [weak self] _ in
                self?.showMoreInfoAlert(for: member)
            })
            alert.addAction(userAction)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showMoreInfoAlert(for member: Member) {
        
        let alert = UIAlertController(title: "User Info", message: "Name: \(member.user.name)\nId: \(member.uuid)", preferredStyle: .alert)
        
        let kickAction = UIAlertAction(title: "Kick", style: .destructive, handler: { [weak self] _ in
            self?.kick(member)
        })
        alert.addAction(kickAction)
        
        let callAction = UIAlertAction(title: "Call", style: .default, handler: { [weak self] _ in
            self?.requestAudioPermission(completion: { success in
                if success {
                    self?.call(member)
                }
            })
        })
        alert.addAction(callAction)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showInviteMemberAlert() {
        
        let alert = UIAlertController(title: "Invite", message: "Enter username to invite", preferredStyle: .alert)
        
        let inviteAction = UIAlertAction(title: "Invite", style: .destructive, handler: { [weak self] _ in
            guard let username = alert.textFields?.first?.text else { return }
            self?.inviteUser(username)
        })
        alert.addAction(inviteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in textField.placeholder = "Username..." }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSendCopiedImageAlert() {
        
        let alert = UIAlertController(title: "Alert", message: "Would you like to send copied image?", preferredStyle: .alert)
        
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { [weak self] _ in
            guard let image = UIPasteboard.general.image else { return }
            self?.send(image)
        })
        alert.addAction(sendAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(with title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}


