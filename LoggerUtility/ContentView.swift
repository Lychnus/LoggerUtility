//
//  ContentView.swift
//  LoggerUtility
//
//  Created by Tahir Anil Oghan on 8.07.2025.
//

import SwiftUI
import OSLog

// MARK: - Implementation
struct ContentView {
    
    @State private var logs: [OSLogEntryLog] = []
    @State private var isLoading: Bool = false
}

// MARK: - View
extension ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                loggingSection
                retrieveLogsSection
                logOutputSection
            }
            .navigationTitle("LoggerUtility Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var loggingSection: some View {
        Section("Log Events") {
            logButton("Debug Log", level: .debug, message: "Debugging system state.")
            logButton("Info Log", level: .info, message: "App started successfully.")
            logButton("Notice Log", level: .notice, message: "Background sync started.")
            logButton("Error Log", level: .error, message: "Data fetch failed.")
            logButton("Fault Log", level: .fault, message: "Critical failure occurred.")
        }
    }
    
    private var retrieveLogsSection: some View {
        Section {
            Button("Retrieve Logs (Last 5m)") {
                Task {
                    await loadLogs()
                }
            }
            .disabled(isLoading)
        }
    }

    private var logOutputSection: some View {
        Section("Recent Logs") {
            if logs.isEmpty {
                Text("No logs found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(logs, id: \.composedMessage) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("[\(log.level.description.uppercased())] \(log.composedMessage)")
                            .font(.caption)
                        
                        HStack {
                            Text(log.date.formatted(.dateTime.hour().minute().second()))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(log.category)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Private Functions
extension ContentView {
    
    private enum LogLevel {
        case debug, info, notice, error, fault
    }

    @ViewBuilder
    private func logButton(_ title: String, level: LogLevel, message: String) -> some View {
        Button(title) {
            let logger = DevTools.logging.logger()

            switch level {
            case .debug: logger?.debug("\(message)")
            case .info:  logger?.info("\(message)")
            case .notice: logger?.notice("\(message)")
            case .error: logger?.error("\(message)")
            case .fault: logger?.fault("\(message)")
            }
        }
    }
    
    private func loadLogs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            logs = try DevTools.logging.retrieveLogs(range: .lastMinutes(5), context: LogContext.development())
        } catch {
            logs = []
        }
    }
}

// MARK: - Preview
#Preview {
    // MARK: - Logging will not work on `Preview`, it only works on runtime. Please use simulator.
    ContentView()
}
