#include "renku_native_runtime.h"

#include "hermes/hermes.h"
#include "jsi/jsi.h"

#include <cstddef>
#include <memory>
#include <string>
#include <utility>

namespace {
thread_local std::string lastError;

void installNativeCapabilities(facebook::jsi::Runtime &runtime) {
  auto capabilities = facebook::jsi::Object(runtime);
  auto has = facebook::jsi::Function::createFromHostFunction(
    runtime,
    facebook::jsi::PropNameID::forAscii(runtime, "has"),
    1,
    [](facebook::jsi::Runtime &,
       const facebook::jsi::Value &,
       const facebook::jsi::Value *,
       std::size_t) {
      return facebook::jsi::Value(false);
    }
  );
  capabilities.setProperty(runtime, "has", std::move(has));
  runtime.global().setProperty(runtime, "renkuNativeCapabilities", std::move(capabilities));
}

struct RuntimeState {
  std::unique_ptr<facebook::jsi::Runtime> engine;
  facebook::jsi::Function renderFunction;
  facebook::jsi::Function invokeFunction;
  std::string lastResult;

  RuntimeState(
    std::unique_ptr<facebook::jsi::Runtime> engine,
    facebook::jsi::Function renderFunction,
    facebook::jsi::Function invokeFunction
  )
      : engine(std::move(engine)),
        renderFunction(std::move(renderFunction)),
        invokeFunction(std::move(invokeFunction)) {}

  const char *render() {
    lastResult = renderFunction.call(*engine).asString(*engine).utf8(*engine);
    return lastResult.c_str();
  }

  const char *invoke(int32_t action, const char *payload) {
    auto value = facebook::jsi::String::createFromUtf8(*engine, payload);
    lastResult =
      invokeFunction.call(*engine, action, std::move(value)).asString(*engine).utf8(*engine);
    return lastResult.c_str();
  }
};

std::unique_ptr<RuntimeState> load(const uint8_t *bytecode, size_t length) {
  auto engine = facebook::hermes::makeHermesRuntime();
  installNativeCapabilities(*engine);
  auto contents = std::string(reinterpret_cast<const char *>(bytecode), length);
  engine->evaluateJavaScript(
    std::make_unique<facebook::jsi::StringBuffer>(std::move(contents)),
    "native-app.hbc"
  );
  auto global = engine->global();
  auto renderFunction = global.getPropertyAsFunction(*engine, "renkuNativeRender");
  auto invokeFunction = global.getPropertyAsFunction(*engine, "renkuNativeInvoke");
  return std::make_unique<RuntimeState>(
    std::move(engine),
    std::move(renderFunction),
    std::move(invokeFunction)
  );
}

template <typename Result, typename Operation>
Result catchErrors(Result failure, Operation operation) {
  try {
    auto result = operation();
    lastError.clear();
    return result;
  } catch (const std::exception &error) {
    lastError = error.what();
    return failure;
  } catch (...) {
    lastError = "Unknown Hermes runtime error";
    return failure;
  }
}
}

struct renku_native_runtime {
  std::unique_ptr<RuntimeState> state;
};

renku_native_runtime *renku_native_runtime_create(const uint8_t *bytecode, size_t length) {
  return catchErrors<renku_native_runtime *>(nullptr, [=] {
    return new renku_native_runtime{load(bytecode, length)};
  });
}

void renku_native_runtime_destroy(renku_native_runtime *runtime) {
  delete runtime;
}

int renku_native_runtime_reload(
  renku_native_runtime *runtime,
  const uint8_t *bytecode,
  size_t length
) {
  if (runtime == nullptr) {
    lastError = "Runtime is not initialized";
    return 0;
  }
  return catchErrors<int>(0, [=] {
    auto candidate = load(bytecode, length);
    candidate->render();
    runtime->state = std::move(candidate);
    return 1;
  });
}

const char *renku_native_runtime_render(renku_native_runtime *runtime) {
  if (runtime == nullptr) {
    lastError = "Runtime is not initialized";
    return nullptr;
  }
  return catchErrors<const char *>(nullptr, [&] {
    return runtime->state->render();
  });
}

const char *renku_native_runtime_invoke(
  renku_native_runtime *runtime,
  int32_t action,
  const char *payload
) {
  if (runtime == nullptr) {
    lastError = "Runtime is not initialized";
    return nullptr;
  }
  if (payload == nullptr) {
    lastError = "Action payload is not initialized";
    return nullptr;
  }
  return catchErrors<const char *>(nullptr, [&] {
    return runtime->state->invoke(action, payload);
  });
}

const char *renku_native_runtime_last_error(void) {
  return lastError.c_str();
}
