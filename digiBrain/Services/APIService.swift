import Foundation

struct Memory: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let date: Date
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case content
        case date
        case userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        userId = try container.decode(String.self, forKey: .userId)
    }
}

struct Question {
    let query: String
    let userId: String
}

struct QueryResponse: Codable {
    let answer: String
    let relevantMemories: [Memory]
}

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "http://10.0.0.67:3000/api"
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)"
            )
        }
        
        return decoder
    }()
    
    func addMemory(title: String, content: String, userId: String) async throws -> Memory {
        guard let url = URL(string: "\(baseURL)/memories") else {
            throw APIError.invalidRequest
        }
        
        let body = [
            "title": title,
            "content": content,
            "userId": userId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let json = String(data: data, encoding: .utf8) {
            print("Received JSON:", json)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        switch httpResponse.statusCode {
        case 201:
            do {
                let memory = try jsonDecoder.decode(Memory.self, from: data)
                return memory
            } catch {
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key), context: \(context)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: \(type), context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type), context: \(context)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                throw error
            }
        case 400:
            throw APIError.invalidRequest
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.networkError
        }
    }
    
    func listMemories(userId: String) async throws -> [Memory] {
        guard let url = URL(string: "\(baseURL)/memories/\(userId)") else {
            throw APIError.invalidRequest
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try jsonDecoder.decode([Memory].self, from: data)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            throw APIError.networkError
        }
    }
    
    func askQuestion(_ question: Question) async throws -> QueryResponse {
        guard let url = URL(string: "\(baseURL)/query") else {
            throw APIError.invalidRequest
        }
        
        let body = [
            "query": question.query,
            "userId": question.userId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try jsonDecoder.decode(QueryResponse.self, from: data)
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.networkError
        }
    }
    
    enum APIError: Error {
        case invalidRequest
        case networkError
        case unauthorized
        case notFound
        
        var description: String {
            switch self {
            case .invalidRequest:
                return "Invalid request parameters"
            case .networkError:
                return "Network error occurred"
            case .unauthorized:
                return "Unauthorized access"
            case .notFound:
                return "Resource not found"
            }
        }
    }
} 