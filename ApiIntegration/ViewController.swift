import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var UserName: UITextField!
    
    // Create a toggle state
    var isPasswordVisible = false
    
    // Constants for UserDefaults keys
    private enum UserDefaultsKeys {
        static let accessToken = "accessToken"
        static let username = "username"
        static let email = "email"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let gender = "gender"
        static let profileImage = "profileImage"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the toggle button to the password field
        configurePasswordToggle()
        
        // Dismiss keyboard when tapping outside of text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Set delegate for text fields to handle return key
        UserName.delegate = self
        Password.delegate = self
    }

    // MARK: - Dismiss Keyboard Methods
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // Dismiss the keyboard
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
        
        // Accessibility
        sender.accessibilityLabel = isPasswordVisible ? "Hide password" : "Show password"
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
                self.UserName.text = ""
                self.Password.text = ""
                self.navigateToDetailsPage()
            case .failure(let error):
                // Handle login error
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Save user data locally (e.g., UserDefaults)
    func saveUserData(_ user: User) {
        UserDefaults.standard.set(user.accessToken, forKey: UserDefaultsKeys.accessToken)
        UserDefaults.standard.set(user.username, forKey: UserDefaultsKeys.username)
        UserDefaults.standard.set(user.email, forKey: UserDefaultsKeys.email)
        UserDefaults.standard.set(user.firstName, forKey: UserDefaultsKeys.firstName)
        UserDefaults.standard.set(user.lastName, forKey: UserDefaultsKeys.lastName)
        UserDefaults.standard.set(user.gender, forKey: UserDefaultsKeys.gender)
        UserDefaults.standard.set(user.image, forKey: UserDefaultsKeys.profileImage)
    }
    
    // Navigate to the details page after successful login
    func navigateToDetailsPage() {
        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    // Helper function to show an alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
}

