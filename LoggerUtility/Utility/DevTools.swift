//
//  DevTools.swift
//  LoggerUtility
//
//  Created by Tahir Anil Oghan on 8.07.2025.
//

import Foundation

public enum DevTools {
    
    #if canImport(OSLog)
    @available(iOS 15.0, macCatalyst 15.0, macOS 10.15, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public static let logger: SystemLogger = AppLogger.shared
    #endif
    
    internal static var isTesting: Bool {
        NSClassFromString("XCTest") != nil
    }
}
