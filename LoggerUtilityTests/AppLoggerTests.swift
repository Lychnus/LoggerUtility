//
//  AppLoggerTests.swift
//  LoggerUtility
//
//  Created by Tahir Anil Oghan on 8.07.2025.
//

#if canImport(OSLog)
import Foundation
import Testing
import OSLog
@testable import LoggerUtility

// MARK: - Test Suite for LogBundle
@Suite("AppLogger-LogBundle Tests")
struct LogBundleTests {
    
    @Test("Main bundle returns correct identifier")
    func testMainBundleIdentifier() {
        let bundle = LogBundle.mainBundle
        let description = bundle.textualDescription
        
        // Should return bundle identifier or fallback
        #expect(description == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
    }
    
    @Test("Custom bundle returns provided identifier")
    func testCustomBundleIdentifier() {
        let customIdentifier = "com.example.test"
        let bundle = LogBundle.someBundle(customIdentifier)
        let description = bundle.textualDescription
        
        #expect(description == customIdentifier)
    }
}

// MARK: - Test Suite for LogCategory
@Suite("AppLogger-LogCategory Tests")
struct LogCategoryTests {
    
    @Test("File category generates correct description")
    func testFileCategoryDescription() {
        let testFile = "/path/to/TestFile.swift"
        let testFunction = "testFunction()"
        let category = LogCategory.fileCategory(file: testFile, function: testFunction)
        let description = category.textualDescription
        
        let expectedDescription = "File: TestFile.swift, Function: testFunction()"
        #expect(description == expectedDescription)
    }
    
    @Test("Some category returns provided string")
    func testSomeCategoryDescription() {
        let categoryName = "NetworkManager"
        let category = LogCategory.someCategory(categoryName)
        let description = category.textualDescription
        
        #expect(description == categoryName)
    }
    
    @Test("File category with default parameters")
    func testFileCategoryWithDefaults() {
        let category = LogCategory.fileCategory()
        let description = category.textualDescription
        
        // Should contain "File:" and "Function:" in the description
        #expect(description.contains("File:"))
        #expect(description.contains("Function:"))
    }
}

// MARK: - Test Suite for LogTimeRange
@Suite("AppLogger-LogTimeRange Tests")
struct LogTimeRangeTests {
    
    @Test("Last minutes calculates correct start date")
    func testLastMinutesRange() {
        let minutes = 30
        let range = LogTimeRange.lastMinutes(minutes)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-60 * minutes))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0) // Within 1 second
    }
    
    @Test("Last hours calculates correct start date")
    func testLastHoursRange() {
        let hours = 2
        let range = LogTimeRange.lastHours(hours)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-3600 * hours))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0)
    }
    
    @Test("Last days calculates correct start date")
    func testLastDaysRange() {
        let days = 7
        let range = LogTimeRange.lastDays(days)
        let startDate = range.startDate
        let expectedDate = Date().addingTimeInterval(TimeInterval(-86400 * days))
        
        // Allow for small timing differences in test execution
        let timeDifference = abs(startDate.timeIntervalSince(expectedDate))
        #expect(timeDifference < 1.0)
    }
    
    @Test("Since date returns provided date")
    func testSinceDateRange() {
        let testDate = Date(timeIntervalSince1970: 1000000)
        let range = LogTimeRange.since(testDate)
        let startDate = range.startDate
        
        #expect(startDate == testDate)
    }
    
    @Test("All available returns distant past")
    func testAllAvailableRange() {
        let range = LogTimeRange.allAvailable
        let startDate = range.startDate
        
        #expect(startDate == .distantPast)
    }
}

// MARK: - Test Suite for LogContext
@Suite("AppLogger-LogContext Tests")
struct LogContextTests {
    
    @Test("Default context creates with main bundle and file category")
    func testDefaultContext() {
        let context = LogContext.default()
        
        #expect(context.bundleTextualDescription == Bundle.main.bundleIdentifier ?? "Unknown Bundle Identifier")
        #expect(context.categoryTextualDescription.contains("File:"))
        #expect(context.categoryTextualDescription.contains("Function:"))
    }
    
    @Test("Custom context with specific bundle and category")
    func testCustomContext() {
        let customBundle = LogBundle.someBundle("com.test.app")
        let customCategory = LogCategory.someCategory("TestCategory")
        let context = LogContext(bundle: customBundle, category: customCategory)
        
        #expect(context.bundleTextualDescription == "com.test.app")
        #expect(context.categoryTextualDescription == "TestCategory")
    }
    
    @Test("Default context with custom parameters")
    func testDefaultContextWithCustomParameters() {
        let customBundle = LogBundle.someBundle("com.custom.bundle")
        let context = LogContext.default(bundle: customBundle, file: "CustomFile.swift", function: "customFunction")
        
        #expect(context.bundleTextualDescription == "com.custom.bundle")
        #expect(context.categoryTextualDescription == "File: CustomFile.swift, Function: customFunction")
    }
}

// MARK: - Test Suite for AppLogger
@Suite("AppLogger Tests")
struct AppLoggerTests {
    
    @Test("Log call will not work while testing")
    func testLogCall() throws {
        let logger = AppLogger.mock().logger()
        
        #expect(logger == nil)
    }
}

#endif
