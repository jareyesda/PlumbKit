//
//  APICLient.swift
//  
//
//  Created by Juan Reyes on 11/2/21.
//

import Foundation
import Combine

struct PlumbAPIClient {
    
    var baseURL: String!
    var networkDispatcher: pkNetworkDispatcher!
    
    init(baseURL: String, networkDispatcher: pkNetworkDispatcher = pkNetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }
    
    /// Dispatches a Request and returns a publisher
        /// - Parameter request: Request to Dispatch
        /// - Returns: A publisher containing decoded data or an error
    func dispatch<R: PlumbRequest>(_ request: R) -> AnyPublisher<R.ReturnType, PlumbNetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: PlumbNetworkRequestError.badRequest)
                .eraseToAnyPublisher()
        }
        
        typealias RequestPublisher = AnyPublisher<R.ReturnType, PlumbNetworkRequestError>
        
        let requestPublisher: RequestPublisher = networkDispatcher.dispatch(request: urlRequest)
        
        return requestPublisher
            .eraseToAnyPublisher()
        
    }
    
}
