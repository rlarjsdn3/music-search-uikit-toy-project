//
//  UIAlertController+Extension.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/18.
//

import UIKit

extension UIAlertController {
    func addAction(_ actions: [UIAlertAction]) {
        for action in actions {
            self.addAction(action)
        }
    }
}
