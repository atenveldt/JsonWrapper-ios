//
//  ContentView.swift
//  JsonWrapperDemo
//
//  Created by Joey Bresette on 12/11/25.
//

import SwiftUI
import JsonWrapper

struct ContentView: View {
    @State private var jsonInput: String = """
        {
            "name": "John Doe",
            "age": 30,
            "email": "john@example.com",
            "active": true,
            "balance": 1234.56
        }
        """
    
    @State private var keyToExtract: String = "name"
    @State private var extractedValue: String = ""
    @State private var errorMessage: String? = nil
    @State private var allValues: [String: String] = [:]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("JSON Input") {
                    TextEditor(text: $jsonInput)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 150)
                }
                
                Section("Extract Single Value") {
                    TextField("Key", text: $keyToExtract)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button("Extract Value") {
                        extractSingleValue()
                    }
                    
                    if !extractedValue.isEmpty {
                        HStack {
                            Text("Result:")
                                .foregroundStyle(.secondary)
                            Text(extractedValue)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section("All Parsed Values") {
                    Button("Parse All Values") {
                        parseAllValues()
                    }
                    
                    ForEach(allValues.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(value)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                if let error = errorMessage {
                    Section("Error") {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("JSON Parser")
        }
    }
    
    private func extractSingleValue() {
        errorMessage = nil
        extractedValue = ""
        
        do {
            let doc = try JsonDocument(json: jsonInput)
            if !doc.hasKey(keyToExtract) {
                errorMessage = "Key '\(keyToExtract)' not found in JSON."
                return
            }
            
            // Try each type
            if let str = doc.getString(key: keyToExtract) {
                extractedValue = "\"\(str)\" (string)"
            } else if let int = doc.getInt(key: keyToExtract) {
                extractedValue = "\(int) (int)"
            } else if let dbl = doc.getDouble(key: keyToExtract) {
                extractedValue = "\(dbl) (double)"
            } else if let bool = doc.getBool(key: keyToExtract) {
                extractedValue = "\(bool) (bool)"
            } else {
                errorMessage = "Could not extract '\(keyToExtract)' - unsupported type"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func parseAllValues() {
        errorMessage = nil
        allValues = [:]
        
        do {
            let doc = try JsonDocument(json: jsonInput)
            let keysToTry = ["name", "age", "email", "active", "balance"]
            
            for key in keysToTry {
                if !doc.hasKey(key) { continue }
                
                if let str = doc.getString(key: key) {
                    allValues[key] = "\"\(str)\""
                } else if let int = doc.getInt(key: key) {
                    allValues[key] = "\(int)"
                } else if let dbl = doc.getDouble(key: key) {
                    allValues[key] = "\(dbl)"
                } else if let bool = doc.getBool(key: key) {
                    allValues[key] = "\(bool)"
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
