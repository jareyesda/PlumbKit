//
//  Request.swift
//  
//
//  Created by Juan Reyes on 11/2/21.
//

import Foundation

public enum HTTPMethod: String {
    case GET     = "GET"
    case POST    = "POST"
    case PUT     = "PUT"
    case DELETE  = "DELETE"
}

public protocol PlumbRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }
    var body: [String: Any]? { get }
    var headers: [String: String]? { get }
    var queryItems: [String: String]? { get }
    associatedtype ReturnType: Codable
}
 
extension PlumbRequest {
    // Defaults
    var method: HTTPMethod { return .GET }
    var contentType: String { return "application/json" }
    var queryParams: [String: String]? { return nil }
    var body: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
    var queryItems: [String: String]? { return nil }
}

extension PlumbRequest {
    
    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else {
            return nil
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        
        return httpBody
    }
    
    private func queryParameters(_ params: [String: String]?) -> [URLQueryItem]? {
        var queryParams = [URLQueryItem]()
        
        guard let params = params else {
            return nil
        }
        
        for (key, value) in params {
            queryParams.append(URLQueryItem(name: key, value: value))
        }
        
        return queryParams
    }
    
    func asURLRequest(baseURL: String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        
        urlComponents.path = "\(urlComponents.path)\(path)"
        urlComponents.queryItems = queryParameters(queryItems)
        
        guard let finalURL = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
        
    }
    
    
}
