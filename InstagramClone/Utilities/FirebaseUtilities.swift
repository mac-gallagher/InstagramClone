//
//  FirebaseUtilities.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 7/30/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import Foundation
import Firebase

extension Auth {
    func createUser(withEmail email: String, username: String, password: String, image: UIImage?, completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err: Error?) in
            if let err = err { completion(err); return }
            
            Storage.storage().uploadUserProfileImage(image: image, completion: { (profileImageUrl, err) in
                if let err = err { completion(err); return }
                
                guard let uid = user?.user.uid else { return }
                Database.database().uploadUser(withUID: uid, username: username, profileImageUrl: profileImageUrl, completion: { (err) in
                    if let err = err { completion(err); return }
                    completion(nil)
                })
            })
        })
    }
}

extension Storage {
    fileprivate func uploadUserProfileImage(image: UIImage?, completion: @escaping (String?, Error?) -> ()) {
        guard let image = image else { completion(nil, nil); return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err { completion(nil, err); return }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err { completion(nil, err); return }
                
                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                completion(profileImageUrl, nil)
            })
        })
    }
}

extension Database {

    func fetchUser(withUID uid: String, completion: @escaping (User) -> (), withCancel cancel: ((Error) -> ())? = nil) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (err) in
            cancel?(err)
        }
    }
    
    func followingCountForUser(withUID uid: String) -> Int {
        return 0
    }
    
    func followerCountForUser(withUID uid: String) -> Int {
        return 0
    }
    
    func postCountForUser(withUID uid: String) -> Int {
        return 0
    }
    
    func fetchAllUsers(includeCurrentUser: Bool = true, completion: @escaping ([User]) -> (), withCancel cancel: ((Error) -> ())? = nil) {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            var users = [User]()
            
            dictionaries.forEach({ (key, value) in
                if !includeCurrentUser, key == Auth.auth().currentUser?.uid { return }
                
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                users.append(user)
            })
            
            users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            completion(users)
            
        }) { (err) in
            cancel?(err)
        }
    }
    
    fileprivate func uploadUser(withUID uid: String, username: String, profileImageUrl: String? = nil, completion: ((Error?) -> ())? = nil) {
        var dictionaryValues = ["username": username]
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        
        let values = [uid: dictionaryValues]
        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err { completion?(err); return }
            completion?(nil)
        })
    }
    
}
