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
        routes.add(method: .get, uri: "/announce") { request, response in
            guard let clientToken = request.param(name: "token"), clientToken == token else {
                response.complete(status: .forbidden)
                return
            }
            response.setHeader(.contentType, value: "text/html")
            response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
            response.complete(status: .ok)
        }
        return routes
    }
}
