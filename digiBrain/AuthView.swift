import SwiftUI
import SwiftData

struct AuthView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: AuthViewModel
    @State private var isAuthenticated = false
    @State private var isSignUp = false  // Toggle between sign in and sign up
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient adjusted for dark mode
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? .blue.opacity(0.2) : .blue.opacity(0.3),
                        colorScheme == .dark ? .purple.opacity(0.2) : .purple.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Logo or App Title
                    Text("DigiBrain")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 20)
                    
                    // Toggle between Sign In and Sign Up
                    Picker("Mode", selection: $isSignUp) {
                        Text("Sign In").tag(false)
                        Text("Sign Up").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Input fields group
                    VStack(spacing: 15) {
                        // Email field
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                            TextField("Email", text: $viewModel.email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(.systemGray6) : .white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1), radius: 5)
                        
                        // Password field with requirements
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                            SecureField("Password", text: $viewModel.password)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color(.systemGray6) : .white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1), radius: 5)
                        
                        if isSignUp {
                            // Confirm Password field
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray6) : .white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1), radius: 5)
                            
                            // Password requirements
                            VStack(alignment: .leading, spacing: 5) {
                                PasswordRequirementRow(isValid: viewModel.hasMinLength, text: "At least 8 characters")
                                PasswordRequirementRow(isValid: viewModel.hasUppercase, text: "Contains uppercase letter")
                                PasswordRequirementRow(isValid: viewModel.hasLowercase, text: "Contains lowercase letter")
                                PasswordRequirementRow(isValid: viewModel.hasNumber, text: "Contains number")
                                PasswordRequirementRow(isValid: viewModel.hasSpecialCharacter, text: "Contains special character")
                                if !viewModel.confirmPassword.isEmpty {
                                    PasswordRequirementRow(isValid: viewModel.passwordsMatch, text: "Passwords match")
                                }
                            }
                            .font(.caption)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Action Button
                    Button(action: { 
                        viewModel.errorMessage = nil
                        if isSignUp {
                            viewModel.signUp()
                        } else {
                            viewModel.signIn()
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(isSignUp && !viewModel.isValidPassword)
                    .padding(.horizontal)
                    
                    NavigationLink(destination: HomeView(modelContext: modelContext)
                        .navigationBarBackButtonHidden(true),
                                 isActive: $isAuthenticated) {
                        EmptyView()
                    }
                }
                .padding(.vertical, 30)
            }
            .onReceive(viewModel.$user) { user in
                isAuthenticated = user != nil
            }
        }
    }
}

struct PasswordRequirementRow: View {
    let isValid: Bool
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .gray)
            Text(text)
                .foregroundColor(isValid ? .primary : .gray)
        }
    }
} 