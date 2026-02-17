function getPingMessage() {
  return {
    ok: true,
    message: "MVC OK ✅ (service)",
    timestamp: new Date().toISOString(),
  };
}

module.exports = { getPingMessage };