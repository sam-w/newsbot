//
//  Commands.swift
//  newsbot
//
//  Created by Sam.Warner on 20/12/16.
//
//

import Foundation
import Result

enum Command {
    case list
    case add(text: String, modifiers: [Announcement.Modifier])
}

extension Newsbot {
    
    typealias RouteResult = Result<SlackResponse, String>

    static func list() -> RouteResult {
        return Database.list().map {
            let attachments = $0.map {
                SlackResponse.Attachment(user: $0.user, text: $0.text)
            }
            return SlackResponse(inChannel: false,
                                 attachments: attachments)
        }.mapError {
            $0.debugDescription
        }
    }
    
    static func add(text: String, modifiers: [Announcement.Modifier], user: String, channel: String) -> RouteResult {
        let announcement = Announcement(user: user, channel: channel, text: text, modifiers: modifiers, category: nil)
        return Database.insert(announcement: announcement).map {
            let attachment = SlackResponse.Attachment(user: user, text: text)
            return SlackResponse(inChannel: true,
                                 attachments: [attachment])
        }.mapError {
            $0.debugDescription
        }
    }
}

extension Command {
    
    typealias InterpretResult = Result<Command, String>
    
    static func from(string: String) -> InterpretResult {
        let tokens = string.components(separatedBy: " ").filter { !$0.isEmpty }
        
        if let commandToken = tokens.first, Command.listTokens.contains(commandToken), tokens.dropFirst().isEmpty {
            return .success(.list)
        } else if let commandToken = tokens.first, tokens.dropFirst().isEmpty {
            return .failure("Unrecognized command '\(commandToken)'")
        } else if !tokens.isEmpty {
            let possibleModifiers = Set(Announcement.Modifier.all.flatMap { $0.clientValues })
            let activeModifiers = Set(tokens).intersection(possibleModifiers)
            
            return .success(.add(
                text: tokens.filter { !activeModifiers.contains($0) }.joined(separator: " "),
                modifiers: activeModifiers.flatMap { Announcement.Modifier(clientValue: $0) }
                ))
        } else {
            return .success(.list)
        }
    }
}

extension String: Swift.Error {}

fileprivate extension Command {
    
    static let listTokens = ["list", "all"]
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

