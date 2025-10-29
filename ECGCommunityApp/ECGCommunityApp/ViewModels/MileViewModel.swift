import Foundation
import SwiftUI
import Combine

@MainActor
class MileViewModel: ObservableObject {
    @Published var balance: Int = 0
    @Published var transactions: [MileTransaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadBalance() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getMileBalance()
            balance = response.miles
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getMileTransactions()
            transactions = response.transactions
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

