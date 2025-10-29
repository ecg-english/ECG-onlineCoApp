import Foundation

struct LearningArticle: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let coverImageUrl: String?
    let category: String
    let contentUrl: String
    let milesReward: Int
    let createdBy: EventCreator
    let isCompleted: Bool?
    let userRating: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, subtitle, coverImageUrl, category, contentUrl, milesReward, createdBy, isCompleted, userRating
    }
}

enum LearningCategory: String, CaseIterable {
    case all = "すべて"
    case english = "英語学習"
    case communication = "コミュニケーション"
    case culture = "異文化理解"
    case otherLanguages = "他言語"
    case motivation = "モチベーション"
}

