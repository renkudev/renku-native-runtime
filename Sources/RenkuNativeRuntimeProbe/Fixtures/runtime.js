let output = "ready";
globalThis.renkuNativeRender = () => output;
globalThis.renkuNativeInvoke = (action, payload) => {
  Promise.resolve().then(() => {
    output = `${action}:${payload}`;
  });
};
