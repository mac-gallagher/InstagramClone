//
//  HomePostHeader.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 8/8/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

class HomePostHeader: UIView {
    
    var user: User? {
        didSet {
            configureUser()
        }
    }
    
    private let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "user")
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(userProfileImageView)
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(optionsButton)
        optionsButton.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingRight: 8, width: 44)
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, right: optionsButton.leftAnchor, paddingLeft: 8)
    }
    
    private func configureUser() {
        guard let user = user else { return }
        usernameLabel.text = user.username
        if let profileImageUrl = user.profileImageUrl {
            userProfileImageView.loadImage(urlString: profileImageUrl)
        } else {
            userProfileImageView.image = #imageLiteral(resourceName: "user")
        }
    }
    
}




