//
//  extensions.swift
//  newsbot
//
//  Created by Sam.Warner on 19/12/16.
//  Copyright © 2016 Domain. All rights reserved.
//

import Foundation
import PerfectHTTP

extension HTTPResponse {
    
    func complete(status: HTTPResponseStatus) {
        self.status = status
        self.completed()
    }
}
