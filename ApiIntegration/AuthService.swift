import Alamofire
import Foundation

// Model for the User data
struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}

// AuthService to manage login API calls and token refresh
class AuthService {
    static let shared = AuthService()
    
    // Function to check if the access token is expired
    func isTokenExpired() -> Bool {
        if let expiresAt = UserDefaults.standard.object(forKey: "expiresAt") as? Date {
            return Date() > expiresAt
        }
        return true // If no expiration date is found, consider the token expired
    }

    // Function to refresh the access token using refreshToken
    func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No refresh token available"])))
            return
        }
        
        let url = URL(string: "https://dummyjson.com/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the body with refresh token
        let body: [String: Any] = [
            "refreshToken": refreshToken,
            "expiresInMins": 30 // Optional
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Make the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let newAccessToken = json["accessToken"] as? String,
                   let newRefreshToken = json["refreshToken"] as? String {

                    // Save the new tokens and calculate new expiration time
                    UserDefaults.standard.set(newAccessToken, forKey: "accessToken")
                    UserDefaults.standard.set(newRefreshToken, forKey: "refreshToken")
                    let expiresAt = Date().addingTimeInterval(30 * 60) // 30 minutes
                    UserDefaults.standard.set(expiresAt, forKey: "expiresAt")

                    completion(.success(newAccessToken))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Function to log in a user
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "https://dummyjson.com/auth/login"
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
            "expiresInMins": 30
        ]
        
        // API Request with Alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: User.self) { response in
                switch response.result {
                case .success(let user):
                    // Successful login, save user data and token info
                    self.saveUserData(user)
                    completion(.success(user))
                    
                case .failure(let error):
                    // Handle failure
                    completion(.failure(error))
                }
            }
    }
    
    // Function to save user data and tokens after successful login
    private func saveUserData(_ user: User) {
        UserDefaults.standard.set(user.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(user.refreshToken, forKey: "refreshToken")
        
        // Set expiration date based on the current time
        let expiresAt = Date().addingTimeInterval(30 * 60) // 30 minutes
        UserDefaults.standard.set(expiresAt, forKey: "expiresAt")
        
        // Save other user details if needed
        UserDefaults.standard.set(user.username, forKey: "username")
        UserDefaults.standard.set(user.email, forKey: "email")
    }
}

