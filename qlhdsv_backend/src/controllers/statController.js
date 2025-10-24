const StatRepo = require("../repositories/statRepo");
const ActivityRepo = require("../repositories/activityRepo");

// 🧮 Thống kê tổng quan cho Admin
exports.adminStats = async (req, res) => {
  try {
    const data = await StatRepo.getAdminStats();
    res.json(data);
  } catch (err) {
    console.error("❌ Lỗi thống kê ADMIN:", err);
    res.status(500).json({ message: "Lỗi server khi lấy thống kê" });
  }
};

// 🧑‍🏫 Thống kê tổng quan cho Giảng viên (theo tài khoản đăng nhập)
exports.lecturerStats = async (req, res) => {
  try {
    const lecturerId = req.user.id;
    const data = await StatRepo.getLecturerStats(lecturerId);
    res.json(data);
  } catch (err) {
    console.error("❌ Lỗi thống kê GIẢNG VIÊN:", err);
    res.status(500).json({ message: "Lỗi server khi lấy thống kê giảng viên" });
  }
};

// 📊 Thống kê chi tiết theo từng hoạt động (Admin dùng)
exports.activityStatsReport = async (_, res) => {
  try {
    const data = await ActivityRepo.getActivityStats();
    res.json(data);
  } catch (err) {
    console.error("❌ Lỗi thống kê theo hoạt động:", err);
    res.status(500).json({ message: "Lỗi server khi lấy thống kê hoạt động" });
  }
};

// 👨‍🏫 Thống kê chi tiết theo từng giảng viên (Admin dùng)
exports.lecturerStatsReport = async (_, res) => {
  try {
    const data = await ActivityRepo.getLecturerStats();
    res.json(data);
  } catch (err) {
    console.error("❌ Lỗi thống kê theo giảng viên:", err);
    res.status(500).json({ message: "Lỗi server khi lấy thống kê giảng viên" });
  }
};
exports.lecturerActivityDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const { rows } = await q(
      `SELECT u.name, u.email, r.attendance_status, r.marked_at
       FROM registrations r
       JOIN users u ON u.id = r.user_id
       WHERE r.activity_id = $1
       ORDER BY r.attendance_status DESC, u.name ASC`,
      [id]
    );
    res.json(rows);
  } catch (err) {
    console.error("❌ Lỗi xem chi tiết hoạt động:", err);
    res.status(500).json({ message: "Lỗi khi lấy danh sách đăng ký" });
  }
};