const { q } = require("../db/pool");

// 🔍 Tìm user theo email
exports.findByEmail = async (email) => {
    const { rows } = await q("SELECT * FROM users WHERE email=$1", [email]);
    return rows[0];
};

// 🔍 Tìm user theo ID (phục vụ cho đổi mật khẩu)
exports.findById = async (id) => {
    const { rows } = await q("SELECT * FROM users WHERE id=$1", [id]);
    return rows[0];
};

// ➕ Tạo user mới
exports.create = async ({ name, email, password, role = "STUDENT" }) => {
    const { rows } = await q(
        `INSERT INTO users (name, email, password, role)
     VALUES ($1,$2,$3,$4)
     RETURNING id, name, email, role`,
        [name, email, password, role]
    );
    return rows[0];
};

// 🔑 Cập nhật mật khẩu mới
exports.updatePassword = async (id, newHash) => {
    const { rows } = await q(
        `UPDATE users SET password = $1 WHERE id = $2 RETURNING id, email, name`,
        [newHash, id]
    );
    return rows[0];
};
exports.list = async () => {
  const { rows } = await q("SELECT id, name, email, role FROM users ORDER BY id ASC");
  return rows;
};

// 🟠 Cập nhật thông tin user (admin)
exports.update = async (id, { name, email, password, role }) => {
  let sql = "UPDATE users SET ";
  const fields = [];
  const params = [];
  let i = 1;

  if (name) {
    fields.push(`name=$${i++}`);
    params.push(name);
  }
  if (email) {
    fields.push(`email=$${i++}`);
    params.push(email);
  }
  if (password) {
    fields.push(`password=$${i++}`);
    params.push(password);
  }
  if (role) {
    fields.push(`role=$${i++}`);
    params.push(role);
  }

  sql += fields.join(", ") + ` WHERE id=$${i} RETURNING id, name, email, role`;
  params.push(id);

  const { rows } = await q(sql, params);
  return rows[0];
};

// 🔴 Xóa user
exports.remove = async (id) => {
  const { rowCount } = await q("DELETE FROM users WHERE id=$1", [id]);
  return rowCount > 0;
};