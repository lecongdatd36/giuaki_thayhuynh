const RegistrationRepo = require("../repositories/registrationRepo");
const ActivityRepo = require("../repositories/activityRepo");
const { sendMail } = require("../utils/mailService");
const { q } = require("../db/pool");

// 🟢 Sinh viên đăng ký hoạt động
exports.register = async (req, res) => {
  try {
    const activityId = Number(req.params.id);
    const userId = req.user.id;

    // 🔍 1. Kiểm tra hoạt động tồn tại
    const activity = await ActivityRepo.get(activityId);
    if (!activity)
      return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    const now = new Date();
    const startAt = new Date(activity.start_at);
    const endAt = new Date(activity.end_at);

    // ⛔ Nếu hoạt động đã bắt đầu
    if (now >= startAt)
      return res
        .status(400)
        .json({ message: "Hoạt động đã bắt đầu, không thể đăng ký" });

    // ⛔ Nếu hoạt động đã kết thúc
    if (now >= endAt)
      return res
        .status(400)
        .json({ message: "Hoạt động đã kết thúc, không thể đăng ký" });

    // 🔍 2. Kiểm tra trùng đăng ký
    const existed = await RegistrationRepo.find(activityId, userId);
    if (existed)
      return res
        .status(400)
        .json({ message: "Bạn đã đăng ký hoạt động này rồi" });

    // 🔍 3. Kiểm tra số lượng chỗ
    const list = await RegistrationRepo.listByActivity(activityId);
    if (list.length >= activity.max_slots)
      return res.status(400).json({ message: "Hoạt động đã đủ chỗ" });

    // 🟢 4. Lưu đăng ký mới
    const reg = await RegistrationRepo.register(activityId, userId);

    // 📩 Gửi mail xác nhận
    await sendMail(
      req.user.email,
      "Xác nhận đăng ký hoạt động 🎓",
      `
      <h3>Bạn đã đăng ký thành công hoạt động: ${activity.title}</h3>
      <p><b>Thời gian:</b> ${activity.start_at} - ${activity.end_at}</p>
      <p><b>Địa điểm:</b> ${activity.location}</p>
      <hr/>
      <p>Hẹn gặp bạn tại buổi hoạt động 🎯</p>
      `
    );

    res.json({ message: "Đăng ký thành công!", data: reg });
  } catch (err) {
    console.error("❌ Lỗi đăng ký:", err);
    res.status(500).json({ message: "Lỗi server khi đăng ký" });
  }
};

// 🟡 Hủy đăng ký
exports.unregister = async (req, res) => {
  try {
    const userId = req.user.id;
    const activityId = Number(req.params.id);

    // 🔍 Kiểm tra đăng ký tồn tại chưa
    const reg = await RegistrationRepo.findByUserAndActivity(userId, activityId);
    if (!reg)
      return res.status(404).json({ message: "Không tìm thấy đăng ký để hủy" });

    // 🔍 Lấy thông tin hoạt động
    const activity = await ActivityRepo.get(activityId);
    if (!activity)
      return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    // ⏰ Không cho hủy nếu hoạt động đã bắt đầu
    const now = new Date();
    if (new Date(activity.start_at) <= now)
      return res
        .status(400)
        .json({ message: "Hoạt động đã bắt đầu, không thể hủy" });

    // 🗑 Tiến hành xóa
    const ok = await RegistrationRepo.unregister(activityId, userId);
    if (!ok)
      return res.status(400).json({ message: "Hủy đăng ký thất bại" });

    res.json({ message: "Đã hủy đăng ký thành công" });
  } catch (err) {
    console.error("❌ Lỗi hủy đăng ký:", err);
    res.status(500).json({ message: "Lỗi server khi hủy đăng ký" });
  }
};


// 🟢 Danh sách đăng ký theo hoạt động
exports.listByActivity = async (req, res) => {
  try {
    const rows = await RegistrationRepo.listByActivity(req.params.id);
    res.json(rows);
  } catch (err) {
    console.error("❌ Lỗi lấy danh sách đăng ký:", err);
    res.status(500).json({ message: "Lỗi server khi lấy danh sách đăng ký" });
  }
};

// 🟠 Admin/giảng viên điểm danh trực tiếp
exports.markAttendance = async (req, res) => {
  try {
    const { registration_id, status } = req.body; // PRESENT / ABSENT
    const markerId = req.user.id;

    // 🔍 Kiểm tra tồn tại đăng ký
    const reg = await RegistrationRepo.findById(registration_id);
    if (!reg)
      return res.status(404).json({ message: "Không tìm thấy đăng ký" });

    // 🟢 Cập nhật trạng thái điểm danh
    const updated = await RegistrationRepo.updateAttendance(
      registration_id,
      status,
      markerId
    );

    if (!updated)
      return res
        .status(400)
        .json({ message: "Không thể cập nhật điểm danh" });

    res.json({
      message: "Điểm danh thành công",
      data: updated,
    });
  } catch (err) {
    console.error("❌ Lỗi điểm danh:", err);
    res.status(500).json({ message: "Lỗi server khi điểm danh" });
  }
};

// 🧾 Danh sách điểm danh của 1 hoạt động
exports.attendanceList = async (req, res) => {
  try {
    const activityId = req.params.id;
    const list = await RegistrationRepo.listAttendanceByActivity(activityId);

    if (!list.length)
      return res
        .status(404)
        .json({ message: "Chưa có ai đăng ký hoặc chưa điểm danh" });

    res.json(list);
  } catch (err) {
    console.error("❌ Lỗi xem danh sách điểm danh:", err);
    res.status(500).json({ message: "Lỗi server khi lấy danh sách điểm danh" });
  }
};
// 🧾 Sinh viên xem danh sách hoạt động của mình
exports.listMyRegistrations = async (req, res) => {
  try {
    const userId = req.user.id;
    const list = await RegistrationRepo.listByUser(userId);
    if (!list.length)
      return res.status(404).json({ message: "Bạn chưa đăng ký hoạt động nào" });
    res.json(list);
  } catch (err) {
    console.error("❌ Lỗi lấy danh sách hoạt động của sinh viên:", err);
    res.status(500).json({ message: "Lỗi server khi lấy danh sách" });
  }
};
// ✅ Kiểm tra trạng thái hoạt động của sinh viên
exports.checkStatus = async (req, res) => {
  try {
    const studentId = req.user.id;
    const activityId = req.params.id;

    const { rows } = await q(
      `SELECT r.id, r.attendance_status
       FROM registrations r
       WHERE r.activity_id = $1 AND r.user_id = $2`,
      [activityId, studentId]
    );

    if (rows.length === 0) {
      return res.json({
        is_registered: false,
        is_attended: false,
      });
    }

    const reg = rows[0];
    res.json({
      is_registered: true,
      // ✅ Đã điểm danh nếu trạng thái là 'PRESENT'
      is_attended: reg.attendance_status === "PRESENT",
    });
  } catch (err) {
    console.error("❌ checkStatus error:", err);
    res.status(500).json({ message: "Lỗi kiểm tra trạng thái" });
  }
};