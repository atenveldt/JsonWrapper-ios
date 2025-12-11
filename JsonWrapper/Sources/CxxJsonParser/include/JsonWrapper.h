#ifndef JSON_WRAPPER_H
#define JSON_WRAPPER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaue handle - hides C++ types from Swift
typedef struct JsonDocument JsonDocument;

// Document Lifecycle
JsonDocument* json_document_create(const char* json_string) ;
void json_document_free(JsonDocument* doc);

// Value extraction
char* json_get_string(const JsonDocument* doc, const char* key);
bool json_get_int(const JsonDocument* doc, const char* key, int64_t* out_value);
bool json_get_double(const JsonDocument* doc, const char* key, double* out_value);
bool json_get_bool(const JsonDocument* doc, const char* key, bool* out_value);
bool json_has_key(const JsonDocument* doc, const char* key);

// Conveninece (parse + extract)
char* json_parse_get_string(const char* json_string, const char* key);

// Memory Management - MUST call for any returned char*
void free_string(char* str);

// Error info
char* json_get_last_error(void);

#ifdef __cplusplus
}
#endif

#endif // JSON_WRAPPER_H
