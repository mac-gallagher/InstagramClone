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
            reloadData()
        }
    }
    
    private let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "user")
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
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
    
    private let padding: CGFloat = 12
    
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
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        layoutBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: padding, paddingRight: padding)
        
        layoutUserStatsView()
        
        addSubview(followButton)
        followButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, right: followingLabel.rightAnchor, paddingTop: 2, height: 34)
    }
    
    private func layoutUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: padding, paddingLeft: padding, paddingRight: padding, height: 50)
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
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        stackView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 44)
    }
    
    func reloadData() {
        guard let user = user else { return }
        usernameLabel.text = user.username
        reloadFollowButton()
        reloadUserStats()
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    private func reloadFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            followButton.type = .edit
            return
        }
        
        let previousButtonType = followButton.type
        followButton.type = .loading
        
        Database.database().isFollowingUser(withUID: userId, completion: { (following) in
            if following {
                self.followButton.type = .unfollow
            } else {
                self.followButton.type = .follow
            }
        }) { (err) in
            self.followButton.type = previousButtonType
        }
    }
    
    private func reloadUserStats() {
        guard let uid = user?.uid else { return }
        
        Database.database().numberOfPostsForUser(withUID: uid) { (count) in
            self.postsLabel.setValue(count)
        }
        
        Database.database().numberOfFollowersForUser(withUID: uid) { (count) in
            self.followersLabel.setValue(count)
        }
        
        Database.database().numberOfFollowingForUser(withUID: uid) { (count) in
            self.followingLabel.setValue(count)
        }
    }
    
    @objc private func handleTap() {
        guard let userId = user?.uid else { return }
        if followButton.type == .edit { return }
        
        let previousButtonType = followButton.type
        followButton.type = .loading
        
        if previousButtonType == .follow {
            Database.database().followUser(withUID: userId) { (err) in
                if err != nil {
                    self.followButton.type = previousButtonType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
            
        } else if previousButtonType == .unfollow {
            Database.database().unfollowUser(withUID: userId) { (err) in
                if err != nil {
                    self.followButton.type = previousButtonType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.updateHomeFeed, object: nil)
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






