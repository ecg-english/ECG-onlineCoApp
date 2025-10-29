import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let flyerImageUrl: String?
    let date: Date
    let venue: String
    let pricing: EventPricing
    let participants: [EventParticipant]
    let createdBy: EventCreator
    let isParticipating: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, flyerImageUrl, date, venue, pricing, participants, createdBy, isParticipating
    }
}

struct EventPricing: Codable {
    let visitorPrice: Double
    let memberPrice: Double
}

struct EventParticipant: Codable, Identifiable {
    let id: String
    let user: User
    let registeredAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, registeredAt
    }
}

struct EventCreator: Codable, Identifiable {
    let id: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
    }
}

