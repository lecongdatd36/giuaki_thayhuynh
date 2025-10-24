const router = require("express").Router();
const ctrl = require("../controllers/authController.js");
const { requireRole } = require("../middleware/role");
const auth = require("../middleware/auth");
router.post("/register", ctrl.register);
router.post("/login", ctrl.login);
router.put("/change-password", auth, ctrl.changePassword);
// 🧩 ADMIN QUẢN LÝ NGƯỜI DÙNG
router.get("/users", auth, requireRole("ADMIN"), ctrl.listUsers);
router.put("/users/:id", auth, requireRole("ADMIN"), ctrl.updateUser);
router.delete("/users/:id", auth, requireRole("ADMIN"), ctrl.deleteUser);
router.post("/users", auth, requireRole("ADMIN"), ctrl.createUser);
router.get("/profile", auth, requireRole("STUDENT"), ctrl.getProfile);

module.exports = router;
