//
//  SceneDelegate.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-18.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var authListener:AuthStateDidChangeListenerHandle?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        fetchRequirements {
            self.listenToAuth()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func fetchRequirements(completion: @escaping()->()) {
        return completion()
    }

    func listenToAuth() {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        
        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
                user.getIDTokenForcingRefresh(true, completion: { token, error in
                    if token != nil, error == nil {
                        //NetworkManager.shared.token = token
                        print("IDTOKEN: \(token)")
                        PolyravenAPI.authToken = token
                        self.fetchUserData {
                            self.openHomeScreen()
                        }
                    } else {
                        do {
                            try Auth.auth().signOut()
                        } catch {}
                        self.openLoginScreen()
                    }
                })
            } else {
                
                guard let rootVC = self.window?.rootViewController else { return }
                
                if rootVC.children.count == 0 {
                    self.openLoginScreen()
                } else {
                    self.window?.rootViewController?.dismiss(animated: false, completion: {
                        self.openLoginScreen()
                    })
                }
                
            }
        }
        
    }
    
    func openLoginScreen() {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = main.instantiateViewController(identifier: "authVC") as! SignInViewController
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
    }
    
    func openHomeScreen() {
        
        ItemManager.shared.configure()
        RavenAPI.shared.enablePresenceDetection()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let controller = storyboard.instantiateViewController(withIdentifier: "mainVC")
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                //UserService.fcmToken = result.token
            }
        }
        
    }
    
    func fetchUserData(completion: @escaping (()->())) {
        RavenAPI.shared.getItems { items in
            ItemManager.shared.setItems(items)
            
            StockManager.shared.observe()
            
            RavenAPI.shared.observeItems()
            CurrencyManager.shared.observeRates()
            
            completion()
            
        }
        
    }


}
