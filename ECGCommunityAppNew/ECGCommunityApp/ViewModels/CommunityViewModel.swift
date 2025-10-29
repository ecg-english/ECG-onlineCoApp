import Foundation
import SwiftUI
import Combine

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var channels: [Channel] = []
    @Published var posts: [Post] = []
    @Published var selectedChannel: Channel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadChannels() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getChannels()
            channels = response.channels
            
            // カテゴリをユニークに抽出
            let uniqueCategories = Dictionary(grouping: channels, by: { $0.category.id })
                .compactMap { $0.value.first?.category }
                .sorted { $0.order < $1.order }
            categories = uniqueCategories
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadPosts(for channelId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getPosts(channelId: channelId)
            posts = response.posts
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createPost(channelId: String, content: String, images: [String] = []) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.createPost(channelId: channelId, content: content, images: images)
            await loadPosts(for: channelId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func likePost(_ postId: String, channelId: String) async {
        do {
            _ = try await apiService.likePost(postId: postId)
            await loadPosts(for: channelId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addComment(postId: String, content: String, channelId: String) async {
        do {
            _ = try await apiService.addComment(postId: postId, content: content)
            await loadPosts(for: channelId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func channelsForCategory(_ categoryId: String) -> [Channel] {
        channels.filter { $0.category.id == categoryId }
            .sorted { $0.order < $1.order }
    }
}

