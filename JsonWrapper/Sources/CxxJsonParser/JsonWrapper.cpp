#include "JsonWrapper.h"
#include <nlohmann/json.hpp>

#include <string>
#include <cstring>
#include <cstdlib>

using json = nlohmann::json;

// Thread-local error storage
static thread_local std::string g_lastError;

static void setError(const std::string& message) {
    g_lastError = message;
}

static void clearError() {
    g_lastError.clear();
}

// Opaque document structure - holds the parsed JSON
struct JsonDocument {
    json data;
    explicit JsonDocument(json&& j) : data(std::move(j)) {}
};

// =========================================================
// Document Lifecycle
// =========================================================
extern "C" JsonDocument* json_document_create(const char* json_string) {
    clearError();
    
    if(json_string == nullptr) {
        setError("Input JSON string is null");
        return nullptr;
    }
    
    try {
        json j = json::parse(json_string);
        return new JsonDocument(std::move(j));
    } catch (const json::parse_error& e) {
        setError(std::string("JSON parse error: ") + e.what());
        return nullptr;
    } catch (const std::exception& e) {
        setError(std::string("Unexpected error: ") + e.what());
        return nullptr;
    }
}

extern "C" void json_document_free(JsonDocument* doc) {
    delete doc; // safe to delete nullptr
}

// =========================================================
// Value extraction
// =========================================================
extern "C" char* json_get_string(const JsonDocument* doc, const char* key) {
    clearError();
    
    if(doc == nullptr || key == nullptr) {
        setError("Null parameter");
        return nullptr;
    }
    
    try {
        if(!doc->data.contains(key)) {
            setError(std::string("Key not found: ") + key);
            return nullptr;
        }
        
        const auto& value = doc->data[key];
        if(!value.is_string()) {
            setError(std::string("Value for '") + key + "' is not a string");
            return nullptr;
        }
        
        std::string str = value.get<std::string>();
        return strdup(str.c_str()); // Caller must free
        
    } catch (const std::exception& e) {
        setError(std::string("Error: ") + e.what());
        return nullptr;
    }
}

extern "C" bool json_get_int(const JsonDocument* doc, const char* key, int64_t* out_value) {
    clearError();

    if (doc == nullptr || key == nullptr || out_value == nullptr) {
        setError("Null parameter");
        return false;
    }

    try {
        if (!doc->data.contains(key)) return false;

        const auto& value = doc->data[key];
        if (!value.is_number_integer()) return false;

        *out_value = value.get<int64_t>();
        return true;
    } catch (...) {
        return false;
    }
}

extern "C" bool json_get_double(const JsonDocument* doc, const char* key, double* out_value) {
    clearError();
    
    if(doc == nullptr || key == nullptr || out_value == nullptr) {
        return false;
    }
    
    try {
        if(!doc->data.contains(key)) return false;
        
        const auto& value = doc->data[key];
        if(!value.is_number()) return false;
        
        *out_value = value.get<double>();
        return true;
    } catch(...) {
        return false;
    }
}

extern "C" bool json_get_bool(const JsonDocument* doc, const char* key, bool* out_value) {
    clearError();
    
    if(doc == nullptr || key == nullptr || out_value == nullptr) {
        return false;
    }
    
    try {
        if(!doc->data.contains(key)) return false;
        
        const auto& value = doc->data[key];
        if(!value.is_boolean()) return false;
        
        *out_value = value.get<bool>();
        return true;
    } catch(...) {
        return false;
    }
}

extern "C" bool json_has_key(const JsonDocument* doc, const char* key) {
    if(doc == nullptr || key == nullptr) return false;
    
    try {
        return doc->data.contains(key);
    } catch(...) {
        return false;
    }
}

// =========================================================
// Convenience function
// =========================================================
extern "C" char* json_parse_get_string(const char* json_string, const char* key) {
    JsonDocument* doc = json_document_create(json_string);
    if(doc == nullptr) return nullptr;
    
    char* result = json_get_string(doc, key);
    json_document_free(doc);
    
    return result;
}


// =========================================================
// Memory management
// =========================================================

extern "C" void free_string(char* str) {
    free(str);  // free(nullptr) is safe
}

extern "C" char* json_get_last_error(void) {
    if(g_lastError.empty()) return nullptr;
    return strdup(g_lastError.c_str());
}
