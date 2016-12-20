//
//  ResponseFormatting.swift
//  newsbot
//
//  Created by Sam.Warner on 20/12/16.
//
//

import Foundation

struct SlackResponse {
    let inChannel: Bool
    let text: String
    let attachedText: String
}

extension SlackResponse {
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "response_type": inChannel ? "in_channel" : "",
            "attachments": [
                "fallback": "foo",
                "text": attachedText
            ]
        ]
    }
}
