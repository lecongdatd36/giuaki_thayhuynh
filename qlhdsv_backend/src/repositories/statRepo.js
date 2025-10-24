const { q } = require("../db/pool");

// 🧮 Thống kê tổng quan cho ADMIN
exports.getAdminStats = async () => {
  const { rows } = await q(`
    SELECT
      (SELECT COUNT(*) FROM activities) AS total_activities,
      (SELECT COUNT(*) FROM users WHERE role='STUDENT') AS total_students,
      (SELECT COUNT(*) FROM registrations) AS total_registrations,
      (SELECT COUNT(*) FROM registrations WHERE attendance_status='PRESENT') AS total_present
  `);

  const { rows: topStudents } = await q(`
    SELECT u.name, u.email, SUM(a.reward_point) AS total_point
    FROM registrations r
    JOIN users u ON u.id = r.user_id
    JOIN activities a ON a.id = r.activity_id
    WHERE r.attendance_status='PRESENT'
    GROUP BY u.id
    ORDER BY total_point DESC
    LIMIT 5
  `);

  return { summary: rows[0], topStudents };
};

// 📊 Thống kê riêng cho giảng viên
exports.getLecturerStats = async (lecturerId) => {
  const { rows } = await q(`
    SELECT
      (SELECT COUNT(*) FROM activities WHERE created_by=$1) AS total_activities,
      (SELECT COUNT(*) FROM registrations r
        JOIN activities a ON a.id = r.activity_id
        WHERE a.created_by=$1) AS total_registrations,
      (SELECT COUNT(*) FROM registrations r
        JOIN activities a ON a.id = r.activity_id
        WHERE a.created_by=$1 AND r.attendance_status='PRESENT') AS total_present
  `, [lecturerId]);

  // 🔥 Thêm a.id ở đây nè
  const { rows: activityStats } = await q(`
    SELECT 
      a.id,                                   -- 🟢 thêm dòng này
      a.title,
      COUNT(r.id) AS registered_count,
      SUM(CASE WHEN r.attendance_status='PRESENT' THEN 1 ELSE 0 END) AS attended_count
    FROM activities a
    LEFT JOIN registrations r ON r.activity_id = a.id
    WHERE a.created_by=$1
    GROUP BY a.id, a.title
    ORDER BY a.id DESC
  `, [lecturerId]);

  return { summary: rows[0], activities: activityStats };
};

