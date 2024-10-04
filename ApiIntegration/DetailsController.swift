import Foundation
import UIKit

class DetailsController: UIViewController {
    
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var FirstNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar and back button
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // Fetch user data from UserDefaults and populate the labels
        loadUserData()
    }
    
    func loadUserData() {
        // Fetch user data from UserDefaults (or another persistence mechanism)
        if let username = UserDefaults.standard.string(forKey: "username"),
           let email = UserDefaults.standard.string(forKey: "email"),
           let firstName = UserDefaults.standard.string(forKey: "firstName"),
           let lastName = UserDefaults.standard.string(forKey: "lastName"),
           let gender = UserDefaults.standard.string(forKey: "gender") {
            
            // Populate the labels with the retrieved data
            Username.text = "\(username)"
            Email.text = "\(email)"
            FirstNameLabel.text = "Hi \(firstName)"
            Name.text = "\(firstName) \(lastName)"
            Gender.text = "\(gender)"
        } else {
            // Handle missing data if needed
            showAlert(message: "Failed to load user details.")
        }
    }
    
    // Helper function to show alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

