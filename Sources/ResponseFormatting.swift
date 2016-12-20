//
//  ResponseFormatting.swift
//  newsbot
//
//  Created by Sam.Warner on 20/12/16.
//
//

import Foundation

struct SlackResponse {
    
    struct Attachment {
        let user: String
        let text: String
    }
    
    let inChannel: Bool
    let attachments: [Attachment]
}

extension SlackResponse.Attachment {
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "author_name": user,
            "text": text,
        ]
    }
}

extension SlackResponse {
    
    var defaultAttachment: [String: Any] {
        return [
            "title": "Good news, everyone!",
            "image_url": "http://67.media.tumblr.com/avatar_3aced8d4976a_128.png"
        ]
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "response_type": inChannel ? "in_channel" : "",
            "attachments": [defaultAttachment] + attachments.map { $0.dictionaryRepresentation }
        ]
    }
}
