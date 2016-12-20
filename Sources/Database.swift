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
import Result

private let dbname = "newsbot"
private let dbtable = "newsbot.announce"

struct Database {
    
    struct Error: Swift.Error {
        
        let code: UInt32
        let message: String
    }
    
    typealias Instance = MySQL
    
    typealias RetrieveResult = Result<[Announcement], Error>
    typealias RetrieveTask = (Instance) -> RetrieveResult
    
    typealias InsertResult = Result<Void, Error>
    typealias InsertTask = (Instance) -> InsertResult
    
    static func insert(announcement: Announcement) -> InsertResult {
        let statement = announcement.insert
        return self.execute { instance in
            guard instance.selectDatabase(named: dbname), instance.query(statement: statement), !instance.commit() else {
                Log.info(message: "Failure: \(instance.error)")
                return .failure(instance.error)
            }
            
            return .success()
        }
    }
    
    static func list() -> RetrieveResult {
        let statement = Announcement.retrieve
        return self.execute { instance in
            guard instance.selectDatabase(named: dbname) && instance.query(statement: statement) else {
                Log.info(message: "Failure: \(instance.error)")
                return .failure(instance.error)
            }
            
            let results = instance.storeResults()
            
            var rows = [[String?]]()
            while let row = results?.next() {
                rows.append(row)
            }
            
            let result = rows.suffix(5).flatMap { Announcement(databaseRow: $0) }
            return .success(result)
        }
    }
}

// MARK: Connect

fileprivate extension Database {
    
    private static let instance = Instance()
    
    private static let dbhost = "s-newsbot-rds.clhd2uxuvo0f.ap-southeast-2.rds.amazonaws.com"
    private static let dbuser = "dom_dbuser"
    private static let dbpassword = "Ksm8lkpqYWsx"
    
    static func execute(retrieval: RetrieveTask) -> RetrieveResult {
        guard instance.connect(host: dbhost, user: dbuser, password: dbpassword, db: dbname, port: 3306) else {
            Log.info(message: "Failure connecting to data server \(dbhost): \(instance.error)")
            return .failure(instance.error)
        }
        
        defer {
            instance.close()
        }
        
        return retrieval(instance)
    }
    
    static func execute(insertion: InsertTask) -> InsertResult {
        guard instance.connect(host: dbhost, user: dbuser, password: dbpassword, db: dbname, port: 3306) else {
            Log.info(message: "Failure connecting to data server \(dbhost): \(instance.error)")
            return .failure(instance.error)
        }
        
        defer {
            instance.close()
        }
        
        return insertion(instance)
    }
}

// MARK: Insert

fileprivate extension Announcement {
    
    enum Column: String {
        case user = "user"
        case channel = "channel"
        case text = "text"
        case modifiers = "modifiers"
        case category = "category"
    }
}

fileprivate extension Announcement {
    
    typealias Pair = (column: Column, value: String)
    
    var pairs: [Pair] {
        let pairs: [Pair?] = [
            (column: Column.user, value: user),
            (column: Column.channel, value: channel),
            (column: Column.text, value: text),
            modifiers.isEmpty ? nil : (column: Column.modifiers, value: modifiers.map { $0.databaseValue }.joined(separator: ",")),
            category.map { (column: Column.category, value: $0) }
        ]
        return pairs.flatMap { $0 }
    }
    
    var insert: String {
        let pairs = self.pairs
        let columns = pairs.map { $0.column.rawValue }.joined(separator: ",")
        let values = pairs.map { "'\($0.value)'" }.joined(separator: ",")
        return "insert into \(dbtable) (\(columns)) values (\(values));"
    }
}

fileprivate extension Announcement.Modifier {
    
    var databaseValue: String {
        switch self {
        case .important: return "important"
        }
    }
    
    init?(databaseValue: String) {
        let matchedModifiers =  Announcement.Modifier.all.filter { $0.databaseValue == databaseValue }
        guard let modifier = matchedModifiers.first else {
            return nil
        }
        self = modifier
    }
}

// MARK: Retrieve

fileprivate extension Announcement {
    
    static var columns: [Column] {
        return [
            .user,
            .channel,
            .text,
            .modifiers,
            .category
        ]
    }
    
    static var retrieve: String {
        let columns = self.columns.map { $0.rawValue }.joined(separator: ",")
        return "select \(columns) from \(dbtable);"
    }
    
    init?(databaseRow: [String?]) {
        let pairs = zip(Announcement.columns, databaseRow)
        
        guard
            let user = pairs.flatValue(for: .user),
            let channel = pairs.flatValue(for: .channel),
            let text = pairs.flatValue(for: .text)
        else
        {
            return nil
        }
        
        self.user = user
        self.channel = channel
        self.text = text
        
        self.modifiers = pairs.flatValue(for: .modifiers)?
            .components(separatedBy: ",")
            .flatMap { Announcement.Modifier(databaseValue: $0) } ?? []
        
        self.category = pairs.flatValue(for: .category)
    }
}

fileprivate extension Zip2Sequence where Sequence1.Iterator.Element: Equatable {
    
    func value(for key: Sequence1.Iterator.Element) -> Sequence2.Iterator.Element? {
        return self.filter { $0.0 == key }.first?.1
    }
}

fileprivate extension Zip2Sequence where Sequence1.Iterator.Element: Equatable, Sequence2.Iterator.Element == Optional<String> {
    
    func flatValue(for key: Sequence1.Iterator.Element) -> Sequence2.Iterator.Element {
        return self.value(for: key).flatMap { $0 }
    }
}

// MARK: Error

fileprivate extension Database.Instance {
    
    var error: Database.Error {
        return Database.Error(code: self.errorCode(), message: self.errorMessage())
    }
}

extension Database.Error: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "\(code) \(message)"
    }
}
