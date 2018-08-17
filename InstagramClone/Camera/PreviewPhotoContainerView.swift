//
//  PreviewPhotoContainerView.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 8/3/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancel_shadow2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return button
    }()
    
    private let savedLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Successfully"
        label.clipsToBounds = true
        label.layer.cornerRadius = 4
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.alpha = 0.7
        label.numberOfLines = 0
        label.backgroundColor = .black
        label.textAlignment = .center
        return label
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
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }
    
    @objc private func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc private func handleSave() {
        guard let previewImage = previewImageView.image else { return }
        
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, err) in
            if let err = err {
                print("Failed to save image to photo library:", err)
                return
            }
            DispatchQueue.main.async {
                self.presentSavedLabel()
            }
        }
    }
    
    private func presentSavedLabel()  {
        addSubview(savedLabel)
        savedLabel.alpha = 1
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        savedLabel.center = self.center
        
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: { (completed) in
            
            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                self.savedLabel.alpha = 0
            }, completion: { (_) in
                self.savedLabel.removeFromSuperview()
            })
            
        })
    }
}






























