const router = require("express").Router();

router.get("/health", (req, res) => {
  res.status(200).json({ ok: true, message: "Backend funcionando ✅" });
});

module.exports = router;