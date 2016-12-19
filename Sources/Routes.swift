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
        
        routes.add(method: .get, uri: "/test") { request, response in
            response.appendBody(string: "Success")
            response.complete(status: .ok)
        }
        
        routes.add(method: .post, uri: "/announce-add") { request, response in
            guard let clientToken = request.param(name: "token"), clientToken == token else {
                response.complete(status: .forbidden)
                return
            }
            
            guard
                let user = request.param(name: "user_name"), !user.isEmpty,
                let channel = request.param(name: "channel_name"), !channel.isEmpty,
                let text = request.param(name: "text"), !text.isEmpty
                else
            {
                response.complete(status: .badRequest)
                return
            }
            
            let announcement = Announcement(user: user, channel: channel, clientText: text)
            Database
                .insert(announcement: announcement)
                .analysis(ifSuccess: {
                    response.complete(status: .ok)
                }, ifFailure: { error in
                    response.appendBody(string: error.debugDescription)
                    response.complete(status: .internalServerError)
                })
        }
        
        routes.add(method: .post, uri: "/announce-list") { request, response in
            guard let clientToken = request.param(name: "token"), clientToken == token else {
                response.complete(status: .forbidden)
                return
            }
            
            guard
                let channel = request.param(name: "channel_name"), !channel.isEmpty,
                let user = request.param(name: "user_name"), !user.isEmpty
                else
            {
                response.complete(status: .badRequest)
                return
            }
            
            response.setHeader(.contentType, value: "text/plain")
            
            let results = Database.list()
            response.appendBody(string: results.debugDescription)
            response.complete(status: .ok)
        }
        
        return routes
    }
}

fileprivate extension Announcement.Modifier {
    
    var clientValues: [String] {
        switch self {
        case .important: return [":exclamation:", ":warning:", "⚠️"]
        }
    }
    
    init?(clientValue: String) {
        let matchedModifiers = Announcement.Modifier.all.filter { $0.clientValues.contains(clientValue) }
        guard let modifier = matchedModifiers.first else {
            return nil
        }
        self = modifier
    }
}

fileprivate extension String {
    
    func extracted() -> (text: String, modifiers: [Announcement.Modifier]) {
        let tokens = self.components(separatedBy: " ")
        let possibleModifiers = Set(Announcement.Modifier.all.flatMap { $0.clientValues })
        let activeModifiers = Set(tokens).intersection(possibleModifiers)

        return (text: tokens.filter { !activeModifiers.contains($0) }.joined(separator: " "),
                modifiers: activeModifiers.flatMap { Announcement.Modifier(clientValue: $0) })
    }
}

fileprivate extension Announcement {
    
    init(user: String, channel: String, clientText: String) {
        let (text, modifiers) = clientText.extracted()
        
        self.user = user
        self.channel = channel
        self.text = text
        self.modifiers = modifiers
        self.category = nil
    }
}
