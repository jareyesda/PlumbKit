//
//  APICLient.swift
//  
//
//  Created by Juan Reyes on 11/2/21.
//

import Foundation
import Combine

struct APIClient {
    
    static let shared = APIClient()
  
    var baseURL: String!
    var networkDispatcher: NetworkDispatcher!
    
    init(baseURL: String = "https://dev-lockheed.inspiringapps.com", networkDispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }
    
    /// Dispatches a Request and returns a publisher
        /// - Parameter request: Request to Dispatch
        /// - Returns: A publisher containing decoded data or an error
    func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: NetworkRequestError.badRequest)
                .eraseToAnyPublisher()
        }
        
        typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        
        let requestPublisher: RequestPublisher = networkDispatcher.dispatch(request: urlRequest)
        
        return requestPublisher
            .eraseToAnyPublisher()
        
    }
    
}
