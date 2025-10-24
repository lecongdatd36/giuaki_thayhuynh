const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/activityController");
const auth = require("../middleware/auth"); // ✅ sửa lại dòng này
const { requireRole } = require("../middleware/role");

router.get("/", auth, ctrl.list);
router.post("/", auth, requireRole("ADMIN", "LECTURER"), ctrl.create);
router.put("/:id", auth, requireRole("ADMIN", "LECTURER"), ctrl.update);
router.patch("/:id/status", auth, requireRole("ADMIN", "LECTURER"), ctrl.updateStatus);
router.delete("/:id", auth, requireRole("ADMIN", "LECTURER"), ctrl.remove);

module.exports = router;
