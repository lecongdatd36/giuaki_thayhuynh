// ✅ src/controllers/activityController.js
const ActivityRepo = require("../repositories/activityRepo");

// 🟢 Danh sách hoạt động
exports.list = async (req, res) => {
  try {
    await ActivityRepo.updateStatusAuto();

    // ✅ Nếu là giảng viên thì chỉ lấy hoạt động do họ tạo
    const role = req.user.role;
    let rows;

    if (role === "LECTURER") {
      rows = await ActivityRepo.listByCreator(req.user.id);
    } else {
      rows = await ActivityRepo.list(); // admin hoặc student xem toàn bộ
    }

    res.json(rows);
  } catch (err) {
    console.error("❌ Lỗi lấy danh sách hoạt động:", err);
    res.status(500).json({ message: "Lỗi server khi lấy danh sách hoạt động" });
  }
};

// 🟢 Tạo mới hoạt động (ADMIN hoặc GIẢNG VIÊN)
exports.create = async (req, res) => {
  try {
    const {
      title,
      description,
      start_at,
      end_at,
      location,
      max_slots,
      reward_point = 25,
      lecturer_id, // 🆕 Nếu admin chọn giảng viên phụ trách
    } = req.body;

    // 🧠 Mặc định: người tạo là người đăng nhập
    let created_by = req.user.id;
    if (req.user.role === "ADMIN" && lecturer_id) {
      // Nếu là admin thì dùng id giảng viên được chọn
      created_by = lecturer_id;
    }

    const newActivity = await ActivityRepo.create({
      title,
      description,
      start_at,
      end_at,
      location,
      max_slots,
      reward_point,
      status: "OPEN",
      created_by,
    });

    res.json({
      message: "Tạo hoạt động thành công",
      data: newActivity,
    });
  } catch (err) {
    console.error("❌ Lỗi tạo hoạt động:", err);
    res.status(500).json({ message: "Lỗi server khi tạo hoạt động" });
  }
};

// 🟢 Cập nhật toàn bộ thông tin hoạt động
exports.update = async (req, res) => {
  try {
    const id = req.params.id;
    const data = req.body;
    const updated = await ActivityRepo.update(id, data);

    if (!updated) {
      return res
        .status(404)
        .json({ message: "Không tìm thấy hoạt động để cập nhật" });
    }

    res.json({
      message: "Cập nhật hoạt động thành công",
      activity: updated,
    });
  } catch (err) {
    console.error("❌ Lỗi cập nhật hoạt động:", err);
    res
      .status(500)
      .json({ message: "Lỗi server khi cập nhật hoạt động" });
  }
};

// 🟡 Cập nhật trạng thái
exports.updateStatus = async (req, res) => {
  try {
    const id = req.params.id;
    const { status } = req.body;
    const updated = await ActivityRepo.updateStatus(id, status);

    res.json({
      message: "Cập nhật trạng thái thành công",
      activity: updated,
    });
  } catch (err) {
    console.error("❌ Lỗi cập nhật trạng thái:", err);
    res.status(500).json({ message: "Lỗi khi cập nhật trạng thái" });
  }
};

// 🔴 Xóa hoạt động
exports.remove = async (req, res) => {
  try {
    const ok = await ActivityRepo.delete(req.params.id);
    if (!ok)
      return res
        .status(404)
        .json({ message: "Không tìm thấy hoạt động để xóa" });
    res.json({ message: "Đã xóa hoạt động thành công" });
  } catch (err) {
    console.error("❌ Lỗi khi xóa hoạt động:", err);
    res.status(500).json({ message: "Lỗi server khi xóa hoạt động" });
  }
};
