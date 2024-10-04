//
//  ViewController.swift
//  ApiIntegration
//
//  Created by Ankur on 03/10/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var UserName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func LoginButton(_ sender: UIButton) {
        guard let username = UserName.text, !username.isEmpty,
              let password = Password.text, !password.isEmpty else {
                   // Handle empty fields
                   showAlert(message: "Please enter both username and password.")
                   return
               }
               
               // Call AuthService login function
               AuthService.shared.login(username: username, password: password) { result in
                   switch result {
                   case .success(let user):
                       // Successfully logged in, navigate to details page
                       self.saveUserData(user)
                       self.UserName.text=""
                       self.Password.text=""
                       self.navigateToDetailsPage()
                   case .failure(let error):
                       // Handle login error
                       self.showAlert(message: "Login failed: \(error.localizedDescription)")
                   }
               }
    }
    
    // Save user data locally (e.g., UserDefaults)
        func saveUserData(_ user: User) {
            UserDefaults.standard.set(user.accessToken, forKey: "accessToken")
            UserDefaults.standard.set(user.username, forKey: "username")
            UserDefaults.standard.set(user.email, forKey: "email")
                    UserDefaults.standard.set(user.firstName, forKey: "firstName")
                    UserDefaults.standard.set(user.lastName, forKey: "lastName")
                    UserDefaults.standard.set(user.gender, forKey: "gender")
                    UserDefaults.standard.set(user.image, forKey: "profileImage")

            // You can save other details as needed
        }
    
    // Navigate to the details page after successful login
       func navigateToDetailsPage() {
           let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailsController") as! DetailsController
           navigationController?.pushViewController(detailsVC, animated: true)
       }
    
    // Helper function to show an alert
        func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
}

