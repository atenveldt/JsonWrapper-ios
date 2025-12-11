import Testing
@testable import JsonWrapper

@Test func parseValidJson() throws {
    let json = #"{"name": "John", "age": 30}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.getString(key: "name") == "John")
    #expect(doc.getInt(key: "age") == 30)
}

@Test func parseInvalidJson() throws {
    #expect(throws: Error.self) {
        try JsonDocument(json: "invalid json")
    }
}

@Test func missingKey() throws {
    let json = #"{"name": "John"}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.getString(key: "missing") == nil)
    #expect(doc.getInt(key: "missing") == nil)
}

@Test func typeMismatch() throws {
    let json = #"{"name": "John", "age": 30}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.getInt(key: "name") == nil)     // name is string, not int
    #expect(doc.getString(key: "age") == nil)   // age is int, not string
}

@Test func booleanValues() throws {
    let json = #"{"active": true, "verified": false}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.getBool(key: "active") == true)
    #expect(doc.getBool(key: "verified") == false)
}

@Test func doubleValue() throws {
    let json = #"{"pi": 3.14}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.getDouble(key: "pi") == 3.14)
}

@Test func hasKey() throws {
    let json = #"{"name": "John"}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.hasKey("name") == true)
    #expect(doc.hasKey("missing") == false)
}

@Test func unicodeStrings() throws {
    let json = #"{"greeting": "你好世界", "emoji": "🎉"}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc.getString(key: "greeting") == "你好世界")
    #expect(doc.getString(key: "emoji") == "🎉")
}

@Test func convenienceApi() {
    let json = #"{"message": "Hello"}"#
    
    let message = JsonParser.getString(from: json, key: "message")!
    #expect(message == "Hello")
}

@Test func subscriptAccess() throws {
    let json = #"{"greeting": "Hello"}"#
    let doc = try JsonDocument(json: json)
    
    #expect(doc["greeting"] == "Hello")
    #expect(doc["missing"] == nil)
}

@Test func nullValue() throws {
      let json = #"{"name": "John", "nickname": null}"#
      let doc = try JsonDocument(json: json)

      #expect(doc.getString(key: "name") == "John")
      #expect(doc.getString(key: "nickname") == nil)  // null returns nil
  }

  @Test func parseReturnsNilForInvalidJson() {
      let result = JsonParser.parse("not valid json")
      #expect(result == nil)
  }
