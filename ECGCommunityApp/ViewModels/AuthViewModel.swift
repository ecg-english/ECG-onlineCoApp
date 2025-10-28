import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let response = try await apiService.getCurrentUser()
                currentUser = response.user
                isAuthenticated = true
            } catch {
                isAuthenticated = false
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signup(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.signup(email: email, password: password, username: username)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        apiService.logout()
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateProfile(username: String?, profile: UserProfile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.updateProfile(username: username, profile: profile)
            currentUser = response.user
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

