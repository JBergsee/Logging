//
//  File.swift
//  
//
//  Created by Johan Nyman on 2023-01-11.
//

import Foundation

/// This protocol provides a way of using Firebase for logging,
/// without importing it in every single file that uses logging.
@objc public protocol FirebaseWrapping {
    func crashlyticsLog(_ message:String)
    func crashlyticsError(_ error:Error)
    func analyticsLog(_ event:String, parameters: [String:Any]?)
}
