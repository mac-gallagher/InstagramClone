//
//  UserProfileController.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 3/19/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    var user: User?
    
    private var isFinishedPaging = false
    private var posts = [Post]()
    
    private var isGridView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
        
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserProfilePhotoGridCell.self, forCellWithReuseIdentifier: UserProfilePhotoGridCell.cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: HomePostCell.cellId)
        
        configureUser()
    }
    
    private func configureUser() {
        let uid = user?.uid ?? (Auth.auth().currentUser?.uid ?? "")
        Database.database().fetchUser(withUID: uid, completion: { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            self.paginatePosts()
        }) { (err) in
            print("Failed to fetch user: ", err)
        }
    }
    
    private func paginatePosts() {
        print("Starting paging for more posts")
        
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            guard let user = self.user else { return }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                
                post.id = snapshot.key
                
                self.posts.append(post)
                
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to paginate posts:", err)
        }
        
    }
    
    private func fetchOrderedPosts() {
        guard let uid = user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let user = self.user else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch ordered posts:", err)
        }
    }
    
    @objc private func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == posts.count - 1, !isFinishedPaging {
            print("Paginating for posts")
            paginatePosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfilePhotoGridCell.cellId, for: indexPath) as! UserProfilePhotoGridCell
            cell.post = posts[indexPath.item]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        return header
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 //username and userProfileImageView
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    //MARK: - UserProfileHeaderDelegate
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    
}









