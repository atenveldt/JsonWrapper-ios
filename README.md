# JsonWrapper

A Swift Package that wraps the nlohmann/json C++ library, providing JSON parsing through a safe Swift API.

## Technology Stack

- **Swift** - Public API and app layer
- **C++** - JSON parsing implementation
- **nlohmann/json** - Header-only JSON library
- **C-API Bridge** - `extern "C"` functions callable from Swift

## Quick Start

Open in Xcode:
```bash
open JsonWrapperWorkspace.xcworkspace
# Select "JsonWrapperDemo" scheme and run (Cmd + R)
```

Or from command line:
```bash
cd JsonWrapper
swift build
swift test
```

## Project Structure

```
ios/
├── JsonWrapper/              # Swift Package (library)
│   ├── Package.swift
│   ├── Sources/
│   │   ├── CxxJsonParser/    # C++ target (nlohmann/json + C-API)
│   │   └── JsonWrapper/      # Swift target (public API)
│   └── Tests/
├── JsonWrapperDemo/          # iOS demo app (SwiftUI)
└── JsonWrapperWorkspace.xcworkspace
```

## Architecture

```
┌─────────────────────────────────────┐
│       JsonWrapperDemo (App)         │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│     JsonWrapper (Swift Target)      │
│   Safe API, automatic memory mgmt   │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│    CxxJsonParser (C++ Target)       │
│   extern "C" bridge functions       │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│        nlohmann/json (C++)          │
│       Header-only JSON library      │
└─────────────────────────────────────┘
```

## Why This Architecture?

Swift cannot call C++ directly due to:
- **Name mangling**: C++ compilers modify function names
- **ABI incompatibility**: No stable C++ ABI across compilers

Solution: Wrap C++ in `extern "C"` functions that Swift can call.

## Memory Ownership

Functions returning `char*` allocate with `strdup()`. The Swift wrapper:

```swift
// C allocates memory
guard let cString = json_get_string(handle, key) else { return nil }

// Copy to Swift-managed memory
let result = String(cString: cString)

// Free C memory immediately
free_string(cString)

return result  // Safe Swift String
```

**Golden rule**: Whoever allocates must provide a way to deallocate.

## Usage

```swift
import JsonWrapper

// Parse and query multiple values
let doc = try JsonDocument(json: #"{"name": "John", "age": 30}"#)
let name = doc.getString(key: "name")  // Optional("John")
let age = doc.getInt(key: "age")       // Optional(30)

// One-liner for simple cases
let value = JsonParser.getString(from: jsonString, key: "name")
```

## Testing

```bash
cd JsonWrapper
swift test
```

Tests verify:
- Valid/invalid JSON parsing
- Type extraction (string, int, double, bool)
- Missing key handling
- Null value handling
- Unicode support

## Demo App Features

- JSON input editor
- Extract single value by key (supports all types)
- Parse all values at once
- Error handling display

## Requirements

- Xcode 15+
- iOS 15+ / macOS 12+
- Swift 5.9+
