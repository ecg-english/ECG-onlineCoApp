import Foundation

struct ShopItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String?
    let mileCost: Int
    let type: String
    let discountValue: Double?
    let stock: Int
    let active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, imageUrl, mileCost, type, discountValue, stock, active
    }
}

struct MileTransaction: Codable, Identifiable {
    let id: String
    let user: String
    let amount: Int
    let type: String
    let description: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, amount, type, description, createdAt
    }
}

