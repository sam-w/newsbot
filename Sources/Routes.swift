//
//  routes.swift
//  newsbot
//
//  Created by Sam.Warner on 19/12/16.
//
//

import Foundation
import PerfectHTTP
import Result

private let token = "liuSVUh04E4w1tT4g8FarT3J"

// Register your own routes and handlers
extension Newsbot {
    
    static var routes: Routes {
        var routes = Routes()
        
        routes.add(method: .post, uri: "/announce") { request, response in
            guard let clientToken = request.param(name: "token"), clientToken == token else {
                response.complete(status: .forbidden)
                return
            }
            
            guard
                let user = request.param(name: "user_name"), !user.isEmpty,
                let channel = request.param(name: "channel_name"), !channel.isEmpty
                else
            {
                response.complete(status: .badRequest)
                return
            }
            
            let interpretResult = request.param(name: "text").map { Command.from(string: $0) } ?? .success(.list)
            switch interpretResult {
            case .success(.list):
                response.complete(result: Newsbot.list())
            case let .success(.add(text, modifiers)):
                response.complete(result: Newsbot.add(text: text, modifiers: modifiers, user: user, channel: channel))
            case let .failure(error):
                response.appendBody(string: error)
                response.complete(status: .badRequest)
            }
        }
        
        // MARK: Test routes
        
        routes.add(method: .get, uri: "/test") { request, response in
            response.appendBody(string: "Success")
            response.complete(status: .ok)
        }
        
        return routes
    }
}

fileprivate extension HTTPResponse {
    
    func complete(result: Newsbot.RouteResult) {
        result.analysis(ifSuccess: {
            self.setHeader(.contentType, value: "application/json")
            try! self.setBody(json: $0.dictionaryRepresentation)
            self.complete(status: .ok)
        }, ifFailure: {
            self.appendBody(string: $0)
            self.complete(status: .internalServerError)
        })
    }
}
