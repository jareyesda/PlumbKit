//
//  APICLient.swift
//  
//
//  Created by Juan Reyes on 11/2/21.
//

import Foundation
import Combine

struct pkAPIClient {
    
    static let shared = pkAPIClient()
  
    var baseURL: String!
    var networkDispatcher: pkNetworkDispatcher!
    
    init(baseURL: String = "https://dev-lockheed.inspiringapps.com", networkDispatcher: pkNetworkDispatcher = pkNetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }
    
    /// Dispatches a Request and returns a publisher
        /// - Parameter request: Request to Dispatch
        /// - Returns: A publisher containing decoded data or an error
    func dispatch<R: pkRequest>(_ request: R) -> AnyPublisher<R.ReturnType, pkNetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: pkNetworkRequestError.badRequest)
                .eraseToAnyPublisher()
        }
        
        typealias RequestPublisher = AnyPublisher<R.ReturnType, pkNetworkRequestError>
        
        let requestPublisher: RequestPublisher = networkDispatcher.dispatch(request: urlRequest)
        
        return requestPublisher
            .eraseToAnyPublisher()
        
    }
    
}
