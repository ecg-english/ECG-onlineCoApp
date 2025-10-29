import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let channel: String
    let author: User
    let content: String
    let images: [String]
    let likes: [User]
    let comments: [Comment]
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case channel, author, content, images, likes, comments, createdAt, updatedAt
    }
}

struct Comment: Codable, Identifiable {
    let id: String
    let user: User
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, content, createdAt
    }
}
