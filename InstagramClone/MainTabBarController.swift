//
//  MainTabBarController.swift
//  InstagramClone
//
//  Created by Mac Gallagher on 3/19/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .black
        delegate = self
        
        if Auth.auth().currentUser == nil {
            presentLoginController()
        } else {
            setupViewControllers()
        }
    }
    
    private func presentLoginController() {
        DispatchQueue.main.async { // wait until MainTabBarController is inside UI
            let loginController = LoginController()
            let navController = UINavigationController(rootViewController: loginController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    internal func setupViewControllers() {
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        let likeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
    }
    
    private func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        return navController
    }
    
    //MARK: UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let nacController = UINavigationController(rootViewController: photoSelectorController)
            present(nacController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}
