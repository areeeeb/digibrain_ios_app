import SwiftData
import Foundation

@Model
final class AuthState {
    var isAuthenticated: Bool
    var userEmail: String?
    var lastUpdated: Date
    
    init(isAuthenticated: Bool = false, userEmail: String? = nil) {
        self.isAuthenticated = isAuthenticated
        self.userEmail = userEmail
        self.lastUpdated = Date()
    }
} 