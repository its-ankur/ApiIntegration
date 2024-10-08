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
        
        // Hide the navigation bar for this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
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
    
    @IBAction func fabButtonClicked(_ sender: UIButton) {
        let fabMenu = UIAlertController(title: "Scan Options", message: nil, preferredStyle: .actionSheet)

        fabMenu.addAction(UIAlertAction(title: "QR Code", style: .default, handler: { _ in
            self.navigateToQRCodePage()
        }))

        fabMenu.addAction(UIAlertAction(title: "Bar Code", style: .default, handler: { _ in
            self.navigateToBarCodePage()
        }))

        fabMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Handle popover presentation for iPad to prevent a crash
        if let popoverController = fabMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = sender.frame
            popoverController.permittedArrowDirections = .any
        }

        self.present(fabMenu, animated: true, completion: nil)
    }

    
    func navigateToQRCodePage() {
        let qrScannerVC = storyboard?.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        self.navigationController?.pushViewController(qrScannerVC, animated: true)
    }

    func navigateToBarCodePage() {
        let barCodeScannerVC = storyboard?.instantiateViewController(withIdentifier: "BarCodeScannerViewController") as! BarCodeScannerViewController
        self.navigationController?.pushViewController(barCodeScannerVC, animated: true)
    }
    
}
