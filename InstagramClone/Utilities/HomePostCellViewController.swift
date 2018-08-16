//
//  HomeCellViewController.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 8/15/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Firebase

class HomePostCellViewController: UICollectionViewController, HomePostCellDelegate {
  
    var posts = [Post]()
    
    func showEmptyStateViewIfNeeded() {}
    
    //MARK: - HomePostCellDelegate
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapUser(user: User) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func didTapOptions(post: Post) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if currentLoggedInUserId == post.user.uid {
            if let deleteAction = deleteAction(forPost: post) {
                alertController.addAction(deleteAction)
            }
        } else {
            if let unfollowAction = unfollowAction(forPost: post) {
                alertController.addAction(unfollowAction)
            }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAction(forPost post: Post) -> UIAlertAction? {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return nil }
        
        let action = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            
            let alert = UIAlertController(title: "Delete Post?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
                
                Database.database().deletePost(withUID: currentLoggedInUserId, postId: post.id) { (_) in
                    if let postIndex = self.posts.index(where: {$0.id == post.id}) {
                        self.posts.remove(at: postIndex)
                        self.collectionView?.reloadData()
                        self.showEmptyStateViewIfNeeded()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        })
        return action
    }
    
    private func unfollowAction(forPost post: Post) -> UIAlertAction? {
        let action = UIAlertAction(title: "Unfollow", style: .destructive) { (_) in
            
            let uid = post.user.uid
            Database.database().unfollowUser(withUID: uid, completion: { (_) in
                let filteredPosts = self.posts.filter({$0.user.uid != uid})
                self.posts = filteredPosts
                self.collectionView?.reloadData()
                self.showEmptyStateViewIfNeeded()
            })
        }
        return action
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var post = posts[indexPath.item]
        
        if post.hasLiked {
            Database.database().reference().child("likes").child(post.id).removeValue { (err, _) in
                if let err = err {
                    print("Failed to unlike post:", err)
                    return
                }
                post.hasLiked = false
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
        } else {
            let values = [uid : 1]
            Database.database().reference().child("likes").child(post.id).updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to like post:", err)
                    return
                }
                post.hasLiked = true
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
    }
    
}
