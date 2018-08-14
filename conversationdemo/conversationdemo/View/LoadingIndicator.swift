//
//  LoadingIndicator.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/19/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

struct LoadingIndicator {
    
    public static var size: CGFloat = 50
    
    public static var indicatorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    public static var textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    public static var backgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    public static var defaultMessage = "Loading..."
    
    public static var messageFont = UIFont.systemFont(ofSize: 17)
    
    public static func startAnimating(message: String? = defaultMessage) {
        
        let activityData = ActivityData(size: CGSize(width: size, height: size),
                                        message: message,
                                        messageFont: messageFont,
                                        messageSpacing: 30,
                                        type: .lineSpinFadeLoader,
                                        color: indicatorColor,
                                        backgroundColor: backgroundColor,
                                        textColor: textColor)
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        }
    }
    
    public static func stopAnimating() {
        
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
}

