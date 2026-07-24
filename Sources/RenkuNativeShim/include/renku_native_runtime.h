#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct renku_native_runtime renku_native_runtime;

renku_native_runtime *renku_native_runtime_create(const uint8_t *bytecode, size_t length);
void renku_native_runtime_destroy(renku_native_runtime *runtime);
int renku_native_runtime_reload(
  renku_native_runtime *runtime,
  const uint8_t *bytecode,
  size_t length
);
const char *renku_native_runtime_render(renku_native_runtime *runtime);
const char *renku_native_runtime_invoke(
  renku_native_runtime *runtime,
  int32_t action,
  const char *payload
);
const char *renku_native_runtime_last_error(void);

#ifdef __cplusplus
}
#endif
