//
//  LoginViewController.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var hideShowPasswordButton: UIButton!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var loginButtonEnabled = false
    var passwordHidden = true
    var rememberMe = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupUI()
        checkRemember()
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        
        handleRememberMe()
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            let params: Parameters = ["email": email,
                                      "password": password]
            
            
            APIHelper().login(url: APIHelper.loginURL, params: params) { (success) in
                if success {
                    self.performSegue(withIdentifier: "shows", sender: self)
                }
                else {
                    Helper().showErrorAlertWithMessage(message: "Error with logging in!", view: self)
                }
            }
        }

    }
    
    @IBAction func hideShowPasswordTapped(_ sender: UIButton) {
        passwordHidden = !passwordHidden
        setShowPasswordIcon()
    }
    
    @IBAction func rememberMeTapped(_ sender: UIButton) {
        rememberMe = !rememberMe
        setRememberMeIcon()
    }
    
    private func handleRememberMe() {
        if rememberMe {
            if let email = emailTextField.text, let password = passwordTextField.text {
                UserDefaults.standard.set(true, forKey: "rememberMe")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(password, forKey: "password")
            }
        }
        else {
            UserDefaults.standard.set(false, forKey: "rememberMe")
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "password")
        }
        UserDefaults.standard.synchronize()
    }
    
    private func checkRemember() {
        
        if UserDefaults.standard.bool(forKey: "rememberMe") == true {
            emailTextField.text = UserDefaults.standard.string(forKey: "email")
            passwordTextField.text = UserDefaults.standard.string(forKey: "password")
            rememberMe = true
            setRememberMeIcon()
            loginButtonEnabled = true
            loginButton.isEnabled = loginButtonEnabled
            setLoginButtonUI()
        }
        
    }
    
}

//MARK: - UI methods

extension LoginViewController {
    
    private func setupUI() {
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        emailTextField.title = "Email"
        passwordTextField.title = "Password"
        
        emailTextField.selectedLineColor = UIColor.lightGray
        passwordTextField.selectedLineColor = UIColor.lightGray
        
        loginButton.layer.cornerRadius = 6
        loginButton.isEnabled = loginButtonEnabled
    }
    
    private func setShowPasswordIcon() {
        if passwordHidden {
            hideShowPasswordButton.setImage(#imageLiteral(resourceName: "ic-characters-hide"), for: .normal)
        }
        else {
            hideShowPasswordButton.setImage(#imageLiteral(resourceName: "ic-hide-password"), for: .normal)
            
        }
        passwordTextField.isSecureTextEntry = passwordHidden
    }
    
    private func setRememberMeIcon() {
        if rememberMe {
            rememberMeButton.setImage(#imageLiteral(resourceName: "ic-checkbox-filled"), for: .normal)
        }
        else {
            rememberMeButton.setImage(#imageLiteral(resourceName: "ic-checkbox-empty"), for: .normal)
        }
    }
    
    private func setLoginButtonUI() {
        if loginButtonEnabled {
            loginButton.backgroundColor = Helper.pinkColor
        }
        else {
            loginButton.backgroundColor = Helper.lightPinkColor
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updateText = text.replacingCharacters(in: textRange, with: string)
            loginButtonEnabled = (updateText.count > 0 && ((textField == passwordTextField && (emailTextField.text?.count)! > 0) || (textField == emailTextField && (passwordTextField.text?.count)! > 0)))
        }
        loginButton.isEnabled = loginButtonEnabled
        setLoginButtonUI()
        return true
    }
    
}
