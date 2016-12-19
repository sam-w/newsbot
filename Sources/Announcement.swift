//
//  Announcement.swift
//  newsbot
//
//  Created by Sam.Warner on 19/12/16.
//
//

import Foundation

struct Announcement {
    
    enum Modifier {
        case important
        
        static var all: [Announcement.Modifier] { return [.important] }
    }
    
    let user: String
    let channel: String
    let text: String
    let modifiers: [Modifier]
    let category: String?
}
