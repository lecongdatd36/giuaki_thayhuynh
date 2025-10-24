const router = require("express").Router();
const ctrl = require("../controllers/registrationController");
const auth = require("../middleware/auth");


const { requireRole } = require("../middleware/role");

// 🟢 Điểm danh (ADMIN / LECTURER) — đặt trước /:id
router.post(
  "/attendance/mark",
  auth,
  requireRole("ADMIN", "LECTURER"),
  ctrl.markAttendance
);

// 🧍‍♂️ Sinh viên đăng ký / hủy
router.post("/:id", auth, requireRole("STUDENT"), ctrl.register);
router.delete("/:id", auth, requireRole("STUDENT"), ctrl.unregister);

// 👩‍🎓 Sinh viên xem danh sách hoạt động của mình
router.get("/mine", auth, requireRole("STUDENT"), ctrl.listMyRegistrations);

// 👩‍🏫 Giảng viên / Admin xem danh sách đăng ký
router.get("/:id", auth, requireRole("ADMIN", "LECTURER"), ctrl.listByActivity);

// 🟡 Xem danh sách điểm danh theo hoạt động
router.get(
  "/:id/attendance",
  auth,
  requireRole("ADMIN", "LECTURER"),
  ctrl.attendanceList
);
// 🔍 Kiểm tra trạng thái đăng ký & điểm danh của sinh viên
router.get(
  "/status/:id",
  auth,
  requireRole("STUDENT"),
  ctrl.checkStatus
);

module.exports = router;
