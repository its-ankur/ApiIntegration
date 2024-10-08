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
    
    private var isRequestInProgress: Bool = false
    private var ongoingRequest: DataRequest? // Store ongoing request
    
    // Function to check if the access token is expired
    func isTokenExpired() -> Bool {
        if let expiresAt = UserDefaults.standard.object(forKey: "expiresAt") as? Date {
            return Date() > expiresAt
        }
        return true // If no expiration date is found, consider the token expired
    }
    
    // Function to refresh the access token using refreshToken
    // Function to refresh the access token using refreshToken
    func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Check if another request is already in progress
        guard !isRequestInProgress else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
            return
        }
        
        isRequestInProgress = true // Set the flag to prevent new requests
        
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            isRequestInProgress = false // Reset the flag on failure
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No refresh token available"])))
            return
        }
        
        let url = "https://dummyjson.com/auth/refresh" // Update to use Alamofire
        let parameters: [String: Any] = [
            "refreshToken": refreshToken,
            "expiresInMins": 30 // Optional
        ]
        
        // Make the network request using Alamofire
        ongoingRequest = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { [weak self] response in
                guard let self = self else { return }
                defer { self.isRequestInProgress = false } // Ensure flag is reset when request is complete
                
                switch response.result {
                case .success(let json):
                    if let jsonDict = json as? [String: Any],
                       let newAccessToken = jsonDict["accessToken"] as? String,
                       let newRefreshToken = jsonDict["refreshToken"] as? String {
                        // Save the new tokens and calculate new expiration time
                        UserDefaults.standard.set(newAccessToken, forKey: "accessToken")
                        UserDefaults.standard.set(newRefreshToken, forKey: "refreshToken")
                        let expiresAt = Date().addingTimeInterval(30 * 60) // 30 minutes
                        UserDefaults.standard.set(expiresAt, forKey: "expiresAt")
                        
                        completion(.success(newAccessToken))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    // Function to log in a user
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Check if another request is already in progress
        if isRequestInProgress {
            ongoingRequest?.cancel() // Cancel ongoing request if it exists
        }
        
        isRequestInProgress = true // Set the flag to prevent new requests
        
        let url = "https://dummyjson.com/auth/login"
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
            "expiresInMins": 30
        ]
        
        // API Request with Alamofire
        ongoingRequest = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: User.self) { [weak self] response in
                guard let self = self else { return }
                defer { self.isRequestInProgress = false } // Reset flag when request completes
                
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

