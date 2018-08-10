//
//  CommentInputAccessoryView.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 8/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView, UITextViewDelegate {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    private let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.autocorrectionType = .no
        return tv
    }()
    
    private let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.setTitleColor(.lightGray, for: .normal)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        sb.isEnabled = false
        return sb
    }()
    
    override var intrinsicContentSize: CGSize { return .zero }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(submitButton)
        submitButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: .UITextViewTextDidChange, object: nil)
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
        submitButton.isEnabled = false
        submitButton.setTitleColor(.lightGray, for: .normal)
    }
    
    @objc private func handleSubmit() {
        guard let commentText = commentTextView.text else { return }
        delegate?.didSubmit(for: commentText)
        commentTextView.resignFirstResponder()
    }
    
    @objc private func handleTextChange() {
        guard let text = commentTextView.text else { return }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            submitButton.isEnabled = false
            submitButton.setTitleColor(.lightGray, for: .normal)
        } else {
            submitButton.isEnabled = true
            submitButton.setTitleColor(.black, for: .normal)
        }
    }
    
}



















