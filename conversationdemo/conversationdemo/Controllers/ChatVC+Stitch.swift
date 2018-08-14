//
//  ChatVC+Stitch.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/20/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Stitch

extension ChatVC {
    
    func observeChatMessages() {
        
        conversation?.events.newEventReceived.subscribe(onSuccess: { event in
            guard event.isCurrentlyBeingSent == false else { return }
            
            DispatchQueue.main.async { [weak self] in
                
                switch event {
                case let textEvent as TextEvent:
                    guard let text = textEvent.text else { return }
                    self?.chatTextView.insertText("\(text)\n")
                    
                case _ as MediaEvent:
                    self?.showAlert(with: "Media Received", message: "You have received a media in chat.")
                    
                default: break
                }
            }
        })
    }
    
    func observeTypingStatus() {
        
        conversation?.members.forEach { member in
            member.typing
                .mainThread
                .subscribe(onSuccess: { [weak self] isTyping in
                    
                    guard member.user.isMe == false, let weakSelf = self else { return }
                    
                    let name = member.user.name
                    if isTyping {
                        weakSelf.whoIsTyping.insert(name)
                    } else {
                        weakSelf.whoIsTyping.remove(name)
                    }
                    
                    guard weakSelf.whoIsTyping.isEmpty == false else {
                        DispatchQueue.main.async { weakSelf.typingLabel.text = nil }
                        return
                    }
                    
                    var caption = weakSelf.whoIsTyping.joined(separator: ", ")
                    
                    caption += (weakSelf.whoIsTyping.count == 1) ? " is typing..." : " are typing..."
                    
                    DispatchQueue.main.async { weakSelf.typingLabel.text = caption }
                })
        }
    }
    
    func send(_ text: String) {
        do {
            try conversation?.send(text)
            inputTextField.text = nil
        } catch let error {
            print("Error in sending message: ", error.localizedDescription)
        }
    }
    
    func send(_ image: UIImage) {
        
        guard let data = UIImagePNGRepresentation(image) ?? UIImageJPEGRepresentation(image, 1) else { return }
        
        do {
            try conversation?.send(data)
            inputTextField.text = nil
        } catch let error {
            print("Error in sending message: ", error.localizedDescription)
        }
    }
    
    func kick(_ member: Member) {
        
        member.kick({ [weak self] in
            self?.showAlert(with: "Success", message: "\(member.user.name) kicked out of conversation.")
        }) { [weak self] error in
            self?.showAlert(with: "Unable to kick member out", message: "Reason: \(error.localizedDescription)")
        }
    }
    
    func call(_ member: Member) {
        
        client.media.call([member.user.name],
                          onSuccess: { [weak self] result in
                            print("Call Result: ", result)
                            self?.call = result.call
        }) { [weak self] error in
            self?.showAlert(with: "Unable to call member.", message: "Reason: \(error.localizedDescription)")
        }
    }
    
    func inviteUser(_ username: String) {
        
        conversation?.invite(username: username,
                             userId: nil,
                             withAudio: false,
                             onSuccess: { [weak self] _ in
                                self?.showAlert(with: "Success", message: "\(username) invited to conversation.")
            }, onError: { [weak self] error in
                self?.showAlert(with: "Unable to invite member.", message: "Reason: \(error.localizedDescription)")
        })
    }
}

