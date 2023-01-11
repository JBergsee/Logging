//
//  File.swift
//  
//
//  Created by Johan Nyman on 2023-01-11.
//

import Foundation

/**
 Extend in dependent projects to add categories.
 
 Example usage:
```
public extension LogCategory {
    //Logs airline specific Journey Log
    static let journeyLog = LogCategory(rawValue: "Journey Log")!
}
```
*/
public struct LogCategory: RawRepresentable {
    public var rawValue: String
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let model = LogCategory(rawValue: "Model")!
    public static let appState = LogCategory(rawValue: "Application State")!
    public static let functionality = LogCategory(rawValue: "Functionality")!
    public static let network = LogCategory(rawValue: "Network")!
    public static let coredata = LogCategory(rawValue: "Core Data")!
    public static let view = LogCategory(rawValue: "View")!
    
    static let unknown = LogCategory(rawValue: "Unknown, change this!")!
}

public struct LogErrorCode: RawRepresentable {
    public var rawValue: Int
    public init?(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let defaultError = LogErrorCode(rawValue: 1)!
    public static let unexpectedCodePath = LogErrorCode(rawValue: 1025)!
}
