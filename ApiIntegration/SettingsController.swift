//
//  SettingsController.swift
//  ApiIntegration
//
//  Created by Ankur on 07/10/24.
//

import Foundation

import UIKit

class SettingsController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func LogoutClicked(_ sender: UIButton) {
        // Create the alert controller
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        // Add the "Yes" action (for confirming logout)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            // Clear user data from UserDefaults
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "firstName")
            UserDefaults.standard.removeObject(forKey: "lastName")
            UserDefaults.standard.removeObject(forKey: "gender")
            UserDefaults.standard.removeObject(forKey: "profileImage")
            
            // Navigate to the ViewController (login page)
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                let navController = UINavigationController(rootViewController: viewController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        }
        
        // Add the "Cancel" action (to dismiss the dialog)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add the actions to the alert controller
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        // Present the alert controller
        present(alert, animated: true, completion: nil)
    }
    
}
