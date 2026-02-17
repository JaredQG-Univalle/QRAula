const router = require("express").Router();
const pingController = require("../controllers/ping.controller");

router.get("/ping", pingController.ping);

module.exports = router;