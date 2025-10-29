import Foundation

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, order
    }
}

struct Channel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let category: Category
    let viewPermissions: [Role]
    let postPermissions: [Role]
    let order: Int
    let canPost: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, category, viewPermissions, postPermissions, order, canPost
    }
}

struct Post: Codable, Identifiable {
    let id: String
    let channel: String
    let author: PostAuthor
    let content: String
    let images: [String]
    let likes: [PostAuthor]
    let comments: [Comment]
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case channel, author, content, images, likes, comments, createdAt
    }
}

struct PostAuthor: Codable, Identifiable {
    let id: String
    let username: String
    let profile: UserProfile?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, profile
    }
}

struct Comment: Codable, Identifiable {
    let id: String
    let user: PostAuthor
    let content: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, content, createdAt
    }
}

