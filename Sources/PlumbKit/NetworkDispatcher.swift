//
//  NetworkDispatcher.swift
//  
//
//  Created by Juan Reyes on 11/2/21.
//

import Foundation
import Combine

enum PlumbNetworkRequestError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
}

struct pkNetworkDispatcher {
    let urlSession: URLSession!
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    /// Dispatches an URLRequest and returns a publisher
    /// - Parameter request: URLRequest
    /// - Returns: A publisher with the provided decoded data or an error
    func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, PlumbNetworkRequestError> {
        
        // Date formatting
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return urlSession
            .dataTaskPublisher(for: request)
            // Map on Request response
            .tryMap({ data, response in
                // If the response is invalid, throw an error
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                // Return Response data
                return data
            })
            // Decode data using our ReturnType
            .decode(type: ReturnType.self, decoder: decoder)
            // Handle any decoding errors
            .mapError { error in
                handleError(error)
            }
            // And finally, expose our publisher
            .eraseToAnyPublisher()
    }
}

extension pkNetworkDispatcher {
/// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private func httpError(_ statusCode: Int) -> PlumbNetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    private func handleError(_ error: Error) -> PlumbNetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as PlumbNetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}
