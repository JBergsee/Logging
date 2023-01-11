//
//  File.swift
//  
//
//  Created by Johan Nyman on 2023-01-11.
//

import Foundation
import OSLog


//MARK: - Retrieving logs


extension Log {
    
    class func getLogEntries(since:TimeInterval) throws -> [OSLogEntryLog] {
        Log.debug(message: "Retrieving logs from last \(since/3600) hours...", in: .functionality)
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
        let startTime = logStore.position(date: Date().addingTimeInterval(-since))
        let allEntries = try logStore.getEntries(at: startTime)
        
        return allEntries
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == Log.subsystem }
    }
    
    struct SendableLog: Codable {
        let level: Int
        let date, subsystem, category, composedMessage: String
    }
    
    public class func logData(since:TimeInterval) -> Data? {
        let logs = try! Log.getLogEntries(since: since)
        let sendLogs: [SendableLog] = logs.map({ SendableLog(level: $0.level.rawValue,
                                                             date: "\($0.date)",
                                                             subsystem: $0.subsystem,
                                                             category: $0.category,
                                                             composedMessage: $0.composedMessage) })
        
        // Convert object to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try? encoder.encode(sendLogs)
        return jsonData
    }
    
    public class func logString(since:TimeInterval) -> String {
        let logs = try! Log.getLogEntries(since: since)
        let sendLogs: [SendableLog] = logs.map({ SendableLog(level: $0.level.rawValue,
                                                             date: "\($0.date)",
                                                             subsystem: $0.subsystem,
                                                             category: $0.category,
                                                             composedMessage: $0.composedMessage) })
        var logBook = ""
        for log in sendLogs {
            logBook.append(contentsOf: String("\(log.date) [\(log.category)] (level \(log.level)): \(log.composedMessage)\n"))
        }
        return logBook
    }
    
    func sendLogs(since:TimeInterval) {
        let logs = try! Log.getLogEntries(since: since)
        let sendLogs: [SendableLog] = logs.map({ SendableLog(level: $0.level.rawValue,
                                                             date: "\($0.date)",
                                                             subsystem: $0.subsystem,
                                                             category: $0.category,
                                                             composedMessage: $0.composedMessage) })
        
        // Convert object to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try? encoder.encode(sendLogs)
        
        //@TODO: Upload to firebase
        // Send to my API
        let url = URL(string: "http://x.x.x.x:8000")! // IP address and port of Python server
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        }
        task.resume()
    }
}
