const router = require("express").Router();

const healthRoutes = require("./health.routes");
const pingRoutes = require("./ping.routes");

router.use(healthRoutes);
router.use(pingRoutes);

module.exports = router;