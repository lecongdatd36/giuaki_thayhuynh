const { q } = require("../db/pool");

// 🟢 Đăng ký hoạt động
exports.register = async (activityId, userId) => {
  try {
    const { rows } = await q(
      `INSERT INTO registrations (user_id, activity_id, created_at)
       VALUES ($1, $2, NOW())
       RETURNING *`,
      [userId, activityId]
    );
    return rows[0];
  } catch (err) {
    if (err.code === "23505") return null; // duplicate key
    throw err;
  }
};

// 🔍 Kiểm tra trùng đăng ký
exports.find = async (activityId, userId) => {
  const { rows } = await q(
    "SELECT * FROM registrations WHERE activity_id = $1 AND user_id = $2",
    [activityId, userId]
  );
  return rows[0];
};

// 🔍 Lấy đăng ký theo ID
exports.findById = async (registrationId) => {
  const { rows } = await q("SELECT * FROM registrations WHERE id = $1", [registrationId]);
  return rows[0];
};
exports.findByUserAndActivity = async (userId, activityId) => {
  const { rows } = await q(
    "SELECT id FROM registrations WHERE user_id = $1 AND activity_id = $2",
    [userId, activityId]
  );
  return rows[0];
};

// 🟡 Hủy đăng ký
exports.unregister = async (activityId, userId) => {
  const { rowCount } = await q(
    "DELETE FROM registrations WHERE activity_id = $1 AND user_id = $2",
    [activityId, userId]
  );
  return rowCount > 0;
};

// 🟢 Danh sách đăng ký theo hoạt động
exports.listByActivity = async (activityId) => {
  const { rows } = await q(
    `SELECT r.*, u.name AS student_name, u.email
     FROM registrations r
     JOIN users u ON u.id = r.user_id
     WHERE r.activity_id = $1
     ORDER BY r.id ASC`,
    [activityId]
  );
  return rows;
};

// 🟠 Cập nhật điểm danh
exports.updateAttendance = async (registrationId, status, marked_by) => {
  const { rows } = await q(
    `UPDATE registrations
     SET attendance_status = $1,
         marked_by = $2,
         marked_at = NOW()
     WHERE id = $3
     RETURNING *`,
    [status.toUpperCase(), marked_by, registrationId]
  );
  return rows[0];
};

// 📋 Xem danh sách điểm danh theo hoạt động
exports.listAttendanceByActivity = async (activityId) => {
  const { rows } = await q(
    `SELECT 
        r.id AS registration_id,
        u.name AS student_name,
        u.email,
        r.attendance_status,
        r.marked_at,
        m.name AS marked_by_name
     FROM registrations r
     JOIN users u ON u.id = r.user_id
     LEFT JOIN users m ON m.id = r.marked_by
     WHERE r.activity_id = $1
     ORDER BY r.id ASC`,
    [activityId]
  );
  return rows;
};
// 🧾 Danh sách đăng ký theo sinh viên (kèm tên giảng viên phụ trách)
exports.listByUser = async (userId) => {
  const { rows } = await q(
    `SELECT 
        a.title,
        a.location,
        a.start_at,
        a.end_at,
        a.reward_point,
        r.attendance_status,
        r.marked_at,
        u.name AS lecturer_name  -- 🆕 Giảng viên tạo hoạt động
     FROM registrations r
     JOIN activities a ON a.id = r.activity_id
     LEFT JOIN users u ON u.id = a.created_by
     WHERE r.user_id = $1
     ORDER BY a.start_at DESC`,
    [userId]
  );
  return rows;
};
