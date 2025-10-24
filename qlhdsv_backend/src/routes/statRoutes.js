const router = require("express").Router();
const auth = require("../middleware/auth");
const { requireRole } = require("../middleware/role");
const ctrl = require("../controllers/statController");

// 🧮 ADMIN - Thống kê tổng quan
router.get("/admin", auth, requireRole("ADMIN"), ctrl.adminStats);

// 📊 ADMIN - Thống kê theo từng hoạt động
router.get("/admin/activities", auth, requireRole("ADMIN"), ctrl.activityStatsReport);

// 👨‍🏫 ADMIN - Thống kê theo từng giảng viên
router.get("/admin/lecturers", auth, requireRole("ADMIN"), ctrl.lecturerStatsReport);

// 🧑‍🏫 GIẢNG VIÊN - Thống kê của giảng viên đăng nhập
router.get("/lecturer", auth, requireRole("LECTURER"), ctrl.lecturerStats);
// chi tiet ai dang ki ai diem danh theo hoat dong
router.get(
  "/lecturer/activity/:id",
  auth,
  requireRole("LECTURER"),
  ctrl.lecturerActivityDetail
);

module.exports = router;
