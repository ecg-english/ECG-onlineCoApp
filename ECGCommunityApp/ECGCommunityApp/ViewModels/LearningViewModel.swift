import Foundation
import SwiftUI
import Combine

@MainActor
class LearningViewModel: ObservableObject {
    @Published var articles: [LearningArticle] = []
    @Published var selectedCategory: LearningCategory = .all
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadArticles(category: LearningCategory? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let categoryString = category == .all ? nil : category?.rawValue
            let response = try await apiService.getLearningArticles(category: categoryString)
            articles = response.articles
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func completeArticle(articleId: String, rating: Int) async -> Int? {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.completeArticle(articleId: articleId, rating: rating)
            await loadArticles(category: selectedCategory)
            isLoading = false
            return response.milesEarned
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }
}

