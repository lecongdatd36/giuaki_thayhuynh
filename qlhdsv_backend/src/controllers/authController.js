const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const UserRepo = require("../repositories/userRepo");
const { sendMail } = require("../utils/mailService"); // ✅ thêm dòng này
require("dotenv").config();

exports.register = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        const exists = await UserRepo.findByEmail(email);
        if (exists) return res.status(400).json({ message: "Email đã tồn tại" });

        const hash = await bcrypt.hash(password, 10);
        const user = await UserRepo.create({ name, email, password: hash, role });

        // 📧 Gửi mail chào mừng
        await sendMail(
            email,
            "Chào mừng bạn đến với hệ thống QLHDSV 🎓",
            `
      <h2>Xin chào ${name},</h2>
      <p>Bạn đã đăng ký tài khoản thành công trên hệ thống <b>Quản lý Hoạt động Sinh viên - Khoa CNTT</b>.</p>
      <p>Bạn có thể đăng nhập ngay để tham gia các hoạt động và theo dõi điểm rèn luyện.</p>
      <hr/>
      <p><i>Hệ thống QLHDSV Khoa CNTT</i></p>
      `
        );

        res.json({
            message: "Đăng ký tài khoản thành công! Đã gửi email xác nhận.",
            data: { id: user.id, name: user.name, email: user.email, role: user.role },
        });
    } catch (err) {
        console.error("❌ Lỗi khi đăng ký tài khoản:", err);
        res.status(500).json({ message: err.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await UserRepo.findByEmail(email);
        if (!user) return res.status(404).json({ message: "Không tìm thấy người dùng" });

        const match = await bcrypt.compare(password, user.password);
        if (!match) return res.status(401).json({ message: "Sai mật khẩu" });

        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role, name: user.name },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        res.json({
            message: "Đăng nhập thành công",
            token,
            user: { id: user.id, name: user.name, role: user.role },
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
exports.changePassword = async (req, res) => {
    try {
        const userId = req.user.id; // lấy từ token (middleware auth)
        const { oldPassword, newPassword } = req.body;

        // Tìm user theo ID
        const user = await UserRepo.findById(userId);
        if (!user) return res.status(404).json({ message: "Không tìm thấy người dùng" });

        // Kiểm tra mật khẩu cũ
        const match = await bcrypt.compare(oldPassword, user.password);
        if (!match) return res.status(401).json({ message: "Mật khẩu cũ không đúng" });

        // Mã hóa mật khẩu mới
        const newHash = await bcrypt.hash(newPassword, 10);
        await UserRepo.updatePassword(userId, newHash);

        // 📧 Gửi mail thông báo
        const { sendMail } = require("../utils/mailService");
        await sendMail(
            user.email,
            "Thông báo thay đổi mật khẩu 🔒",
            `
      <h2>Xin chào ${user.name},</h2>
      <p>Mật khẩu của bạn đã được thay đổi thành công vào lúc ${new Date().toLocaleString("vi-VN")}.</p>
      <p>Nếu bạn không thực hiện hành động này, vui lòng liên hệ quản trị viên ngay lập tức.</p>
      <hr/>
      <p><i>Hệ thống QLHDSV Khoa CNTT</i></p>
      `
        );

        res.json({ message: "Đổi mật khẩu thành công! Đã gửi mail xác nhận." });
    } catch (err) {
        console.error("❌ Lỗi khi đổi mật khẩu:", err);
        res.status(500).json({ message: "Lỗi khi đổi mật khẩu" });
    }
};
// 🧩 QUẢN LÝ NGƯỜI DÙNG (ADMIN)
// ===========================================

// 🟢 Lấy danh sách user
exports.listUsers = async (req, res) => {
  try {
    const users = await UserRepo.list();
    res.json(users);
  } catch (err) {
    console.error("❌ Lỗi lấy danh sách user:", err);
    res.status(500).json({ message: "Lỗi server khi lấy danh sách người dùng" });
  }
};

// 🟢 Tạo mới (admin thêm tay)
exports.createUser = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    const exists = await UserRepo.findByEmail(email);
    if (exists) return res.status(400).json({ message: "Email đã tồn tại" });

    const hash = await bcrypt.hash(password, 10);
    const newUser = await UserRepo.create({ name, email, password: hash, role });
    res.json({ message: "Tạo người dùng thành công", newUser });
  } catch (err) {
    console.error("❌ Lỗi tạo user:", err);
    res.status(500).json({ message: "Lỗi server khi tạo user" });
  }
};

// 🟠 Cập nhật user
exports.updateUser = async (req, res) => {
  try {
    const id = req.params.id;
    const { name, email, password, role } = req.body;
    const hash = password ? await bcrypt.hash(password, 10) : null;
    const updated = await UserRepo.update(id, { name, email, password: hash, role });
    res.json({ message: "Cập nhật thành công", user: updated });
  } catch (err) {
    console.error("❌ Lỗi cập nhật user:", err);
    res.status(500).json({ message: "Lỗi server khi cập nhật user" });
  }
};

// 🔴 Xóa user
exports.deleteUser = async (req, res) => {
  try {
    const id = req.params.id;
    const ok = await UserRepo.remove(id);
    if (!ok) return res.status(404).json({ message: "Không tìm thấy người dùng" });
    res.json({ message: "Đã xóa người dùng thành công" });
  } catch (err) {
    console.error("❌ Lỗi xóa user:", err);
    res.status(500).json({ message: "Lỗi server khi xóa user" });
  }
};
// 🧾 Lấy thông tin cá nhân sinh viên
exports.getProfile = async (req, res) => {
  try {
    const user = await require("../repositories/userRepo").findById(req.user.id);
    if (!user) return res.status(404).json({ message: "Không tìm thấy người dùng" });

    // ✅ Tính tổng hoạt động và điểm thưởng
    const { q } = require("../db/pool");
    const { rows } = await q(
      `SELECT 
         COUNT(*) AS total_activities,
         COALESCE(SUM(a.reward_point), 0) AS total_points
       FROM registrations r
       JOIN activities a ON a.id = r.activity_id
       WHERE r.user_id = $1`,
      [user.id]
    );

    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      total_activities: parseInt(rows[0].total_activities),
      total_points: parseInt(rows[0].total_points),
    });
  } catch (err) {
    console.error("❌ Lỗi lấy thông tin cá nhân:", err);
    res.status(500).json({ message: "Lỗi server khi lấy thông tin cá nhân" });
  }
};
