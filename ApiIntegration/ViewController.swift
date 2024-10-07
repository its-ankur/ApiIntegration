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
    
    // Create a toggle state
    var isPasswordVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Add the toggle button to the password field
        configurePasswordToggle()
        
    }
    
    // Configure the password toggle button
    func configurePasswordToggle() {
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.fill"), for: .normal) // Icon when password is hidden
        toggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected) // Icon when password is visible
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        Password.rightView = toggleButton
        Password.rightViewMode = .always
        Password.isSecureTextEntry = true // Initially, keep the password hidden
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle() // Toggle the state
        Password.isSecureTextEntry = !isPasswordVisible // Show or hide the password
        
        // Toggle the button icon
        sender.isSelected = isPasswordVisible
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
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    // Helper function to show an alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

