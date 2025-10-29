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


