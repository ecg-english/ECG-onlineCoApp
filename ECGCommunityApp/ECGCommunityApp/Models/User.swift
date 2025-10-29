import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let roles: [Role]
    let profile: UserProfile?
    let miles: Int
    let registeredAt: Date
    let lastLoginAt: Date
    let pushNotificationSettings: PushNotificationSettings
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, username, roles, profile, miles, registeredAt, lastLoginAt, pushNotificationSettings
    }
    
    var isAdmin: Bool {
        roles.contains { $0.name == "管理者" }
    }
    
    var isMember: Bool {
        roles.contains { $0.name == "メンバー" }
    }
    
    var isVisitor: Bool {
        roles.contains { $0.name == "ビジター" } && roles.count == 1
    }
}

struct UserProfile: Codable {
    var avatarUrl: String?
    var nativeLanguage: String?
    var learningLanguages: [String]?
    var currentCountry: String?
    var statusMessage: String?
    var bio: String?
    var instagram: String?
}

struct PushNotificationSettings: Codable {
    var eventReminders: Bool
    var newPosts: Bool
    var newLearningContent: Bool
}

struct Role: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let permissions: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, permissions
    }
}

