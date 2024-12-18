import FirebaseAuth
import Combine
import SwiftData

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var user: User?
    
    // Password validation properties
    var hasMinLength: Bool {
        password.count >= 8
    }
    
    var hasUppercase: Bool {
        password.contains(where: { $0.isUppercase })
    }
    
    var hasLowercase: Bool {
        password.contains(where: { $0.isLowercase })
    }
    
    var hasNumber: Bool {
        password.contains(where: { $0.isNumber })
    }
    
    var hasSpecialCharacter: Bool {
        let specialCharacters = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        return password.contains(where: { specialCharacters.contains($0) })
    }
    
    var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }
    
    var isValidPassword: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber && 
        hasSpecialCharacter && passwordsMatch
    }
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Check stored auth state
        var descriptor = FetchDescriptor<AuthState>(sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)])
        descriptor.fetchLimit = 1
        
        if let storedAuth = try? modelContext.fetch(descriptor).first,
           storedAuth.isAuthenticated {
            // Attempt to restore Firebase session
            self.email = storedAuth.userEmail ?? ""
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.updateStoredAuthState(user: user)
        }
    }
    
    private func updateStoredAuthState(user: User?) {
        // Clear existing auth states
        let descriptor = FetchDescriptor<AuthState>()
        if let existingStates = try? modelContext.fetch(descriptor) {
            existingStates.forEach { modelContext.delete($0) }
        }
        
        // Store new auth state
        let newState = AuthState(
            isAuthenticated: user != nil,
            userEmail: user?.email
        )
        modelContext.insert(newState)
        
        // Save changes
        try? modelContext.save()
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.user = result?.user
                self?.clearFields()
            }
        }
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.user = result?.user
                self?.clearFields()
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            clearFields()
            updateStoredAuthState(user: nil)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
} 