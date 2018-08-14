//
//  ProviderDelegate.swift
//  conversationdemo
//
//  Created by Eric Giannini on 8/14/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import AVFoundation
import CallKit

class ProviderDelegate: NSObject {
    
    fileprivate let callManager: CallManager
    fileprivate let provider: CXProvider
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Stitch")
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        return providerConfiguration
    }
    
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?) {
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                let call = Caller(uuid: uuid, handle: handle)
                self.callManager.add(call: call)
            }
            
            completion?(error as NSError?)
        }
    }
}

extension ProviderDelegate: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        stopAudio()
        
        for call in callManager.calls {
            call.end()
        }
        
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        configureAudioSession()
        call.answer()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        startAudio()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        stopAudio()
        call.end()
        action.fulfill()
        callManager.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Caller(uuid: action.callUUID, outgoing: true, handle: action.handle.value)
        
        configureAudioSession()
        
        call.connectedStateChanged = { [weak self, weak call] in
            guard let strongSelf = self, let call = call else { return }
            
            if call.connectedState == .pending {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if call.connectedState == .complete {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }
        
        call.start { [weak self, weak call] success in
            guard let strongSelf = self, let call = call else { return }
            
            if success {
                action.fulfill()
                strongSelf.callManager.add(call: call)
            } else {
                action.fail()
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.state = action.isOnHold ? .held : .active
        if call.state == .held {
            stopAudio()
        } else {
            startAudio()
        }
        action.fulfill()
    }
}
