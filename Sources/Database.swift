//
//  Database.swift
//  newsbot
//
//  Created by Sam.Warner on 19/12/16.
//
//

import Foundation
import PerfectLib
import MySQL
import PerfectHTTP

let dbhost = "newbotinstance.cutupejdufse.us-west-2.rds.amazonaws.com:3306"
let dbuser = "newsbotuser"
let dbpassword = "H<xx&S~%uK!\\~X*"
let dbtable = "newsbot.announce"

let database = MySQL()

public func useMysql(_ request: HTTPRequest, response: HTTPResponse) {
    guard database.connect(host: dbhost, user: dbuser, password: dbpassword ) else {
        Log.info(message: "Failure connecting to data server \(testHost)")
        return
    }
    
    defer {
        database.close()  // defer ensures we close our db connection at the end of this request
    }
    
    //set database to be used, this example assumes presence of a users table and run a raw query, return failure message on a error
    guard database.selectDatabase(named: dbtable) && dataMysql.query(statement: "select * from *") else {
        Log.info(message: "Failure: \(database.errorCode()) \(database.errorMessage())")
        
        return
    }
    
    //store complete result set
    let results = database.storeResults()
    
    //setup an array to store results
    var resultArray = [[String?]]()
    
    while let row = results?.next() {
        resultArray.append(row)
        
    }
    
    //return array to http response
    response.appendBody(string: "<html><title>Mysql Test</title><body>\(resultArray.debugDescription)</body></html>")
    response.completed()
    
}
