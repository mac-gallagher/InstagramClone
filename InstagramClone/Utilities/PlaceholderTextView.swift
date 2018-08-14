//
//  CommentInputTextView.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 8/4/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: .UITextViewTextDidChange, object: nil)
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    func showPlaceholderLabel() {
        placeholderLabel.isHidden = false
    }
    
    @objc private func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}


































