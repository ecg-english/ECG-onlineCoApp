import Foundation

class APIService {
    static let shared = APIService()
    
    // TODO: Renderにデプロイ後、実際のURLに変更してください
    private let baseURL = "https://ecg-community-api.onrender.com/api"
    
    private var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    private init() {}
    
    // MARK: - Generic Request
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Auth
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "password": password]
        let response: AuthResponse = try await request(
            endpoint: "/auth/login",
            method: "POST",
            body: body,
            requiresAuth: false
        )
        authToken = response.token
        return response
    }
    
    func signup(email: String, password: String, username: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "password": password, "username": username]
        let response: AuthResponse = try await request(
            endpoint: "/auth/signup",
            method: "POST",
            body: body,
            requiresAuth: false
        )
        authToken = response.token
        return response
    }
    
    func getCurrentUser() async throws -> UserResponse {
        return try await request(endpoint: "/auth/me")
    }
    
    func logout() {
        authToken = nil
    }
    
    // MARK: - Users
    
    func getAllUsers() async throws -> UsersResponse {
        return try await request(endpoint: "/users")
    }
    
    func getMembers() async throws -> UsersResponse {
        return try await request(endpoint: "/users/members")
    }
    
    func getUser(id: String) async throws -> UserResponse {
        return try await request(endpoint: "/users/\(id)")
    }
    
    func updateProfile(username: String?, profile: UserProfile) async throws -> UserResponse {
        var body: [String: Any] = [:]
        if let username = username {
            body["username"] = username
        }
        body["profile"] = try JSONEncoder().encode(profile)
        return try await request(endpoint: "/users/profile", method: "PUT", body: body)
    }
    
    // MARK: - Channels
    
    func getChannels() async throws -> ChannelsResponse {
        return try await request(endpoint: "/channels")
    }
    
    func getAllChannels() async throws -> ChannelsResponse {
        return try await request(endpoint: "/channels/all")
    }
    
    func createChannel(name: String, description: String, categoryId: String, viewPermissions: [String], postPermissions: [String]) async throws -> ChannelResponse {
        let body: [String: Any] = [
            "name": name,
            "description": description,
            "category": categoryId,
            "viewPermissions": viewPermissions,
            "postPermissions": postPermissions
        ]
        return try await request(endpoint: "/channels", method: "POST", body: body)
    }
    
    // MARK: - Posts
    
    func getPosts(channelId: String) async throws -> PostsResponse {
        return try await request(endpoint: "/posts/channel/\(channelId)")
    }
    
    func createPost(channelId: String, content: String, images: [String] = []) async throws -> PostResponse {
        let body: [String: Any] = [
            "channel": channelId,
            "content": content,
            "images": images
        ]
        return try await request(endpoint: "/posts", method: "POST", body: body)
    }
    
    func likePost(postId: String) async throws -> PostResponse {
        return try await request(endpoint: "/posts/\(postId)/like", method: "POST")
    }
    
    func addComment(postId: String, content: String) async throws -> PostResponse {
        let body: [String: Any] = ["content": content]
        return try await request(endpoint: "/posts/\(postId)/comment", method: "POST", body: body)
    }
    
    // MARK: - Events
    
    func getEvents(startDate: Date? = nil, endDate: Date? = nil) async throws -> EventsResponse {
        var endpoint = "/events"
        if let startDate = startDate, let endDate = endDate {
            let formatter = ISO8601DateFormatter()
            endpoint += "?startDate=\(formatter.string(from: startDate))&endDate=\(formatter.string(from: endDate))"
        }
        return try await request(endpoint: endpoint)
    }
    
    func getEvent(id: String) async throws -> EventResponse {
        return try await request(endpoint: "/events/\(id)")
    }
    
    func participateEvent(eventId: String) async throws -> EventResponse {
        return try await request(endpoint: "/events/\(eventId)/participate", method: "POST")
    }
    
    // MARK: - Learning
    
    func getLearningArticles(category: String? = nil) async throws -> LearningArticlesResponse {
        var endpoint = "/learning"
        if let category = category {
            endpoint += "?category=\(category)"
        }
        return try await request(endpoint: endpoint)
    }
    
    func completeArticle(articleId: String, rating: Int) async throws -> CompleteArticleResponse {
        let body: [String: Any] = ["comprehensionRating": rating]
        return try await request(endpoint: "/learning/\(articleId)/complete", method: "POST", body: body)
    }
    
    // MARK: - Miles
    
    func getMileBalance() async throws -> MileBalanceResponse {
        return try await request(endpoint: "/miles/balance")
    }
    
    func getMileTransactions() async throws -> MileTransactionsResponse {
        return try await request(endpoint: "/miles/transactions")
    }
    
    // MARK: - Shop
    
    func getShopItems() async throws -> ShopItemsResponse {
        return try await request(endpoint: "/shop")
    }
    
    func purchaseItem(itemId: String) async throws -> PurchaseItemResponse {
        return try await request(endpoint: "/shop/\(itemId)/purchase", method: "POST")
    }
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let message: String
    let token: String
    let user: User
}

struct UserResponse: Codable {
    let user: User
}

struct UsersResponse: Codable {
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case users = "members"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let members = try? container.decode([User].self, forKey: .users) {
            self.users = members
        } else {
            let directContainer = try decoder.singleValueContainer()
            let response = try directContainer.decode([String: [User]].self)
            self.users = response["users"] ?? response["members"] ?? []
        }
    }
}

struct ChannelsResponse: Codable {
    let channels: [Channel]
}

struct ChannelResponse: Codable {
    let message: String
    let channel: Channel
}

struct PostsResponse: Codable {
    let posts: [Post]
}

struct PostResponse: Codable {
    let message: String
    let post: Post
}

struct EventsResponse: Codable {
    let events: [Event]
}

struct EventResponse: Codable {
    let event: Event
}

struct LearningArticlesResponse: Codable {
    let articles: [LearningArticle]
}

struct CompleteArticleResponse: Codable {
    let message: String
    let milesEarned: Int
}

struct MileBalanceResponse: Codable {
    let miles: Int
}

struct MileTransactionsResponse: Codable {
    let transactions: [MileTransaction]
}

struct ShopItemsResponse: Codable {
    let items: [ShopItem]
}

struct PurchaseItemResponse: Codable {
    let message: String
    let item: ShopItem
    let remainingMiles: Int
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .serverError(let code):
            return "サーバーエラー: \(code)"
        }
    }
}

