//
//  SceneDelegate.swift
//  HomeScreen
//
//  Created by Himadri  on 30/01/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Load JSON data
        DataManager.shared.loadAppData()
        
        // Instantiate Tab Bar Controller
        guard let tabBarController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateInitialViewController() as? UITabBarController else {
            return
        }
        
        // Inject data into HomeViewController
        if let homeNavController = tabBarController.viewControllers?[0] as? UINavigationController,
           let homeVC = homeNavController.viewControllers.first as? HomeViewController {
            
            let dm = DataManager.shared
            homeVC.currentUser = dm.currentUser
            homeVC.family = dm.family
            homeVC.otherProfiles = dm.allProfiles
            homeVC.messages = dm.messages
            
        }
        
        if let challengeNavController = tabBarController.viewControllers?[2] as? UINavigationController {
           
            if let challengeVC = challengeNavController.viewControllers.first as? ChallengeFirstViewController {
            challengeVC.challenges = DataManager.shared.family?.challenge
            challengeVC.familyMembers = DataManager.shared.allProfiles
                print("data transfered from scene delegate to challenge storyboard")
            } else {
                print("data didnt transfer from scene delegate to challenge storyboard")
            }
            
        }
        
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

