//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 3/19/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: UICollectionViewCell {
   
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            configureUser()
        }
    }
    
    private let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 80 / 2
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "user")
        return iv
    }()
    
    private let postsLabel = UserProfileStatsLabel(value: 0, title: "posts")
    private let followersLabel = UserProfileStatsLabel(value: 0, title: "followers")
    private let followingLabel = UserProfileStatsLabel(value: 0, title: "following")
    
    private lazy var followButton: UserProfileFollowButton = {
        let button = UserProfileFollowButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    private lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    static var headerId = "userProfileHeaderId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        layoutBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        layoutUserStatsView()
        
        addSubview(followButton)
        followButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    private func layoutUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    private func layoutBottomToolbar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
    }
    
    private func configureUser() {
        guard let user = user else { return }
        usernameLabel.text = user.username
        reloadFollowButton()
        reloadUserStats()
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    private func reloadFollowButton() {
        guard let userId = user?.uid else { return }
        
        let previousButtonType = followButton.type
        followButton.type = .loading
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {
            followButton.type = previousButtonType
            return
        }
        
        if currentLoggedInUserId == userId {
            followButton.type = .edit
            return
        }
        
        Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                self.followButton.type = .unfollow
            } else {
                self.followButton.type = .follow
            }
            
        }) { (err) in
            print("Failed to check if following:", err)
            self.followButton.type = previousButtonType
        }
    }
    
    private func reloadUserStats() {
        guard let uid = user?.uid else { return }
        
        Database.database().reference().child("posts").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                self.postsLabel.setValue(value: dictionaries.count)
            } else {
                self.postsLabel.setValue(value: 0)
            }
        }
        
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                self.followingLabel.setValue(value: dictionaries.count)
            } else {
                self.followingLabel.setValue(value: 0)
            }
        }
        
        Database.database().reference().child("followers").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                self.followersLabel.setValue(value: dictionaries.count)
            } else {
                self.followersLabel.setValue(value: 0)
            }
        }
    }
    
    func reloadData() {
        configureUser()
    }
    
    @objc private func handleTap() {
        guard let userId = user?.uid else { return }
        if followButton.type == .edit { return }
        
        let previousButtonType = followButton.type
        followButton.type = .loading
        
        if previousButtonType == .follow {
            Database.database().followUser(withUID: userId) { (err) in
                if let err = err {
                    print("Failed to follow user:", err)
                    self.followButton.type = previousButtonType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
            
        } else if previousButtonType == .unfollow {
            Database.database().unfollowUser(withUID: userId) { (err) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    self.followButton.type = previousButtonType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
        }
    }
    
    @objc private func handleChangeToGridView() {
        gridButton.tintColor = UIColor.mainBlue
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    @objc private func handleChangeToListView() {
        listButton.tintColor = UIColor.mainBlue
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
}






