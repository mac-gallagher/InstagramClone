//
//  CommentCell.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 8/3/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func didTapUser(user: User)
}

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            configureComment()
        }
    }
    
    var delegate: CommentCellDelegate?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    private let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
        iv.image = #imageLiteral(resourceName: "user")
        return iv
    }()
    
    static var cellId = "commentCellId"
    
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
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 04, paddingRight: 4)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 0.5)
    }
    
    private func configureComment() {
        guard let comment = comment else { return }
        
        let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = comment.creationDate.timeAgoDisplayShort()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        
        textView.attributedText = attributedText
        
        if let profileImageUrl = comment.user.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        } else {
            profileImageView.image = #imageLiteral(resourceName: "user")
        }
    }
    
    @objc private func handleTap() {
        guard let user = comment?.user else { return }
        delegate?.didTapUser(user: user)
    }
}
