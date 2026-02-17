const pingService = require("../services/ping.service");

function ping(req, res) {
  const data = pingService.getPingMessage();
  return res.status(200).json(data);
}

module.exports = { ping };