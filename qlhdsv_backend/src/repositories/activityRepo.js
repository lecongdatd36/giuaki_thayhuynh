const { q } = require("../db/pool");

// 🟢 Tạo hoạt động
exports.create = async (data) => {
    const {
        title,
        description,
        start_at,
        end_at,
        location,
        max_slots,
        reward_point,
        status,
        created_by,
    } = data;

    const { rows } = await q(
        `INSERT INTO activities
     (title, description, start_at, end_at, location, max_slots, reward_point, status, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
     RETURNING *`,
        [
            title,
            description,
            start_at,
            end_at,
            location,
            max_slots,
            reward_point,
            status,
            created_by,
        ]
    );
    return rows[0];
};

// 🟢 Danh sách hoạt động
exports.list = async () => {
    const { rows } = await q("SELECT * FROM activities ORDER BY id DESC");
    return rows;
};

// 🟢 Danh sách hoạt động theo giảng viên tạo
exports.listByCreator = async (lecturerId) => {
    const { rows } = await q(
        `SELECT * FROM activities 
     WHERE created_by = $1
     ORDER BY id DESC`,
        [lecturerId]
    );
    return rows;
};

// 🟢 Lấy 1 hoạt động theo ID
exports.get = async (id) => {
    const { rows } = await q("SELECT * FROM activities WHERE id=$1", [id]);
    return rows[0];
};

// 🟡 Cập nhật trạng thái tự động
exports.updateStatusAuto = async () => {
    await q(
        `UPDATE activities 
     SET status='CLOSED' 
     WHERE end_at < NOW() AND status!='CLOSED'`
    );
};

// 🟡 Cập nhật trạng thái thủ công
exports.updateStatus = async (id, status) => {
    const { rows } = await q(
        "UPDATE activities SET status=$2, updated_at=NOW() WHERE id=$1 RETURNING *",
        [id, status]
    );
    return rows[0];
};

// 🟢 Cập nhật toàn bộ thông tin hoạt động
exports.update = async (id, payload) => {
    const {
        title,
        description,
        start_at,
        end_at,
        location,
        max_slots,
        status,
        reward_point,
    } = payload;

    const { rows } = await q(
        `UPDATE activities 
     SET title = $1,
         description = $2,
         start_at = $3,
         end_at = $4,
         location = $5,
         max_slots = $6,
         status = $7,
         reward_point = $8,
         updated_at = NOW()
     WHERE id = $9
     RETURNING *`,
        [
            title,
            description,
            start_at,
            end_at,
            location,
            max_slots,
            status,
            reward_point,
            id,
        ]
    );
    return rows[0];
};

// 🔴 Xóa hoạt động
exports.delete = async (id) => {
    await q("DELETE FROM activities WHERE id=$1", [id]);
};

// 📊 Thống kê theo hoạt động (số lượng đăng ký và có mặt)
exports.getActivityStats = async () => {
    try {
        const { rows } = await q(`
      SELECT 
        a.id,
        a.title,
        COALESCE(u.name, 'Không rõ') AS lecturer_name,
        COUNT(r.id) AS total_registered,
        COUNT(CASE WHEN r.attendance_status = 'PRESENT' THEN 1 END) AS total_attended,
        ROUND(
          CASE WHEN COUNT(r.id) = 0 THEN 0
          ELSE COUNT(CASE WHEN r.attendance_status = 'PRESENT' THEN 1 END)::decimal / COUNT(r.id) * 100 END, 2
        ) AS attendance_rate
      FROM activities a
      LEFT JOIN registrations r ON r.activity_id = a.id
      LEFT JOIN users u ON a.created_by = u.id
      WHERE a.id IS NOT NULL
      GROUP BY a.id, a.title, u.name
      ORDER BY a.id ASC;
    `);
        return rows;
    } catch (err) {
        console.error("❌ Lỗi trong getActivityStats:", err);
        throw err;
    }
};



// 👨‍🏫 Thống kê theo giảng viên (số hoạt động, số đăng ký, tỉ lệ tham gia)
exports.getLecturerStats = async () => {
    try {
        const { rows } = await q(`
      SELECT 
        u.id,
        u.name AS lecturer_name,
        COUNT(DISTINCT a.id) AS total_activities,
        COUNT(r.id) AS total_registered,
        COUNT(CASE WHEN r.attendance_status = 'PRESENT' THEN 1 END) AS total_attended,
        ROUND(
          CASE WHEN COUNT(r.id) = 0 THEN 0
          ELSE COUNT(CASE WHEN r.attendance_status = 'PRESENT' THEN 1 END)::decimal / COUNT(r.id) * 100 END, 2
        ) AS attendance_rate
      FROM users u
      LEFT JOIN activities a ON a.created_by = u.id
      LEFT JOIN registrations r ON r.activity_id = a.id
      WHERE u.role = 'LECTURER'
      GROUP BY u.id, u.name
      ORDER BY total_activities DESC;
    `);
        return rows;
    } catch (err) {
        console.error("❌ Lỗi trong getLecturerStats:", err);
        throw err;
    }
};
