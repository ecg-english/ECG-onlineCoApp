import Foundation
import SwiftUI
import Combine

@MainActor
class ShopViewModel: ObservableObject {
    @Published var items: [ShopItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let apiService = APIService.shared
    
    func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getShopItems()
            items = response.items
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func purchaseItem(itemId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let response = try await apiService.purchaseItem(itemId: itemId)
            successMessage = response.message
            await loadItems()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

