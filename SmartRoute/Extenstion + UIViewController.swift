//
//  Extenstion + UIViewController.swift
//  SmartRoute
//
//  Created by zz on 08.02.2022.
//  Copyright © 2022 Vadim Vitkovskiy. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(title: String?, message : String?,searchTextField: Bool, buttonTitle: String, completionHandler: @escaping (_ text : String) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if searchTextField {
            alert.addTextField { (tf) in
                tf.placeholder = "Введите название города"
            }
        }
        
        let actionAddButton = UIAlertAction(title: "\(buttonTitle)", style: .default) { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            completionHandler(text)
        }
        let cancelButton = UIAlertAction(title: "Назад", style: .destructive, handler: nil)
        alert.addAction(actionAddButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
        
    }
}
