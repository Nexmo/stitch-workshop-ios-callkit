//
//  CallManager.swift
//  conversationdemo
//
//  Created by Eric Giannini on 8/14/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Foundation
import CallKit

class CallManager {
    
    private let callController = CXCallController()
    
    var callsChangedHandler: (() -> Void)?
    
    private(set) var calls = [Caller]()
    
    func callWithUUID(uuid: UUID) -> Caller? {
        guard let index = calls.index(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }
    
    func startCall(handle: String, videoEnabled: Bool) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = videoEnabled
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction)
    }
    
    func add(call: Caller) {
        calls.append(call)
        call.stateChanged = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.callsChangedHandler?()
        }
        callsChangedHandler?()
    }
    
    func end(call: Caller) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction)
    }
    
    func remove(call: Caller) {
        guard let index = calls.index(where: { $0 === call }) else { return }
        calls.remove(at: index)
        callsChangedHandler?()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        callsChangedHandler?()
    }
    
    func setHeld(call: Caller, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
}

