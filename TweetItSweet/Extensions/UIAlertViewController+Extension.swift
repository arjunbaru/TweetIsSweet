//
//  UIAlertViewController+Extension.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 16/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    convenience init(title: String, message: String?, prefferedStyle: UIAlertController.Style, buttonTitle: String, buttonhandler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, message: message, preferredStyle: prefferedStyle)
        let action = UIAlertAction(title: buttonTitle, style: .destructive, handler: buttonhandler)
        self.addAction(action)
    }
}
