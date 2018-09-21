//
//  LoginController.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 3/19/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    private let logoContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        container.addSubview(logoImageView)
        logoImageView.anchor(width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        return container
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainBlue
            ]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, height: 130 + UIApplication.shared.statusBarFrame.height)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, height: 50)
        
        setupInputFields()
    }
    
    private func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingRight: 40, height: 140)
    }
    
    private func resetInputFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        emailTextField.isUserInteractionEnabled = false
        passwordTextField.isUserInteractionEnabled = false
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            if let err = err {
                print("Failed to sign in with email:", err)
                self.resetInputFields()
                return
            }
            
            if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController {
                mainTabBarController.setupViewControllers()
                mainTabBarController.selectedIndex = 0
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @objc private func handleTapOnView() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func handleTextInputChange() {
        let isFormValid = emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.mainBlue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc private func handleShowSignUp() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}




