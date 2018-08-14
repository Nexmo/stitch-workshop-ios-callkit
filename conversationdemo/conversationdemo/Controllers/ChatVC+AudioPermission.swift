//
//  ChatVC+AudioPermission.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/20/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import AVKit

extension ChatVC {
    
    func requestAudioPermission(completion: @escaping (_ success: Bool) -> Void) {
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            session.requestRecordPermission { success in
                completion(success)
            }
        } catch {
            print("Error requesting audio services: ", error.localizedDescription)
            completion(false)
        }
    }
    
}
