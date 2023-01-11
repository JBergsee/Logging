//
//  File.swift
//  
//
//  Created by Johan Nyman on 2023-01-11.
//

import Foundation

public extension Data {
  var prettySize: String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .binary
    return formatter.string(fromByteCount: Int64(count))
  }
}
