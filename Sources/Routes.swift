//
//  routes.swift
//  newsbot
//
//  Created by Sam.Warner on 19/12/16.
//
//

import Foundation
import PerfectHTTP

let token = "liuSVUh04E4w1tT4g8FarT3J"

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
                let text = request.param(name: "text"), !text.isEmpty,
                let channel = request.param(name: "channel_name"), !channel.isEmpty,
                let user = request.param(name: "user_name"), !user.isEmpty
                else
            {
                response.complete(status: .badRequest)
                return
            }
            
            response.setHeader(.contentType, value: "text/plain")
            response.appendBody(string: "Reply!")
            response.complete(status: .ok)
        }
        return routes
    }
}
