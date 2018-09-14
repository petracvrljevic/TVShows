//
//  Helper.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 13/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import MBProgressHUD

class Helper: NSObject {
    
    static let pinkColor = UIColor(displayP3Red: 255/255, green: 117/255, blue: 140/255, alpha: 1)
    static let lightPinkColor = UIColor(displayP3Red: 255/255, green: 204/255, blue: 213/255, alpha: 1)

    func showErrorAlertWithMessage(message: String, view: UIViewController)
    {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction (title: "OK", style: .default, handler: nil))
        
        view.present(alertController, animated: true, completion: nil)
    }
    
    func setStatusBarColorLight() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setStatusBarColorDefault() {
        UIApplication.shared.statusBarStyle = .default
    }
    
    func customBackButton(view: UIView) -> UIButton {
        
        let backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "ic-navigate-back"), for: .normal)
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        if isIphoneX() {
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        }
        else {
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        }
        
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        
        return backButton
    }
    
    func isIphoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436 {
                return true
            }
        }
        return false
    }
    
    func addProgressNotification() {
        if let vc = UIApplication.shared.topMostViewController() {
            let progressNotification = MBProgressHUD.showAdded(to: vc.view, animated: true)
            progressNotification.isUserInteractionEnabled = false
        }
    }
    
    func hideProgressNotification() {
        if let vc = UIApplication.shared.topMostViewController() {
            MBProgressHUD.hide(for: vc.view, animated: true)
        }
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
