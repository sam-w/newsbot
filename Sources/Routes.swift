//
//  routes.swift
//  newsbot
//
//  Created by Sam.Warner on 19/12/16.
//
//

import Foundation
import PerfectHTTP

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
                let list = Newsbot.list()
                response.appendBody(string: list)
                response.complete(status: .ok)
            case let .success(.add(text, modifiers)):
                Newsbot.add(text: text, modifiers: modifiers, user: user, channel: channel)
                response.complete(status: .ok)
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
